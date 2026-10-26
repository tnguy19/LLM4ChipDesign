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
module mux32_1(input [4:0] sel, input [31:0] in, output reg out);
always @* begin
    case (sel)
        5'd0:  out = in[0];
        5'd1:  out = in[1];
        5'd2:  out = in[2];
        5'd3:  out = in[3];
        5'd4:  out = in[4];
        5'd5:  out = in[5];
        5'd6:  out = in[6];
        5'd7:  out = in[7];
        5'd8:  out = in[8];
        5'd9:  out = in[9];
        5'd10: out = in[10];
        5'd11: out = in[11];
        5'd12: out = in[12];
        5'd13: out = in[13];
        5'd14: out = in[14];
        5'd15: out = in[15];
        5'd16: out = in[16];
        5'd17: out = in[17];
        5'd18: out = in[18];
        5'd19: out = in[19];
        5'd20: out = in[20];
        5'd21: out = in[21];
        5'd22: out = in[22];
        5'd23: out = in[23];
        5'd24: out = in[24];
        5'd25: out = in[25];
        5'd26: out = in[26];
        5'd27: out = in[27];
        5'd28: out = in[28];
        5'd29: out = in[29];
        5'd30: out = in[30];
        5'd31: out = in[31];
        default: out = 1'b0;
    endcase
end
endmodule
module mux64_1(input [5:0] sel, input [63:0] in, output reg out);
  wire lower_out;
  wire upper_out;

  mux32_1 u_lower (.sel(sel[4:0]), .in(in[31:0]),  .out(lower_out));
  mux32_1 u_upper (.sel(sel[4:0]), .in(in[63:32]), .out(upper_out));

  always @* begin
    out = sel[5] ? upper_out : lower_out;
  end
endmodule
