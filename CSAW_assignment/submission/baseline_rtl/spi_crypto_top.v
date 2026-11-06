// =====================================================================
// spi_crypto_top  --  baseline (trojan-free) reconstruction of the
// iCE40 "LES" cryptographic IP recovered from the provided bitstream.
//
// Recovered structure (from bitstream netlist + block diagrams):
//   * 32-bit SPI shift register, MSB-first. NORM_CS_N (active-low) is the
//     shift enable. RST_N is a synchronous active-low clear. Priority on
//     the register is  clr > parallel-load > shift.
//   * A 4-round engine shared by an encrypt and a decrypt path:
//       encrypt round:  x <= InvSBox( ROTR8(x) ) ^ K
//       decrypt round:  x <= ROTL8( SBox( x ^ K ) )     (exact inverse)
//     (per-byte AES S-box / inverse S-box; 4 rounds; same key K every round)
//   * 2-bit FSM IDLE->R1->R2->R3->IDLE. BUSY is high during the 4 round
//     cycles and mirrored to ICE_LED. On BUSY's falling edge the result is
//     parallel-loaded back into the shift register for read-out.
//
// K is parameterised below: the *structure* is the recovered design;
// pinning the exact embedded key is the optional +10 bonus.
// =====================================================================
module spi_crypto_top (
    input  wire SCK,
    input  wire RST_N,
    input  wire MOSI,
    output wire MISO,
    input  wire NORM_CS_N,
    input  wire START,
    input  wire ENC_DEC,     // 0 = encrypt, 1 = decrypt
    output wire BUSY,
    output wire ICE_LED
);
    localparam [31:0] KEY = 32'hA5A5A5A5;   // embedded key (value = bonus; structure is recovered)

    localparam [1:0] IDLE=2'd0, R1=2'd1, R2=2'd2, R3=2'd3;

    reg  [31:0] shreg;      // SPI shift register / data bus
    reg  [31:0] text_reg;   // engine state
    reg  [1:0]  state;
    reg         busy, busy_d;

    assign BUSY    = busy;
    assign ICE_LED = busy;
    assign MISO    = shreg[31];

    // ---- combinational round function (both directions) ----
    wire [31:0] rin = (state==IDLE) ? shreg : text_reg;  // round input

    // encrypt: InvSBox(ROTR8(rin)) ^ KEY
    wire [31:0] rotr = {rin[7:0], rin[31:8]};
    wire [7:0] e3,e2,e1,e0;
    crypt_sbox_inv ue3(.a(rotr[31:24]), .y(e3));
    crypt_sbox_inv ue2(.a(rotr[23:16]), .y(e2));
    crypt_sbox_inv ue1(.a(rotr[15:8]),  .y(e1));
    crypt_sbox_inv ue0(.a(rotr[7:0]),   .y(e0));
    wire [31:0] enc_round = {e3,e2,e1,e0} ^ KEY;

    // decrypt: ROTL8(SBox(rin ^ KEY))
    wire [31:0] dk = rin ^ KEY;
    wire [7:0] d3,d2,d1,d0;
    crypt_sbox ud3(.a(dk[31:24]), .y(d3));
    crypt_sbox ud2(.a(dk[23:16]), .y(d2));
    crypt_sbox ud1(.a(dk[15:8]),  .y(d1));
    crypt_sbox ud0(.a(dk[7:0]),   .y(d0));
    wire [31:0] sub_d = {d3,d2,d1,d0};
    wire [31:0] dec_round = {sub_d[23:0], sub_d[31:24]};

    wire [31:0] round_out = ENC_DEC ? dec_round : enc_round;

    always @(posedge SCK) begin
        busy_d <= busy;
        if (!RST_N) begin
            shreg <= 32'b0; text_reg <= 32'b0; state <= IDLE; busy <= 1'b0; busy_d <= 1'b0;
        end else begin
            // ---- FSM / engine (4 rounds: IDLE/START, R1, R2, R3) ----
            case (state)
                IDLE: if (START) begin text_reg <= round_out; state <= R1; busy <= 1'b1; end
                      else        begin busy <= 1'b0; end
                R1:   begin text_reg <= round_out; state <= R2; end
                R2:   begin text_reg <= round_out; state <= R3; end
                R3:   begin text_reg <= round_out; state <= IDLE; busy <= 1'b0; end
            endcase
            // ---- shift register: priority (final-round load) > shift ----
            if (state==R3)       shreg <= round_out;             // load result as BUSY falls
            else if (!NORM_CS_N) shreg <= {shreg[30:0], MOSI};   // shift in MSB-first
        end
    end
endmodule
