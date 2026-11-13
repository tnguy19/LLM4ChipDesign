`timescale 1ns/1ps
module tb_verify;
  reg SCK=0, RST_N=1, MOSI=0, NORM_CS_N=1, START=0, ENC_DEC=0;
  wire MISO, BUSY, ICE_LED;
  spi_crypto_top dut(.SCK(SCK),.RST_N(RST_N),.MOSI(MOSI),.MISO(MISO),
    .NORM_CS_N(NORM_CS_N),.START(START),.ENC_DEC(ENC_DEC),.BUSY(BUSY),.ICE_LED(ICE_LED));
  localparam T=10;
  task tick; begin SCK=1;#(T/2);SCK=0;#(T/2); end endtask
  task do_reset; begin RST_N=0;NORM_CS_N=1;START=0;tick;RST_N=1;tick; end endtask
  task load_word(input [31:0] w); integer i; begin
    NORM_CS_N=0; for(i=31;i>=0;i=i-1) begin MOSI=w[i];tick; end NORM_CS_N=1; end endtask
  task read_word(output [31:0] w); integer i; begin
    NORM_CS_N=0;w=0; for(i=31;i>=0;i=i-1) begin w[i]=MISO;tick; end NORM_CS_N=1; end endtask
  integer busyc;
  task run_engine; begin
    START=1; tick; START=0; busyc=0;
    while (BUSY===1'b1 && busyc<64) begin tick; busyc=busyc+1; end
  end endtask

  reg [31:0] vecs [0:5]; reg [31:0] ct, rt; integer k, fails;
  initial begin
    vecs[0]=32'h59C359C3; vecs[1]=32'h00000000; vecs[2]=32'hFFFFFFFF;
    vecs[3]=32'hDEADBEEF; vecs[4]=32'h12345678; vecs[5]=32'hA5A5A5A5;
    fails=0;
    for (k=0;k<6;k=k+1) begin
      do_reset; ENC_DEC=0; load_word(vecs[k]); run_engine; read_word(ct);
      do_reset; ENC_DEC=1; load_word(ct);     run_engine; read_word(rt);
      $display("pt=%08h -> ct=%08h -> dec=%08h  busy_cycles(enc)=%0d  %s",
               vecs[k], ct, rt, busyc, (rt===vecs[k])?"ROUNDTRIP OK":"*** FAIL ***");
      if (rt!==vecs[k]) fails=fails+1;
    end
    $display("\nSUMMARY: %0d/6 round-trips OK, busy_cycles=%0d (expect 4)", 6-fails, busyc);
    $finish;
  end
endmodule
