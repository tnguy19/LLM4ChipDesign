module half_adder_tb;
  reg a, b; wire sum, carry;
  integer errors;
  half_adder dut(.a(a), .b(b), .sum(sum), .carry(carry));
  task check(input ta, input tb_);
    begin
      a = ta; b = tb_; #1;
      if ({carry, sum} !== ta + tb_) begin
        errors = errors + 1;
        $display("FAILED half_adder a=%b b=%b got carry=%b sum=%b", ta, tb_, carry, sum);
      end
    end
  endtask
  initial begin
    errors = 0;
    check(0, 0);
    check(0, 1);
    check(1, 0);
    check(1, 1);
    if (errors == 0) $display("half_adder passed!"); else $display("half_adder Failed");
    $finish;
  end
endmodule
