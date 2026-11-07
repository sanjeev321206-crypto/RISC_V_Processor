
module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg branch,
    output reg jump,
    output reg [3:0] alu_control
);

    always @(*) begin

        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        mem_to_reg = 0;
        alu_src = 0;
        branch = 0;
        jump = 0;
        alu_control = 4'b0000;

        case (opcode)

            // R-type instructions
            7'b0110011: begin
                reg_write = 1;

                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_control = 4'b0000;
                    {7'b0100000, 3'b000}: alu_control = 4'b0001;
                    {7'b0000000, 3'b111}: alu_control = 4'b0010;
                    {7'b0000000, 3'b110}: alu_control = 4'b0011;
                    {7'b0000000, 3'b100}: alu_control = 4'b0100;
                    {7'b0000000, 3'b001}: alu_control = 4'b0101;
                    {7'b0000000, 3'b101}: alu_control = 4'b0110;
                    {7'b0000000, 3'b010}: alu_control = 4'b0111;
                    {7'b0100000, 3'b101}: alu_control = 4'b1000;
                    {7'b0000000, 3'b011}: alu_control = 4'b1001;

                    default: begin
                        reg_write = 0;
                        alu_control = 4'b0000;
                    end
                endcase
            end

            // I-type arithmetic instructions
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1;

                case (funct3)
                    3'b000: alu_control = 4'b0000;
                    3'b111: alu_control = 4'b0010;
                    3'b110: alu_control = 4'b0011;
                    3'b100: alu_control = 4'b0100;

                    3'b001: begin
                        if (funct7 == 7'b0000000)
                            alu_control = 4'b0101;
                        else
                            reg_write = 0;
                    end

                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            alu_control = 4'b0110;
                        else if (funct7 == 7'b0100000)
                            alu_control = 4'b1000;
                        else
                            reg_write = 0;
                    end

                    3'b010: alu_control = 4'b0111;
                    3'b011: alu_control = 4'b1001;

                    default: reg_write = 0;
                endcase
            end

            // LOAD: LB, LH, LW, LBU, LHU
            7'b0000011: begin
                case (funct3)
                    3'b000, 3'b001, 3'b010,
                    3'b100, 3'b101: begin
                        reg_write = 1;
                        mem_read = 1;
                        mem_to_reg = 1;
                        alu_src = 1;
                    end

                    default: begin
                    end
                endcase
            end

            // STORE: SB, SH, SW
            7'b0100011: begin
                case (funct3)
                    3'b000, 3'b001, 3'b010: begin
                        mem_write = 1;
                        alu_src = 1;
                    end

                    default: begin
                    end
                endcase
            end

            // BRANCH
            7'b1100011: begin
                branch = 1;
                alu_control = 4'b0001;
            end

            // JAL
            7'b1101111: begin
                reg_write = 1;
                jump = 1;
            end

            // JALR
            7'b1100111: begin
                if (funct3 == 3'b000) begin
                    reg_write = 1;
                    jump = 1;
                    alu_src = 1;
                end
            end

            // LUI
            7'b0110111: begin
                reg_write = 1;
                alu_src = 1;
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1;
                alu_src = 1;
            end

            default: begin
            end

        endcase
    end

endmodule
