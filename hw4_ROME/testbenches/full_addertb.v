module full_adder_tb;
  reg a, b, cin; wire sum, cout;
  integer errors, i;
  full_adder dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
  initial begin
    errors = 0;
    for (i = 0; i < 8; i = i + 1) begin
      {a, b, cin} = i[2:0]; #1;
      if ({cout, sum} !== a + b + cin) begin
        errors = errors + 1;
        $display("FAILED full_adder a=%b b=%b cin=%b got cout=%b sum=%b", a, b, cin, cout, sum);
      end
    end
    if (errors == 0) $display("full_adder passed!"); else $display("full_adder failed");
    $finish;
  end
endmodule
