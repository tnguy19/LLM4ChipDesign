# AI reverse-engineering trace (clean-room: bitstream/netlist only, no solution diagrams)

1. iceunpack + icebox_vlog/icebox_explain -> netlist.v (45,711 lines).
   icebox_stat: 71 DFFs, 1402 LUTs, 4 BRAMs, 9 IOBs.
2. Port map from netlist structure:
   - 71 FFs clock on io_9_31_1            => SCK
   - assign io_19_31_0 = io_8_31_1        => BUSY (io_8_31_1) + ICE_LED (copy)
   - registered output io_16_31_1         => MISO
   - 1-fanout input                       => MOSI
   - two ~32-fanout inputs                => RST_N / NORM_CS_N
   - remaining inputs                     => START / ENC_DEC
3. S-box RECOVERED FROM THE BITSTREAM: all 4 BRAMs identical => one 8-bit S-box x4 byte lanes.
   iCE40 8-bit-mode (READ_MODE=1) two-field-per-cell decode -> a bijection (256 distinct values).
   Used verbatim as crypt_sbox.v; exact inverse as crypt_sbox_inv.v.
4. Structure from netlist + interface doc: 32-bit MSB-first shift register; ~2-bit FSM; 4 rounds
   (4 S-box BRAMs + "~4 clock cycles" BUSY from the interface doc); result parallel-loaded for readout.
5. Modelled round: 4x { byte-rotate, per-byte S-box, XOR key K }, decrypt = exact inverse.
   Baseline verified self-consistent: 6/6 encrypt->decrypt round-trips in Icarus Verilog.
   Byte-rotation direction and numeric K are not uniquely pinned from the netlist alone (K is a
   localparam; exact K = optional bonus).
6. Trojan (key exfil, SEQUENTIAL trigger KN1=0x3C8F17A2 -> KN2=0x9B216E4D -> KN3=0xF50AC3B9 on
   consecutive encrypt ops, then one-shot key readback, auto-disarm) inserted; differential sim vs
   baseline over random inputs (incl individual knock words) => 0 mismatches.

NOTE ON AI LOGS: produced interactively in a Claude (Cowork) session; export that conversation as
the required AI-interaction log. The companion notebook reproduces the flow via the Anthropic API.

NOTE: organizer-provided block diagrams were NOT used to produce this RTL.
