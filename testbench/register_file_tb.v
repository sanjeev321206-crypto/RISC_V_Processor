`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg reg_write;
reg [4:0] rs1, rs2, rd;
reg [31:0] write_data;

wire [31:0] read_data1, read_data2;

register_file uut (
    .clk(clk),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    reg_write = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    write_data = 0;

    @(negedge clk);
    rd = 1;
    write_data = 100;
    reg_write = 1;

    @(negedge clk);
    reg_write = 0;

    rd = 2;
    write_data = 200;
    reg_write = 1;

    @(negedge clk);
    reg_write = 0;

    rs1 = 1;
    rs2 = 2;
    #1;

    $display("x1 = %d", read_data1);
    $display("x2 = %d", read_data2);

    @(negedge clk);
    rd = 0;
    write_data = 999;
    reg_write = 1;

    @(negedge clk);
    reg_write = 0;

    rs1 = 0;
    #1;

    $display("x0 after attempted write = %d", read_data1);

    $finish;
end

endmodule