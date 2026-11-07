`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire jump;
wire [3:0] alu_control;

control_unit uut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .jump(jump),
    .alu_control(alu_control)
);

initial begin

    // ADD
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;
    $display("ADD: ALU control = %b", alu_control);

    // SUB
    funct7 = 7'b0100000;
    #10;
    $display("SUB: ALU control = %b", alu_control);

    // AND
    funct3 = 3'b111;
    funct7 = 7'b0000000;
    #10;
    $display("AND: ALU control = %b", alu_control);

    // OR
    funct3 = 3'b110;
    #10;
    $display("OR: ALU control = %b", alu_control);

    // XOR
    funct3 = 3'b100;
    #10;
    $display("XOR: ALU control = %b", alu_control);

    // ADDI
    opcode = 7'b0010011;
    funct3 = 3'b000;
    #10;
    $display("ADDI: ALU control = %b", alu_control);

    // LOAD
    opcode = 7'b0000011;
    #10;
    $display("LOAD: reg_write=%b mem_read=%b", reg_write, mem_read);

    // STORE
    opcode = 7'b0100011;
    #10;
    $display("STORE: mem_write=%b", mem_write);

    // BRANCH
    opcode = 7'b1100011;
    #10;
    $display("BRANCH: branch=%b", branch);

    // JUMP
    opcode = 7'b1101111;
    #10;
    $display("JUMP: jump=%b", jump);

    $finish;

end

endmodule