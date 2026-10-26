module cov_dump;
  initial begin
    $dumpfile("./coverage_runs/adder8/cov_refine_2/raw.vcd");
    $dumpvars(0, adder8_tb);
  end
endmodule
