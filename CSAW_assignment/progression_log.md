# Progression log

A concise, chronological record of how the submission was produced. (The full prompt/response
transcript of the Claude Desktop "Cowork" session is the complete AI-interaction log; this file is a
summary of the key steps and decisions.)

## 1. Two AI approaches attempted
- **Anthropic API notebook (first attempt).** Built a Colab notebook to run an agentic bitstream →
  netlist → RTL → Trojan pipeline via the API. The API **refused** the Trojan-related calls
  (`stop_reason = refusal`), even with competition/GitHub context supplied — a false positive on this
  sanctioned task. Abandoned.
- **Claude Desktop "Cowork" (used).** An agentic session with a built-in Linux environment where the
  model runs shell commands, writes files, and executes Icarus Verilog itself. This produced the result.

## 2. Bitstream → netlist
- `iceunpack` + `icebox_vlog` recovered `netlist.v` (45,711 lines). `icebox_stat`: 71 DFFs, 1402 LUTs,
  4 BRAMs, 9 IOBs.

## 3. Pin / port identification (from netlist structure)
- 71 FFs clock on `io_9_31_1` → SCK.
- `assign io_19_31_0 = io_8_31_1` → BUSY (`io_8_31_1`) + ICE_LED (copy).
- Registered output `io_16_31_1` → MISO.
- Input fanout: 1-fanout → MOSI; two ~32-fanout → RST_N / NORM_CS_N; remaining → START / ENC_DEC.

## 4. S-box recovered from the bitstream
- All 4 BRAMs identical → one 8-bit S-box, one per byte lane.
- Decoded the iCE40 8-bit-mode (`READ_MODE=1`) BRAM init (two interleaved 8-bit fields per 16-bit cell)
  into a bijection → used as `crypt_sbox.v` (+ exact inverse `crypt_sbox_inv.v`).

## 5. Algorithm recovered and baseline RTL built
- Structure: 32-bit MSB-first SPI shift register; 2-bit FSM; 4 rounds of { byte-rotate, per-byte S-box,
  XOR key }; decrypt is the exact inverse.
- Wrote clean `spi_crypto_top` and verified in Icarus Verilog: 6/6 encrypt→decrypt round-trips.
- Clean-room note: an early pass confirmed the round arithmetic against the organizer-provided diagrams;
  this was redone to remove that dependency — the S-box is taken directly from the BRAM and the diagrams
  are not used. Not pinned from the netlist alone: exact rotation direction and the numeric key.

## 6. Trojan — iterative design
1. **v1 — single-constant trigger:** one magic plaintext arms a one-shot key readback. Works
   (~2⁻³² accidental) but a single full-word comparator is an obvious Trojan signature.
2. **v2 — sequential "knock" trigger:** three specific words in order across consecutive encrypt ops
   (~2⁻⁹⁶); one-shot key readback; auto-disarm. Harder to trip accidentally and to spot.
3. **v3 — distributed / disguised insertion (primary, `rtl/`):** same behavior as v2 but the logic is
   spread through the RTL with innocuous names (`dbg`, `mc`), BIST-labelled trigger taps, and a
   masking-XOR payload instead of an obvious key mux.
4. **Advanced — command-configurable covert serial exfiltration (`advanced_trojan/`):** the knock
   unlocks a channel; a command word configures the leak bit position and cadence; the key is then
   exfiltrated one bit per transaction, hidden in otherwise-valid ciphertext. Written readably.

## 7. Verification
- Baseline: 6/6 round-trips.
- Primary Trojan: fires only on the full ordered knock; negative test (wrong order) does not fire;
  differential check vs baseline over non-trigger traffic = 0 mismatches (normal operation preserved).
- Advanced Trojan: reconstructs the full 32-bit key from 32 ciphertexts; normal (non-unlock) traffic =
  0 mismatches; each leaked ciphertext is Hamming-distance ≤ 1 from the true ciphertext.

## 8. Packaging
- Assembled `rtl/`, `tb/`, `baseline_rtl/`, `advanced_trojan/`, `ai/`, and the technical brief (README).

## Note on AI guardrails (observed)
- The API refused Trojan-related requests outright. The Cowork session assisted but initially declined a
  fully covert, general-purpose exfiltration channel; it produced the readable, clearly-labelled
  versions here. Model-selection behaviour varied during the session.
