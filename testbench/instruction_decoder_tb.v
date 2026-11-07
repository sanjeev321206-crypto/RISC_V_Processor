`timescale 1ns/1ps

module instruction_decoder_tb;

reg [31:0] instruction;

wire [6:0] opcode;
wire [4:0] rd;
wire [2:0] funct3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [6:0] funct7;

instruction_decoder uut (
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
);

initial begin

    // ADD x3, x1, x2
    instruction = 32'h002081B3;
    #10;

    $display("Instruction: %h", instruction);
    $display("Opcode: %b", opcode);
    $display("rd: %d", rd);
    $display("funct3: %b", funct3);
    $display("rs1: %d", rs1);
    $display("rs2: %d", rs2);
    $display("funct7: %b", funct7);

    if (opcode == 7'b0110011 &&
        rd == 5'd3 &&
        funct3 == 3'b000 &&
        rs1 == 5'd1 &&
        rs2 == 5'd2 &&
        funct7 == 7'b0000000)
        $display("TEST PASSED!");
    else
        $display("TEST FAILED!");

    $finish;

end

endmodule