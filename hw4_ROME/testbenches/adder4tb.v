module adder4_tb;
  reg [3:0] a, b; reg cin; wire [3:0] sum; wire cout;
  integer errors;
  adder4 dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
  task check(input [3:0] ta, input [3:0] tb_, input tc);
    reg [4:0] expv;
    begin
      a = ta; b = tb_; cin = tc; #1;
      expv = ta + tb_ + tc;
      if ({cout, sum} !== expv) begin
        errors = errors + 1;
        $display("FAILED adder4 a=%0d b=%0d cin=%0d got=%0d exp=%0d", ta, tb_, tc, {cout, sum}, expv);
      end
    end
  endtask
  initial begin
    errors = 0;
    check(4'd0, 4'd0, 1'b0);
    check(4'd1, 4'd2, 1'b0);
    check(4'd7, 4'd8, 1'b0);
    check(4'd9, 4'd9, 1'b1);
    check(4'd15, 4'd15, 1'b1);
    if (errors == 0) $display("adder4 passed!"); else $display("adder4 failed");
    $finish;
  end
endmodule
