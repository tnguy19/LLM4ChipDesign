module adder8_tb;
  reg [7:0] a, b; reg cin; wire [7:0] sum; wire cout;
  integer errors;
  adder8 dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
  task check(input [7:0] ta, input [7:0] tb_, input tc);
    reg [8:0] expv;
    begin
      a = ta; b = tb_; cin = tc; #1;
      expv = ta + tb_ + tc;
      if ({cout,sum} !== expv) begin
        errors = errors + 1;
        $display("FAILED a=%0d b=%0d cin=%0d got=%0d exp=%0d", ta, tb_, tc, {cout,sum}, expv);
      end
    end
  endtask
  initial begin
    errors = 0;
    check(8'd1, 8'd2, 1'b0);
    check(8'd10, 8'd20, 1'b0);
    check(8'd0,  8'd0,  1'b0);
    // COVERAGE_TESTS_BEGIN
    // COVERAGE_TESTS_END
    if (errors == 0) $display("adder8 passed!"); else $display("adder8 failed");
    $finish;
  end
endmodule
