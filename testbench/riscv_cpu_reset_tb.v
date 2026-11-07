
`timescale 1ns/1ps

module riscv_cpu_reset_tb;

    reg clk;
    reg reset;

    integer errors;

    riscv_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        errors = 0;

        // Test 1: Initial CPU reset
        #2;

        if (uut.pc !== 32'd0) begin
            $display("[FAIL] Initial CPU reset");
            errors = errors + 1;
        end else begin
            $display("[PASS] Initial CPU reset");
        end

        // Release reset
        #10;
        reset = 0;

        // Test 2: CPU execution advances PC
        @(posedge clk);
        #1;

        if (uut.pc !== 32'd4) begin
            $display("[FAIL] CPU execution");
            errors = errors + 1;
        end else begin
            $display("[PASS] CPU execution");
        end

        // Allow another instruction to execute
        @(posedge clk);
        #1;

        // Test 3: Assert reset while CPU is running
        #2;
        reset = 1;
        #1;

        if (uut.pc !== 32'd0) begin
            $display("[FAIL] Runtime CPU reset");
            errors = errors + 1;
        end else begin
            $display("[PASS] Runtime CPU reset");
        end

        // Keep reset active through a clock edge
        @(negedge clk);
        #1;
        reset = 0;

        // Test 4: CPU resumes execution
        @(posedge clk);
        #1;

        if (uut.pc !== 32'd4) begin
            $display("[FAIL] CPU resumes after reset");
            errors = errors + 1;
        end else begin
            $display("[PASS] CPU resumes after reset");
        end

        // Final result
        $display("------------------------------------");

        if (errors == 0)
            $display("ALL CPU RESET TESTS PASSED!");
        else
            $display("CPU RESET TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
