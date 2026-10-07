module tb_sat_adder4;
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] sum;
    wire sat;

    integer passed_tests = 0;
    integer failed_tests = 0;

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
        if (sum === 4'b0000 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 0000, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b0000) begin
                $display("  sum: ✗ (expected 0000, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 0000, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 2: a = 1111, b = 0000");
        a = 4'b1111; b = 4'b0000; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 3: a = 0000, b = 1111");
        a = 4'b0000; b = 4'b1111; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 4: a = 1111, b = 0001");
        a = 4'b1111; b = 4'b0001; #10;
        if (sum === 4'b1111 && sat === 1'b1) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 1, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b1) begin
                $display("  sat: ✗ (expected 1, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 1, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 5: a = 1000, b = 0111");
        a = 4'b1000; b = 4'b0111; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 6: a = 1000, b = 1000");
        a = 4'b1000; b = 4'b1000; #10;
        if (sum === 4'b1111 && sat === 1'b1) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 1, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b1) begin
                $display("  sat: ✗ (expected 1, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 1, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 7: a = 1111, b = 1111");
        a = 4'b1111; b = 4'b1111; #10;
        if (sum === 4'b1111 && sat === 1'b1) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 1, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b1) begin
                $display("  sat: ✗ (expected 1, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 1, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 8: a = 0010, b = 0011");
        a = 4'b0010; b = 4'b0011; #10;
        if (sum === 4'b0101 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 0101, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b0101) begin
                $display("  sum: ✗ (expected 0101, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 0101, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 9: a = 0100, b = 0101");
        a = 4'b0100; b = 4'b0101; #10;
        if (sum === 4'b1001 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1001, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1001) begin
                $display("  sum: ✗ (expected 1001, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1001, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 10: a = 0110, b = 0010");
        a = 4'b0110; b = 4'b0010; #10;
        if (sum === 4'b1000 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1000, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1000) begin
                $display("  sum: ✗ (expected 1000, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1000, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 11: a = 0011, b = 0100");
        a = 4'b0011; b = 4'b0100; #10;
        if (sum === 4'b0111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 0111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b0111) begin
                $display("  sum: ✗ (expected 0111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 0111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 12: a = 0111, b = 0001");
        a = 4'b0111; b = 4'b0001; #10;
        if (sum === 4'b1000 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1000, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1000) begin
                $display("  sum: ✗ (expected 1000, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1000, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 13: a = 1010, b = 0100");
        a = 4'b1010; b = 4'b0100; #10;
        if (sum === 4'b1110 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1110, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1110) begin
                $display("  sum: ✗ (expected 1110, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1110, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 14: a = 1100, b = 0011");
        a = 4'b1100; b = 4'b0011; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 15: a = 1001, b = 0110");
        a = 4'b1001; b = 4'b0110; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 16: a = 0110, b = 1001");
        a = 4'b0110; b = 4'b1001; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 17: a = 0101, b = 0101");
        a = 4'b0101; b = 4'b0101; #10;
        if (sum === 4'b1010 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1010, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1010) begin
                $display("  sum: ✗ (expected 1010, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1010, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 18: a = 1110, b = 0001");
        a = 4'b1110; b = 4'b0001; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 19: a = 0010, b = 1101");
        a = 4'b0010; b = 4'b1101; #10;
        if (sum === 4'b1111 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 20: a = 1011, b = 0010");
        a = 4'b1011; b = 4'b0010; #10;
        if (sum === 4'b1101 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1101, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1101) begin
                $display("  sum: ✗ (expected 1101, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1101, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 21: a = 1101, b = 0001");
        a = 4'b1101; b = 4'b0001; #10;
        if (sum === 4'b1110 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1110, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1110) begin
                $display("  sum: ✗ (expected 1110, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1110, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 22: a = 1000, b = 0110");
        a = 4'b1000; b = 4'b0110; #10;
        if (sum === 4'b1110 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1110, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1110) begin
                $display("  sum: ✗ (expected 1110, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1110, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 23: a = 0111, b = 0111");
        a = 4'b0111; b = 4'b0111; #10;
        if (sum === 4'b1110 && sat === 1'b0) begin
            $display("  sum: ✓ (expected 1110, got %b)", sum);
            $display("  sat: ✓ (expected 0, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1110) begin
                $display("  sum: ✗ (expected 1110, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1110, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b0) begin
                $display("  sat: ✗ (expected 0, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 0, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end
        
        $display("Test 24: a = 0100, b = 1100");
        a = 4'b0100; b = 4'b1100; #10;
        if (sum === 4'b1111 && sat === 1'b1) begin
            $display("  sum: ✓ (expected 1111, got %b)", sum);
            $display("  sat: ✓ (expected 1, got %b)", sat);
            passed_tests = passed_tests + 2;
        end else begin
            if (sum !== 4'b1111) begin
                $display("  sum: ✗ (expected 1111, got %b)", sum);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sum: ✓ (expected 1111, got %b)", sum);
                passed_tests = passed_tests + 1;
            end
            if (sat !== 1'b1) begin
                $display("  sat: ✗ (expected 1, got %b)", sat);
                failed_tests = failed_tests + 1;
            end else begin
                $display("  sat: ✓ (expected 1, got %b)", sat);
                passed_tests = passed_tests + 1;
            end
        end

        $display("\nTest Summary:");
        $display("  Total tests run: %d", passed_tests + failed_tests);
        $display("  Number passed: %d", passed_tests);
        $display("  Number failed: %d", failed_tests);

        $finish;
    end

endmodule