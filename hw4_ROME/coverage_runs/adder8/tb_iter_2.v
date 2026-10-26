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
        // Drive cin 0->1 and 1->0; also exercise internal carry generation in bit0 (half_adder 11)
        check(8'h00, 8'h00, 1'b1);
        check(8'h00, 8'h00, 1'b0);

        // Force LSB a=b=1 so half_adder sees 11 (xor and and) and generate carries; then clear to get 1->0 toggles
        check(8'h01, 8'h01, 1'b0);
        check(8'h00, 8'h00, 1'b0);

        // Create ripple carry through low nibble to raise c4 and exercise full_adder cout OR input combos; then drop it
        check(8'h0F, 8'h01, 1'b0);
        check(8'h00, 8'h00, 1'b0);

        // Create full 8-bit carry out to toggle cout and high sum bits; then clear to get 1->0 toggles
        check(8'hFF, 8'h01, 1'b0);
        check(8'h00, 8'h00, 1'b0);
        // Toggle b bits [1,3,5,6,7] 0->1 with no sum change (a=0) then force sum[5:7] 0->1 via a=1 and fall back
        check(8'h00, 8'h00, 1'b0);
        check(8'h00, 8'hEA, 1'b0);  // b[1,3,5,6,7] rise; sum mirrors b
        check(8'h00, 8'h00, 1'b0);  // b[3,5,6,7] fall back to 0

        // Exercise sum[5],sum[6],sum[7] 0->1 and 1->0 while keeping b stable (also re-toggles b[1])
        check(8'h20, 8'h00, 1'b0);  // sum[5] rise
        check(8'h40, 8'h00, 1'b0);  // sum[5] fall, sum[6] rise
        check(8'h80, 8'h00, 1'b0);  // sum[6] fall, sum[7] rise
        check(8'h00, 8'h00, 1'b0);  // sum[7] fall
    // COVERAGE_TESTS_END
    if (errors == 0) $display("adder8 passed!"); else $display("adder8 failed");
    $finish;
  end
endmodule
