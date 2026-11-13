# CSAW 2026 AI Hardware Attack Challenge — Qualifier Technical Brief

**Target:** the iCE40-UP5K lightweight cryptographic accelerator (SPI peripheral) recovered from the
provided `ice40_bitstream.bin`. All work is in simulation.

**Summary:** the bitstream was reverse-engineered into readable RTL, a hardware Trojan was inserted,
and the exploit was demonstrated in Icarus Verilog. Two Trojan variants are included — a distributed
one-shot key-leak (`rtl/`) and an advanced command-configurable covert serial key-exfiltration
(`advanced_trojan/`). No RTL or testbench was written by a human; all of it was AI-generated.

---

## 1. Reverse-engineering method

1. **Bitstream → netlist.** `iceunpack ice40_bitstream.bin` → `bitstream.asc`; `icebox_vlog` → a flat
   gate-level `netlist.v` (45,711 lines); `icebox_stat` → 71 DFFs, 1402 LUTs, **4 BRAMs**, 9 IOBs.
2. **Pin identification (from netlist structure, no constraint file):** all 71 flip-flops clock on
   `io_9_31_1` ⇒ **SCK**; `assign io_19_31_0 = io_8_31_1` ⇒ those equal outputs are **BUSY/ICE_LED**;
   the registered output `io_16_31_1` ⇒ **MISO**; fanout analysis of the inputs ⇒ **MOSI** (1-fanout),
   **RST_N/NORM_CS_N** (~32-fanout, gate all datapath flops), **START/ENC_DEC**.
3. **S-box recovered from the bitstream.** All 4 BRAMs are identical ⇒ one 256-entry 8-bit S-box across
   the four byte lanes. The iCE40 8-bit-mode (`READ_MODE=1`) BRAM init was decoded (two interleaved
   8-bit fields per 16-bit cell) into a **bijection** and used verbatim in `crypt_sbox.v` (inverse in
   `crypt_sbox_inv.v`).
4. **Structure** (netlist + interface doc): 32-bit MSB-first SPI shift register; a 2-bit FSM sequencing
   **4 rounds** (4 S-box BRAMs + "~4 clock cycles" of BUSY from the interface doc); result parallel-
   loaded into the shift register for read-out.

The organizer-provided "solution" block diagrams were **not** used to produce this RTL (clean-room).

## 2. Proposed explanation of how the encryption works

A **4-round** 32-bit block cipher with one 32-bit key `K`:

```
encrypt round :  x ← Sinv( ROT8(x) ) ⊕ K        x0 = plaintext,  ciphertext = x4
decrypt round :  x ← ROT8inv( S( x ⊕ K ) )       (exact inverse)
```

- `S` = the S-box recovered from the BRAM; `Sinv` = its exact inverse (so decrypt inverts encrypt).
- `ROT8` = an 8-bit (one-byte) rotation of the 32-bit word; the per-byte S-box is applied to all 4
  bytes in parallel (one BRAM each); the key is XORed each round.
- **Protocol** (from the interface doc): load 32 bits MSB-first over MOSI with `NORM_CS_N` low; pulse
  `START`; `BUSY` is high ~4 cycles; on BUSY's falling edge the result is loaded for read-out on MISO.

The baseline reconstruction (`baseline_rtl/`) is a self-consistent cipher: **6/6 encrypt→decrypt
round-trips pass** in simulation. Not uniquely pinned from the netlist alone: the exact byte-rotation
direction and the numeric key value (`K` is a `localparam`) — see §7.

## 3. AI usage method (interaction, models, framework)

- **Method of interaction:** the **Claude Desktop application with "Cowork" enabled** — an agentic
  session with a built-in Linux environment in which the model runs shell commands, writes files, and
  executes **Icarus Verilog** itself to check its own output. An earlier attempt used the **Anthropic
  API** directly from a Colab notebook (see §8).
- **Model(s):** Claude **Opus** (the session targeted Opus 5.5 / 4.8).
- **Framework around the AI:** an **agentic tool-use loop** — the model (a) ran IceStorm to recover the
  netlist, (b) traced/greped the netlist and decoded the BRAM S-box, (c) wrote baseline RTL, the Trojan
  RTL, and the testbench, and (d) compiled and simulated each candidate, reading the simulator output
  back and self-correcting. No hardware was written by a human; the model generated all RTL/testbench
  code, which was then machine-verified by compilation + simulation.

## 4. Trojan design

Two variants are provided.

### 4a. Primary — distributed one-shot key leak (`rtl/`)
- **Trigger (sequential "knock"):** arms only after three specific plaintext words arrive **in order**
  on consecutive encrypt operations — `0x3C8F17A2 → 0x9B216E4D → 0xF50AC3B9`. Any wrong/out-of-order
  word resets the sequence; accidental activation ≈ 2⁻⁹⁶.
- **Payload (one-shot):** the first encrypt operation after the knock returns the embedded key `K`
  over MISO instead of the ciphertext, then the Trojan disarms.
- **Stealth of insertion:** the logic is **distributed and disguised** in the RTL rather than added as
  an obvious block — the arm flag is named `dbg` (reads as "debug status"), the knock counter is `mc`
  (reads as a "monitor counter"), the trigger comparisons sit among the datapath wires labelled as
  BIST self-test taps, and the payload is folded into a masking XOR
  (`load_val = round_out ^ ({32{dbg}} & (round_out ^ KEY))`) that looks like benign output conditioning
  (there is no explicit `?KEY:` mux). It reuses the cipher's existing `KEY` constant, so no new
  suspicious value appears. Overhead: a few flip-flops + one mux; the cipher datapath and S-box are
  untouched; normal operation is **byte-identical** to the baseline (0-mismatch differential check).

### 4b. Advanced — command-configurable covert serial exfiltration (`advanced_trojan/`)
- **Trigger:** the same sequential knock unlocks the channel.
- **Coded instruction:** the encrypt word sent immediately after the knock is a command —
  `cmd[4:0]=leak_pos` (which ciphertext bit carries the leak), `cmd[9:5]=cadence-1` (leak every
  `cadence` operations). The channel is programmable, not a fixed dump.
- **Payload (covert serial):** each selected encrypt operation produces the normal ciphertext but
  overwrites **one bit** (at `leak_pos`) with the next key bit; 32 operations exfiltrate the whole key.
  Each output is Hamming-distance ≤ 1 from the true ciphertext, so it still looks like valid ciphertext.
- Normal operation is perfectly preserved for anyone who does not send the unlock sequence.

## 5. Exploit & simulation (how to exploit, in hardware too)

Testbenches drive the IP over the documented bit-banged SPI protocol (as in the provided micropython
script) and prove **both** normal operation and the payload.

- `tb/tb_agentic.v` (primary): shows normal encryption, a **negative test** (wrong-order knock does not
  arm), the sequential arming, the one-shot key leak (`TROJAN STATUS: TRIGGERED`), and auto-disarm.
- `advanced_trojan/tb/tb_agentic.v`: unlocks, sends the coded instruction, and reconstructs the full
  32-bit key from 32 ciphertexts (`reconstructed key = embedded key`).
- `tb/tb_verify.v`: baseline encrypt→decrypt round-trip (6/6).

**To exploit on real hardware** once a bitstream is built from this RTL: act as the SPI controller and
perform three encrypt operations with plaintexts `0x3C8F17A2`, `0x9B216E4D`, `0xF50AC3B9` in that order
(ignore their outputs); then one more encrypt operation and clock out 32 bits on MISO — those bits are
the device's embedded key (primary variant). For the advanced variant, after the knock send a command
word selecting an output bit, then read that bit across successive ciphertexts to assemble the key.

## 6. System automation & reproducibility

The pipeline (bitstream → netlist → recovered RTL → Trojan → simulation) was run end-to-end by the
agentic Cowork session, which executed the shell/IceStorm/iverilog steps itself. To reproduce the
simulations:
```bash
# baseline self-consistency (6/6 round-trips)
iverilog -g2012 -o v.out baseline_rtl/*.v tb/tb_verify.v && vvp v.out
# primary trojan exploit
iverilog -g2012 -o e.out rtl/*.v tb/tb_agentic.v && vvp e.out
# advanced covert-serial trojan exploit
cd advanced_trojan && iverilog -g2012 -o a.out rtl/*.v tb/tb_agentic.v && vvp a.out
```

## 7. Bonus — key recovery (status)

The exact embedded key `K` was **not** recovered and is left as a `localparam` placeholder. The S-box
and pin map are recovered from the bitstream; the key and the byte-rotation direction are the remaining
unknowns. The key could be brute-forced/solved against the published vector
`encrypt(0x59C359C3)=0x9CD84392` once the rotation direction and S-box bit-order are fixed. The Trojan
and its proof do not depend on the key's value.

## 8. AI conversation logs

This submission was produced interactively in a Claude Desktop (Cowork) session. The full prompt/
response transcript is included at **`ai/raw_conversation_log.pdf`** (the required AI-interaction log,
and the confirmation that no hardware was human-written). **`ai/transcript_cleaned.md`** is a readable,
typo-corrected version of the same exchange, and **`ai/progression_log.md`** summarizes the
chronological process. An earlier Anthropic-API agentic notebook was also attempted, but the API
refused the Trojan-related calls (a false positive on this sanctioned task), so the Cowork session was
used instead.

## Files
```
README.md               this technical brief
rtl/                    primary trojaned RTL (distributed one-shot) + S-box modules
tb/                     tb_agentic.v (exploit), tb_verify.v (round-trip)
baseline_rtl/           trojan-free reconstruction (diff oracle)
advanced_trojan/        command-configurable covert serial variant (rtl/ + tb/ + its own README)
ai/                     raw_conversation_log.pdf (full transcript), transcript_cleaned.md,
                        progression_log.md, reverse_engineering_notes.md
```
