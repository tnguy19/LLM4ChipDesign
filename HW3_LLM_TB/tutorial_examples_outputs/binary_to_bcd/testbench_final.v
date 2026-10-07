module tb_binary_to_bcd_converter;
    // Declare input and output signals
    reg [4:0] binary_input;
    wire [7:0] bcd_output;

    // Instantiate the module under test
    binary_to_bcd_converter uut (
        .binary_input(binary_input),
        .bcd_output(bcd_output)
    );

    integer passed_tests = 0;
    integer failed_tests = 0;

    initial begin
        // Test cases
        // Corner cases and boundary values
        $display("Test 1: binary_input = 00000");
        binary_input = 5'b00000; #10;
        if (bcd_output === 8'd0) begin
            $display("✓ Test 1: bcd_output = %d [Expected: 0]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 1: bcd_output = %d [Expected: 0]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 2: binary_input = 00001");
        binary_input = 5'b00001; #10;
        if (bcd_output === 8'd1) begin
            $display("✓ Test 2: bcd_output = %d [Expected: 1]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 2: bcd_output = %d [Expected: 1]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 3: binary_input = 11111");
        binary_input = 5'b11111; #10;
        if (bcd_output === 8'd49) begin
            $display("✓ Test 3: bcd_output = %d [Expected: 49]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 3: bcd_output = %d [Expected: 49]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 4: binary_input = 10000");
        binary_input = 5'b10000; #10;
        if (bcd_output === 8'd22) begin
            $display("✓ Test 4: bcd_output = %d [Expected: 22]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 4: bcd_output = %d [Expected: 22]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 5: binary_input = 01111");
        binary_input = 5'b01111; #10;
        if (bcd_output === 8'd21) begin
            $display("✓ Test 5: bcd_output = %d [Expected: 21]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 5: bcd_output = %d [Expected: 21]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Typical use cases
        $display("Test 6: binary_input = 00101");
        binary_input = 5'b00101; #10;
        if (bcd_output === 8'd5) begin
            $display("✓ Test 6: bcd_output = %d [Expected: 5]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 6: bcd_output = %d [Expected: 5]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 7: binary_input = 01010");
        binary_input = 5'b01010; #10;
        if (bcd_output === 8'd16) begin
            $display("✓ Test 7: bcd_output = %d [Expected: 16]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 7: bcd_output = %d [Expected: 16]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 8: binary_input = 01100");
        binary_input = 5'b01100; #10;
        if (bcd_output === 8'd18) begin
            $display("✓ Test 8: bcd_output = %d [Expected: 18]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 8: bcd_output = %d [Expected: 18]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Edge cases
        $display("Test 9: binary_input = 00010");
        binary_input = 5'b00010; #10;
        if (bcd_output === 8'd2) begin
            $display("✓ Test 9: bcd_output = %d [Expected: 2]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 9: bcd_output = %d [Expected: 2]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 10: binary_input = 00100");
        binary_input = 5'b00100; #10;
        if (bcd_output === 8'd4) begin
            $display("✓ Test 10: bcd_output = %d [Expected: 4]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 10: bcd_output = %d [Expected: 4]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        // Random values for thorough testing
        $display("Test 11: binary_input = 01001");
        binary_input = 5'b01001; #10;
        if (bcd_output === 8'd9) begin
            $display("✓ Test 11: bcd_output = %d [Expected: 9]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 11: bcd_output = %d [Expected: 9]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 12: binary_input = 10111");
        binary_input = 5'b10111; #10;
        if (bcd_output === 8'd35) begin
            $display("✓ Test 12: bcd_output = %d [Expected: 35]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 12: bcd_output = %d [Expected: 35]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 13: binary_input = 11001");
        binary_input = 5'b11001; #10;
        if (bcd_output === 8'd37) begin
            $display("✓ Test 13: bcd_output = %d [Expected: 37]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 13: bcd_output = %d [Expected: 37]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 14: binary_input = 10010");
        binary_input = 5'b10010; #10;
        if (bcd_output === 8'd24) begin
            $display("✓ Test 14: bcd_output = %d [Expected: 24]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 14: bcd_output = %d [Expected: 24]", bcd_output);
            failed_tests = failed_tests + 1;
        end

        $display("Test 15: binary_input = 01110");
        binary_input = 5'b01110; #10;
        if (bcd_output === 8'd20) begin
            $display("✓ Test 15: bcd_output = %d [Expected: 20]", bcd_output);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Test 15: bcd_output = %d [Expected: 20]", bcd_output);
            failed_tests = failed_tests + 1;
        end
        
        // Test summary
        $display("Test Summary: Total = %d, Passed = %d, Failed = %d", 
                 passed_tests + failed_tests, passed_tests, failed_tests);
        $finish;
    end
endmodule