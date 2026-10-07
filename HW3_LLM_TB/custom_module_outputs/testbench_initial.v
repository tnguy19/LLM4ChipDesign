module tb_sat_adder4;
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] sum;
    wire sat;

    // Instantiate the module under test
    sat_adder4 uut (
        .a(a),
        .b(b),
        .sum(sum),
        .sat(sat)
    );

    initial begin
        // Test cases

        // Corner cases
        $display("Test 1: a = 0000, b = 0000");
        a = 4'b0000; b = 4'b0000; #10;
        
        $display("Test 2: a = 1111, b = 0000");
        a = 4'b1111; b = 4'b0000; #10;
        
        $display("Test 3: a = 0000, b = 1111");
        a = 4'b0000; b = 4'b1111; #10;
        
        $display("Test 4: a = 1111, b = 0001");
        a = 4'b1111; b = 4'b0001; #10;
        
        $display("Test 5: a = 1000, b = 0111");
        a = 4'b1000; b = 4'b0111; #10;
        
        $display("Test 6: a = 1000, b = 1000");
        a = 4'b1000; b = 4'b1000; #10;
        
        $display("Test 7: a = 1111, b = 1111");
        a = 4'b1111; b = 4'b1111; #10;
        
        // Randomized input pairs
        $display("Test 8: a = 0010, b = 0011");
        a = 4'b0010; b = 4'b0011; #10;
        
        $display("Test 9: a = 0100, b = 0101");
        a = 4'b0100; b = 4'b0101; #10;
        
        $display("Test 10: a = 0110, b = 0010");
        a = 4'b0110; b = 4'b0010; #10;
        
        $display("Test 11: a = 0011, b = 0100");
        a = 4'b0011; b = 4'b0100; #10;
        
        $display("Test 12: a = 0111, b = 0001");
        a = 4'b0111; b = 4'b0001; #10;
        
        $display("Test 13: a = 1010, b = 0100");
        a = 4'b1010; b = 4'b0100; #10;
        
        $display("Test 14: a = 1100, b = 0011");
        a = 4'b1100; b = 4'b0011; #10;
        
        $display("Test 15: a = 1001, b = 0110");
        a = 4'b1001; b = 4'b0110; #10;
        
        $display("Test 16: a = 0110, b = 1001");
        a = 4'b0110; b = 4'b1001; #10;
        
        $display("Test 17: a = 0101, b = 0101");
        a = 4'b0101; b = 4'b0101; #10;
        
        $display("Test 18: a = 1110, b = 0001");
        a = 4'b1110; b = 4'b0001; #10;
        
        $display("Test 19: a = 0010, b = 1101");
        a = 4'b0010; b = 4'b1101; #10;
        
        $display("Test 20: a = 1011, b = 0010");
        a = 4'b1011; b = 4'b0010; #10;
        
        $display("Test 21: a = 1101, b = 0001");
        a = 4'b1101; b = 4'b0001; #10;
        
        $display("Test 22: a = 1000, b = 0110");
        a = 4'b1000; b = 4'b0110; #10;
        
        $display("Test 23: a = 0111, b = 0111");
        a = 4'b0111; b = 4'b0111; #10;
        
        $display("Test 24: a = 0100, b = 1100");
        a = 4'b0100; b = 4'b1100; #10;

        $finish;
    end

endmodule