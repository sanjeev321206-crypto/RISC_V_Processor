module alu_mux (
    input [31:0] register_data,
    input [31:0] immediate,
    input alu_src,
    output [31:0] alu_operand_b
);

    assign alu_operand_b = alu_src ? immediate : register_data;

endmodule