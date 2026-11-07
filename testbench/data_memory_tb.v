
`timescale 1ns/1ps

module data_memory_tb;

    reg clk;
    reg mem_read;
    reg mem_write;
    reg [2:0] funct3;
    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;

    integer errors;

    data_memory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_read = 0;
        mem_write = 0;
        funct3 = 0;
        address = 0;
        write_data = 0;
        errors = 0;

        $display("\n========== DATA MEMORY VERIFICATION ==========");

        // Test 1: SW
        @(negedge clk);
        address = 32'd0;
        write_data = 32'h12345678;
        funct3 = 3'b010;
        mem_write = 1;
        @(negedge clk);
        mem_write = 0;

        // Test 2: LW
        address = 32'd0;
        funct3 = 3'b010;
        mem_read = 1;
        #1;
        $display("LW  Result = %h | Expected = 12345678", read_data);
        if (read_data !== 32'h12345678) errors = errors + 1;

        // Test 3: LH
        funct3 = 3'b001;
        #1;
        $display("LH  Result = %h | Expected = 00005678", read_data);
        if (read_data !== 32'h00005678) errors = errors + 1;

        // Test 4: LHU
        funct3 = 3'b101;
        #1;
        $display("LHU Result = %h | Expected = 00005678", read_data);
        if (read_data !== 32'h00005678) errors = errors + 1;

        // Test 5: SB
        mem_read = 0;
        address = 32'd4;
        write_data = 32'h00000080;
        funct3 = 3'b000;
        mem_write = 1;
        @(negedge clk);
        mem_write = 0;

        // Test 6: LB
        mem_read = 1;
        funct3 = 3'b000;
        #1;
        $display("LB  Result = %h | Expected = FFFFFF80", read_data);
        if (read_data !== 32'hFFFFFF80) errors = errors + 1;

        // Test 7: LBU
        funct3 = 3'b100;
        #1;
        $display("LBU Result = %h | Expected = 00000080", read_data);
        if (read_data !== 32'h00000080) errors = errors + 1;

        // Test 8: SH
        mem_read = 0;
        address = 32'd6;
        write_data = 32'h000080FE;
        funct3 = 3'b001;
        mem_write = 1;
        @(negedge clk);
        mem_write = 0;

        // Test 9: LH with negative value
        mem_read = 1;
        funct3 = 3'b001;
        #1;
        $display("LH  Result = %h | Expected = FFFF80FE", read_data);
        if (read_data !== 32'hFFFF80FE) errors = errors + 1;

        // Test 10: LHU with same value
        funct3 = 3'b101;
        #1;
        $display("LHU Result = %h | Expected = 000080FE", read_data);
        if (read_data !== 32'h000080FE) errors = errors + 1;

        // Final result
        $display("\nErrors detected: %0d", errors);

        if (errors == 0)
            $display("ALL DATA MEMORY TESTS PASSED!");
        else
            $display("DATA MEMORY VERIFICATION FAILED!");

        $display("==============================================");

        $finish;
    end

endmodule
