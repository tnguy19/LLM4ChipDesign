module mux2_1(input wire in1, input wire in2, input wire select, output wire out);
    assign out = select ? in2 : in1;
endmodule
module mux4_1(input [1:0] sel, input [3:0] in, output reg out);
always @* begin
    case (sel)
        2'b00: out = in[0];
        2'b01: out = in[1];
        2'b10: out = in[2];
        2'b11: out = in[3];
        default: out = 1'b0;
    endcase
end
endmodule
module mux8_1(input [2:0] sel, input [7:0] in, output reg out);
always @(*) begin
    case (sel)
        3'b000: out = in[0];
        3'b001: out = in[1];
        3'b010: out = in[2];
        3'b011: out = in[3];
        3'b100: out = in[4];
        3'b101: out = in[5];
        3'b110: out = in[6];
        3'b111: out = in[7];
        default: out = 1'b0;
    endcase
end
endmodule
module mux16_1(input [3:0] sel, input [15:0] in, output reg out);
always @* begin
    case (sel)
        4'b0000: out = in[0];
        4'b0001: out = in[1];
        4'b0010: out = in[2];
        4'b0011: out = in[3];
        4'b0100: out = in[4];
        4'b0101: out = in[5];
        4'b0110: out = in[6];
        4'b0111: out = in[7];
        4'b1000: out = in[8];
        4'b1001: out = in[9];
        4'b1010: out = in[10];
        4'b1011: out = in[11];
        4'b1100: out = in[12];
        4'b1101: out = in[13];
        4'b1110: out = in[14];
        4'b1111: out = in[15];
        default: out = 1'b0;
    endcase
end
endmodule
