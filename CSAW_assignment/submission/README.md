# CSAW 2026 AI Hardware Attack Challenge — Qualifier Submission

**Target:** iCE40-UP5K lightweight cryptographic IP (SPI peripheral), recovered from the provided
`ice40_bitstream.bin`.

**Provenance note (clean-room):** the design was recovered from the bitstream/netlist and the
provided interface documentation only. The organizer-supplied "solution" block diagrams were **not**
used in producing this RTL.

---

## 1. Reverse-engineering method (bitstream → design)

1. **Bitstream → netlist.** `iceunpack ice40_bitstream.bin` → `bitstream.asc`, then `icebox_vlog`
   → a flat gate-level `netlist.v` (45,711 lines). `icebox_stat`: 71 DFFs, 1402 LUTs, **4 BRAMs**, 9 IOBs.
2. **Port identification (from netlist structure alone, no constraint file):**
   - All 71 flip-flops clock on `io_9_31_1` ⇒ **SCK**.
   - `assign io_19_31_0 = io_8_31_1;` ⇒ those two equal outputs are **BUSY** and **ICE_LED**
     (interface doc: ICE_LED mirrors BUSY).
   - The remaining registered output `io_16_31_1` ⇒ **MISO**.
   - Input fanout analysis: a 1-fanout net = **MOSI**; two ~32-fanout nets = **RST_N / NORM_CS_N**
     (both gate all 32 datapath flops); remaining = **START / ENC_DEC**.
3. **S-box (recovered from the bitstream).** All **4 BRAMs are identical** ⇒ one 256-entry 8-bit
   S-box replicated across the four byte lanes. Decoding the iCE40 8-bit-mode (`READ_MODE=1`) BRAM
   init (two interleaved 8-bit fields per 16-bit cell) yields a **bijection** — the substitution
   table is used verbatim in the RTL (`crypt_sbox.v`), with its exact inverse in `crypt_sbox_inv.v`.
4. **Structure (from the netlist + interface doc).** 32-bit MSB-first SPI shift register; a small
   (~2-bit) FSM sequencing **4 rounds** (consistent with the interface doc's "~4 clock cycles" of
   BUSY and the 4 S-box BRAMs); result parallel-loaded into the shift register for read-out.

## 2. Recovered algorithm

A **4-round** 32-bit block cipher, one 32-bit key `K`, per-byte S-box substitution and an 8-bit
byte rotation each round:

```
encrypt round :  x ← Sinv( ROT8(x) ) ⊕ K        x0 = plaintext,  ciphertext = x4
decrypt round :  x ← ROT8inv( S( x ⊕ K ) )       (exact inverse)
```

- `S` is the S-box recovered from the BRAM; `Sinv` is its exact inverse (so decrypt inverts encrypt).
- `ROT8` is an 8-bit (one-byte) rotation of the 32-bit word.
- The baseline (`baseline_rtl/`) is a self-consistent cipher: **6/6 encrypt→decrypt round-trips
  pass** in Icarus Verilog.

> Notes on what is and isn't pinned: the S-box values and the pin map are recovered directly from
> the bitstream. The round *structure* (4 rounds of rotate + S-box + key XOR) is inferred from the
> netlist (4 S-box BRAMs, a byte-rotation permutation, a 4-cycle FSM) and the interface doc; the
> exact byte-rotation direction and the numeric key value `K` are **not uniquely pinned** from the
> netlist alone and are modelled as a consistent choice (`K` is a `localparam`). Recovering the
> exact key is the optional +10 bonus and does not affect the Trojan or its proof.

## 3. AI usage method

The reverse-engineering and Trojan design were driven by a large language model (Claude) in an
agentic loop: it issued tool calls to unpack the bitstream, trace/grep the netlist, decode the
BRAM S-box, and compile/simulate candidate RTL with Icarus Verilog, iterating against simulation
output. No hardware (RTL/testbench) was written by a human. A companion Colab notebook implements
the same pipeline as an Anthropic-API agent flow; logs are in `ai/`.

## 4. Trojan design

| Property | Detail |
|---|---|
| **Type** | Key-exfiltration Trojan with a **sequential (multi-word) trigger** |
| **Trigger** | A **sequential "knock"**: the Trojan arms only after three specific plaintext words arrive **in order** on consecutive encrypt operations — `KN1=0x3C8F17A2 → KN2=0x9B216E4D → KN3=0xF50AC3B9`. Any out-of-order/wrong word resets the sequence. No single input reveals anything; accidental activation ≈ 2⁻⁹⁶. |
| **Payload** | One-shot: on the first encrypt operation **after** the knock, the value read back is the embedded key `K` instead of the ciphertext — over the existing MISO line, no extra I/O. The Trojan then disarms. |
| **Stealth** | With no knock the datapath, timing, ports and output are **byte-identical** to the baseline (verified by differential simulation, including inputs equal to the individual knock words). |
| **Overhead** | A 2-bit sequence register, an `armed` flag, a one-shot flag, and a 32-bit mux on the load path. Negligible. |

Implementation & stealth of insertion (`rtl/spi_crypto_top.v`): the Trojan is **distributed and
disguised** in the RTL rather than added as an obvious block, using techniques from the course:
- innocuous signal names that read as real features — `dbg` (a "debug-mode" status bit) is the arm
  flag, `mc` (an "operation monitor counter") is the knock sequence counter; no `trojan`/`armed`/`key`
  naming and no comments naming the trigger or payload.
- the payload is folded into a masking XOR that looks like benign output conditioning:
  `omask = {32{dbg}} & (round_out ^ KEY); load_val = round_out ^ omask;` — zero in normal mode, and
  equal to the key when `dbg` is set (there is no explicit `?KEY:` multiplexer to spot).
- the three trigger comparisons sit among the datapath `wire`s labelled as BIST / factory self-test
  taps, and the sequence update is interleaved into the normal FSM `case` rather than isolated.
- it reuses the cipher's existing `KEY` constant, introducing no new suspicious value.
Net: no single line reveals the Trojan — a reviewer must connect the "debug" bit, the "BIST" taps and
the "output conditioning" XOR to see the trigger-to-leak path. (This document discloses it; the stealth
target is the RTL artifact under code review.) The cipher datapath and S-box modules are untouched.

## 5. Exploit & simulation

`tb/tb_agentic.v` drives the IP over the documented bit-banged SPI protocol and shows normal
operation, a **negative test** (wrong-order knock does not arm), the sequential arming, the
one-shot key leak, and auto-disarm:

```
NORMAL     enc(0x12345678)=<ciphertext>           normal operation intact
NEG TEST   after wrong-order knock, enc(1)=...     no leak (good)
knock 1/3, 2/3, 3/3  → normal ciphertexts (ignored)
POST-KNOCK enc(0)=0xa5a5a5a5
TROJAN STATUS: TRIGGERED  → embedded key leaked over MISO
NEXT OP    enc(0)=...  disarmed, normal
```

Differential check (baseline vs trojaned) over 16 non-trigger words — including inputs equal to the
individual knock words (but never the full ordered sequence): **0 mismatches** — normal operation
perfectly preserved, no accidental trigger.

### Hardware exploitation
Act as the SPI controller: perform three encrypt operations with plaintexts `0x3C8F17A2`,
`0x9B216E4D`, `0xF50AC3B9` in that order (ignoring their outputs); then one more encrypt operation
and clock out 32 bits on MISO — the bits returned are the device's embedded key.

## 6. Reproduce
```bash
# baseline self-consistency (6/6 round-trips)
iverilog -g2012 -o v.out baseline_rtl/*.v tb/tb_verify.v && vvp v.out
# trojan exploit
iverilog -g2012 -o e.out rtl/*.v tb/tb_agentic.v && vvp e.out
```

## Files
```
rtl/           spi_crypto_top.v (TROJANED), crypt_sbox.v, crypt_sbox_inv.v  (S-box from the bitstream)
tb/            tb_agentic.v (exploit), tb_verify.v (round-trip check)
baseline_rtl/  trojan-free reconstruction (diff oracle)
ai/            reverse-engineering notes + AI-interaction logs
```
