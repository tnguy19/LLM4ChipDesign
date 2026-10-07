module tb_binary_to_bcd_converter;
    // Declare input and output signals
    reg [4:0] binary_input;
    wire [7:0] bcd_output;

    // Instantiate the module under test
    binary_to_bcd_converter uut (
        .binary_input(binary_input),
        .bcd_output(bcd_output)
    );

    initial begin
        // Test cases
        // Corner cases and boundary values
        $display("Test 1: binary_input = 00000");
        binary_input = 5'b00000; #10;
        
        $display("Test 2: binary_input = 00001");
        binary_input = 5'b00001; #10;

        $display("Test 3: binary_input = 11111");
        binary_input = 5'b11111; #10;

        $display("Test 4: binary_input = 10000");
        binary_input = 5'b10000; #10;

        $display("Test 5: binary_input = 01111");
        binary_input = 5'b01111; #10;

        // Typical use cases
        $display("Test 6: binary_input = 00101");
        binary_input = 5'b00101; #10;

        $display("Test 7: binary_input = 01010");
        binary_input = 5'b01010; #10;

        $display("Test 8: binary_input = 01100");
        binary_input = 5'b01100; #10;

        // Edge cases
        $display("Test 9: binary_input = 00010");
        binary_input = 5'b00010; #10;

        $display("Test 10: binary_input = 00100");
        binary_input = 5'b00100; #10;

        // Random values for thorough testing
        $display("Test 11: binary_input = 01001");
        binary_input = 5'b01001; #10;

        $display("Test 12: binary_input = 10111");
        binary_input = 5'b10111; #10;

        $display("Test 13: binary_input = 11001");
        binary_input = 5'b11001; #10;

        $display("Test 14: binary_input = 10010");
        binary_input = 5'b10010; #10;

        $display("Test 15: binary_input = 01110");
        binary_input = 5'b01110; #10;

        $finish;
    end
endmodule