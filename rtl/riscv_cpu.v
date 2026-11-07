
module riscv_cpu (
    input clk,
    input reset
);

    wire [31:0] pc;
    wire [31:0] next_pc_value;
    wire [31:0] pc_plus4;
    wire [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [31:0] immediate;

    wire reg_write, mem_read, mem_write;
    wire mem_to_reg, alu_src, branch, jump;
    wire [3:0] alu_control;

    wire [31:0] read_data1, read_data2;
    wire [31:0] write_back_data;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire zero;
    wire [31:0] memory_data;

    wire jalr;
    wire [31:0] jalr_target;

    wire auipc;
    wire [31:0] auipc_result;

    reg branch_condition;
    wire branch_taken;

    // Program Counter
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .pc_enable(1'b1),
        .next_pc_value(next_pc_value),
        .pc(pc)
    );

    assign pc_plus4 = pc + 32'd4;

    // Instruction Memory
    instruction_memory IMEM (
        .address(pc),
        .instruction(instruction)
    );

    // Instruction Decoder
    instruction_decoder DECODER (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    // Immediate Generator
    immediate_generator IMMGEN (
        .instruction(instruction),
        .immediate(immediate)
    );

    // Control Unit
    control_unit CONTROL (
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

    // Register File
    register_file REGFILE (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU Operand MUX
    alu_mux MUX (
        .register_data(read_data2),
        .immediate(immediate),
        .alu_src(alu_src),
        .alu_operand_b(alu_operand_b)
    );

    // ALU
    alu ALU (
        .A(read_data1),
        .B(alu_operand_b),
        .ALU_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Byte-addressable Data Memory
    data_memory DMEM (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_data)
    );

    // JALR target calculation
    assign jalr = (opcode == 7'b1100111);

    assign jalr_target =
        (read_data1 + immediate) & 32'hFFFFFFFE;

    // AUIPC calculation
    assign auipc = (opcode == 7'b0010111);

    assign auipc_result = pc + immediate;

    // Writeback selection
    assign write_back_data =
        jump ? pc_plus4 :
        auipc ? auipc_result :
        mem_to_reg ? memory_data :
        alu_result;

    // Branch comparison logic
    always @(*) begin
        case (funct3)
            3'b000: branch_condition = (read_data1 == read_data2);
            3'b001: branch_condition = (read_data1 != read_data2);
            3'b100: branch_condition =
                ($signed(read_data1) < $signed(read_data2));
            3'b101: branch_condition =
                ($signed(read_data1) >= $signed(read_data2));
            3'b110: branch_condition = (read_data1 < read_data2);
            3'b111: branch_condition = (read_data1 >= read_data2);
            default: branch_condition = 1'b0;
        endcase
    end

    assign branch_taken = branch && branch_condition;

    // Next PC selection
    assign next_pc_value =
        jalr ? jalr_target :
        jump ? (pc + immediate) :
        branch_taken ? (pc + immediate) :
        pc_plus4;

    // Simulation monitor
    always @(posedge clk) begin
        if (!reset) begin
            $display(
                "PC=%h INSTRUCTION=%h ALU_RESULT=%h BRANCH=%b JUMP=%b JALR=%b AUIPC=%b",
                pc, instruction, alu_result, branch_taken, jump, jalr, auipc
            );
        end
    end

endmodule
