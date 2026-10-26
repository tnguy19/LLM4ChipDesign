module adder8(input [7:0] a, input [7:0] b, input cin, output [7:0] sum, output cout);
  wire c4;

  adder4 u0 (
    .a   (a[3:0]),
    .b   (b[3:0]),
    .cin (cin),
    .sum (sum[3:0]),
    .cout(c4)
  );

  adder4 u1 (
    .a   (a[7:4]),
    .b   (b[7:4]),
    .cin (c4),
    .sum (sum[7:4]),
    .cout(cout)
  );
endmodule
