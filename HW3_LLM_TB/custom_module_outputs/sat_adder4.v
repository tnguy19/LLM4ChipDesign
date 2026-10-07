
module sat_adder4 (
    input wire [3:0] a,
    input wire [3:0] b,
    output wire [3:0] sum,
    output wire sat
);
    wire [4:0] full;
    assign full = a + b;
    assign sat  = full[4];
    assign sum  = full[4] ? 4'b1111 : full[3:0];
endmodule
