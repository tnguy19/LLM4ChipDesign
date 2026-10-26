module cov_dump;
  initial begin
    $dumpfile("./coverage_runs/mux64_1/raw.vcd");
    $dumpvars(0, tb_mux64_1);
  end
endmodule
