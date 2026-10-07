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

    initial begin
        // Test Case 1
        a = 0; b = 0; sel = 0;
        #10;
        $display("Test Case 1: a=%b, b=%b, sel=%b", a, b, sel);
        
        // Test Case 2
        a = 0; b = 0; sel = 1;
        #10;
        $display("Test Case 2: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 3
        a = 0; b = 1; sel = 0;
        #10;
        $display("Test Case 3: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 4
        a = 0; b = 1; sel = 1;
        #10;
        $display("Test Case 4: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 5
        a = 1; b = 0; sel = 0;
        #10;
        $display("Test Case 5: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 6
        a = 1; b = 0; sel = 1;
        #10;
        $display("Test Case 6: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 7
        a = 1; b = 1; sel = 0;
        #10;
        $display("Test Case 7: a=%b, b=%b, sel=%b", a, b, sel);

        // Test Case 8
        a = 1; b = 1; sel = 1;
        #10;
        $display("Test Case 8: a=%b, b=%b, sel=%b", a, b, sel);

        $finish;
    end
endmodule