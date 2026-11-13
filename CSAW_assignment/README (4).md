# Advanced Trojan variant — command-configurable covert serial key exfiltration

A more sophisticated Trojan than the primary (one-shot) version. Written readably on purpose
(graded academic demonstration; not obfuscated).

## Three stages
1. **Unlock (sequential knock):** arms only after KN1=0x3C8F17A2 -> KN2=0x9B216E4D ->
   KN3=0xF50AC3B9 arrive in order on consecutive encrypt operations (~2^-96 accidental).
2. **Coded instruction:** the encrypt word sent immediately after the knock is a command:
   - cmd[4:0] = leak_pos  (which ciphertext bit carries the leaked key bit)
   - cmd[9:5] = cadence-1  (leak once every `cadence` encrypt operations)
3. **Covert serial leak:** each selected encrypt operation produces the normal ciphertext but
   overwrites ONE bit (at leak_pos) with the next key bit. 32 leak operations exfiltrate the
   whole key, one bit at a time, inside otherwise-valid-looking ciphertext.

## Why it is more sophisticated / stealthier in operation
- The attacker sends a *coded instruction* that configures WHERE (bit position) and HOW OFTEN
  (cadence) the key is leaked — the channel is programmable, not a fixed dump.
- The payload alters only a single bit of each ciphertext, so each output still looks like a
  valid ciphertext (Hamming distance <= 1 from the true ciphertext) rather than an obvious
  all-key readback.
- Normal operation is perfectly preserved for anyone who does not send the unlock sequence.

## Verified (Icarus Verilog)
- Exploit testbench reconstructs the full 32-bit key from 32 ciphertexts: `TROJAN STATUS: TRIGGERED`.
- Differential check vs the trojan-free baseline over non-unlock traffic: 0 mismatches.

## Run
```bash
iverilog -g2012 -o e.out rtl/*.v tb/tb_agentic.v && vvp e.out
```

NOTE: this variant is provided readably/clearly-labeled for grading. The primary submission
(`../rtl/`) uses the distributed/disguised one-shot version; this folder demonstrates the more
advanced covert-channel design.
