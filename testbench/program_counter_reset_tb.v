
`timescale 1ns/1ps

module program_counter_reset_tb;

    reg clk;
    reg reset;
    reg pc_enable;
    reg [31:0] next_pc_value;

    wire [31:0] pc;

    integer errors;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_enable(pc_enable),
        .next_pc_value(next_pc_value),
        .pc(pc)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        pc_enable = 1;
        next_pc_value = 32'd0;
        errors = 0;

        // Test 1: Asynchronous reset
        #2;
        reset = 1;
        #1;

        if (pc !== 32'd0) begin
            $display("[FAIL] Asynchronous reset");
            errors = errors + 1;
        end else begin
            $display("[PASS] Asynchronous reset");
        end

        // Release reset
        #2;
        reset = 0;

        // Test 2: Normal PC update
        next_pc_value = 32'd100;
        @(posedge clk);
        #1;

        if (pc !== 32'd100) begin
            $display("[FAIL] PC update");
            errors = errors + 1;
        end else begin
            $display("[PASS] PC update");
        end

        // Test 3: PC hold when disabled
        pc_enable = 0;
        next_pc_value = 32'd200;
        @(posedge clk);
        #1;

        if (pc !== 32'd100) begin
            $display("[FAIL] PC hold");
            errors = errors + 1;
        end else begin
            $display("[PASS] PC hold");
        end

        // Test 4: Reset between clock edges
        #2;
        reset = 1;
        #1;

        if (pc !== 32'd0) begin
            $display("[FAIL] Mid-cycle reset");
            errors = errors + 1;
        end else begin
            $display("[PASS] Mid-cycle reset");
        end

        // Final result
        if (errors == 0)
            $display("ALL PC RESET TESTS PASSED!");
        else
            $display("PC RESET TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
