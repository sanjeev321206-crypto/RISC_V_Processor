
`timescale 1ns/1ps

module program_counter_tb;

    reg clk;
    reg reset;

    riscv_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        // Load a dedicated BGE test program
        #1;

        uut.IMEM.memory[0] = 32'h01400093; // ADDI x1, x0, 20
        uut.IMEM.memory[1] = 32'h00A00113; // ADDI x2, x0, 10
        uut.IMEM.memory[2] = 32'h0020D463; // BGE x1, x2, +8
        uut.IMEM.memory[3] = 32'h06300413; // ADDI x8, x0, 99 (skipped)
        uut.IMEM.memory[4] = 32'h002081B3; // ADD x3, x1, x2

        // Wait until the program is loaded
        #11;
        reset = 0;

        // Allow the processor to execute
        #60;

        $display("\n========== BGE VERIFICATION ==========");

        $display("x1 = %h (Expected: 00000014)",
                 uut.REGFILE.registers[1]);

        $display("x2 = %h (Expected: 0000000a)",
                 uut.REGFILE.registers[2]);

        $display("x8 = %h (Expected: 00000000 - SKIPPED)",
                 uut.REGFILE.registers[8]);

        $display("x3 = %h (Expected: 0000001e)",
                 uut.REGFILE.registers[3]);

        if (
            uut.REGFILE.registers[1] == 32'd20 &&
            uut.REGFILE.registers[2] == 32'd10 &&
            uut.REGFILE.registers[8] == 32'd0 &&
            uut.REGFILE.registers[3] == 32'd30
        ) begin
            $display("\nBGE TEST PASSED!");
        end
        else begin
            $display("\nBGE TEST FAILED!");
        end

        $display("=====================================");

        $finish;

    end

endmodule
