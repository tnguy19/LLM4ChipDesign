module mux2to1_tb;
    // Declare inputs as regs and outputs as wires
    reg a, b, sel;
    wire y;

    // Instantiate the module under test
    mux2to1 uut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    integer passed_tests = 0;
    integer failed_tests = 0;

    initial begin
        // Test Case 1
        a = 0; b = 0; sel = 0;
        #10;
        $display("Test Case 1: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 0) begin
            $display("✓ Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end
        
        // Test Case 2
        a = 0; b = 0; sel = 1;
        #10;
        $display("Test Case 2: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 0) begin
            $display("✓ Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 3
        a = 0; b = 1; sel = 0;
        #10;
        $display("Test Case 3: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 0) begin
            $display("✓ Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 4
        a = 0; b = 1; sel = 1;
        #10;
        $display("Test Case 4: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 1) begin
            $display("✓ Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 5
        a = 1; b = 0; sel = 0;
        #10;
        $display("Test Case 5: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 1) begin
            $display("✓ Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 6
        a = 1; b = 0; sel = 1;
        #10;
        $display("Test Case 6: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 0) begin
            $display("✓ Pass: y=%b (Expected: 0)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 0)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 7
        a = 1; b = 1; sel = 0;
        #10;
        $display("Test Case 7: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 1) begin
            $display("✓ Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Case 8
        a = 1; b = 1; sel = 1;
        #10;
        $display("Test Case 8: a=%b, b=%b, sel=%b", a, b, sel);
        #10;
        if (y === 1) begin
            $display("✓ Pass: y=%b (Expected: 1)", y);
            passed_tests = passed_tests + 1;
        end else begin
            $display("✗ Fail: y=%b (Expected: 1)", y);
            failed_tests = failed_tests + 1;
        end

        // Test Summary
        $display("Test Summary: Total Tests: %d, Passed: %d, Failed: %d", passed_tests + failed_tests, passed_tests, failed_tests);
        $finish;
    end
endmodule