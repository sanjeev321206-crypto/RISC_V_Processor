
`timescale 1ns/1ps

module data_memory_boundary_tb;

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

    // Store operation task
    task store;
        input [2:0] operation;
        input [31:0] addr;
        input [31:0] value;
        begin
            @(negedge clk);
            funct3 = operation;
            address = addr;
            write_data = value;
            mem_write = 1;

            @(posedge clk);
            #1;
            mem_write = 0;
        end
    endtask

    // Load and compare operation task
    task check_load;
        input [2:0] operation;
        input [31:0] addr;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            funct3 = operation;
            address = addr;
            mem_read = 1;

            #1;

            if (read_data === expected) begin
                $display("[PASS] %0s: %h",
                         test_name, read_data);
            end
            else begin
                $display("[FAIL] %0s: Got %h, Expected %h",
                         test_name, read_data, expected);
                errors = errors + 1;
            end

            mem_read = 0;
        end
    endtask

    initial begin

        clk = 0;
        mem_read = 0;
        mem_write = 0;
        funct3 = 0;
        address = 0;
        write_data = 0;
        errors = 0;

        #2;

        $display("\n======================================");
        $display(" DATA MEMORY BOUNDARY VERIFICATION");
        $display("======================================");

        // Test 1: Valid word access at address 1020
        store(3'b010, 32'd1020, 32'h12345678);
        check_load(3'b010, 32'd1020,
                   32'h12345678, "Valid SW/LW at 1020");

        // Test 2: Invalid word store at address 1021
        store(3'b010, 32'd1021, 32'hFFFFFFFF);
        check_load(3'b100, 32'd1021,
                   32'h00000056, "Invalid SW preserves byte 1021");

        // Test 3: Valid halfword access at address 1022
        store(3'b001, 32'd1022, 32'h0000A1B2);
        check_load(3'b101, 32'd1022,
                   32'h0000A1B2, "Valid SH/LHU at 1022");

        // Test 4: Invalid halfword store at address 1023
        store(3'b001, 32'd1023, 32'h0000FFFF);
        check_load(3'b100, 32'd1023,
                   32'h000000A1, "Invalid SH preserves byte 1023");

        // Test 5: Invalid byte access at address 1024
        check_load(3'b100, 32'd1024,
                   32'h00000000, "Out-of-range LBU at 1024");

        // Test 6: Unaligned word access at address 101
        store(3'b010, 32'd101, 32'hDEADBEEF);
        check_load(3'b010, 32'd101,
                   32'hDEADBEEF, "Unaligned SW/LW at 101");

        // Test 7: Invalid word load at address 1024
        check_load(3'b010, 32'd1024,
                   32'h00000000, "Out-of-range LW at 1024");

        $display("\n======================================");

        if (errors == 0)
            $display("ALL BOUNDARY TESTS PASSED!");
        else
            $display("BOUNDARY TESTS FAILED: %0d errors", errors);

        $display("Total errors: %0d", errors);
        $display("======================================");

        $finish;

    end

endmodule
