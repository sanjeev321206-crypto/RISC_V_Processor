`timescale 1ns/1ps

module alu_mux_tb;

reg [31:0] register_data;
reg [31:0] immediate;
reg alu_src;

wire [31:0] alu_operand_b;

alu_mux uut (
    .register_data(register_data),
    .immediate(immediate),
    .alu_src(alu_src),
    .alu_operand_b(alu_operand_b)
);

initial begin

    register_data = 32'd25;
    immediate = 32'd10;

    // Select register data
    alu_src = 0;
    #10;
    $display("Register selected: %d", alu_operand_b);

    // Select immediate
    alu_src = 1;
    #10;
    $display("Immediate selected: %d", alu_operand_b);

    $finish;

end

endmodule