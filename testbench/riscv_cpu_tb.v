
`timescale 1ns/1ps

module riscv_cpu_tb;

    reg clk;
    reg reset;

    riscv_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        // GTKWave waveform recording
        $dumpfile("riscv_wave.vcd");
        $dumpvars(0, uut);

        clk = 0;
        reset = 1;

        #12;
        reset = 0;

        #80;

        $display("\n========== CPU LOAD/STORE VERIFICATION ==========");

        $display("x3 (LB Result)  = %h (Expected: FFFFFFFE)",
                 uut.REGFILE.registers[3]);

        $display("x4 (LBU Result) = %h (Expected: 000000FE)",
                 uut.REGFILE.registers[4]);

        $display("x5 (LH Result)  = %h (Expected: FFFF80FE)",
                 uut.REGFILE.registers[5]);

        $display("x6 (LHU Result) = %h (Expected: 000080FE)",
                 uut.REGFILE.registers[6]);

        $display("\nMemory Byte Verification:");

        $display("Memory[64] = %h (Expected: FE)",
                 uut.DMEM.memory[64]);

        $display("Memory[66] = %h (Expected: FE)",
                 uut.DMEM.memory[66]);

        $display("Memory[67] = %h (Expected: 80)",
                 uut.DMEM.memory[67]);

        if (uut.REGFILE.registers[3] == 32'hFFFFFFFE &&
            uut.REGFILE.registers[4] == 32'h000000FE &&
            uut.REGFILE.registers[5] == 32'hFFFF80FE &&
            uut.REGFILE.registers[6] == 32'h000080FE &&
            uut.DMEM.memory[64] == 8'hFE &&
            uut.DMEM.memory[66] == 8'hFE &&
            uut.DMEM.memory[67] == 8'h80)

            $display("\nCPU LOAD/STORE TEST PASSED!");

        else
            $display("\nCPU LOAD/STORE TEST FAILED!");

        $display("================================================");

        $finish;
    end

endmodule
