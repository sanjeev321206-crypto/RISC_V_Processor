
module instruction_memory (
    input [31:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP

        memory[0] = 32'h00208023; // SB x2, 0(x1)
        memory[1] = 32'h00008183; // LB x3, 0(x1)
        memory[2] = 32'h0000C203; // LBU x4, 0(x1)
        memory[3] = 32'h00209123; // SH x2, 2(x1)
        memory[4] = 32'h00209283; // LH x5, 2(x1)
        memory[5] = 32'h0020D303; // LHU x6, 2(x1)
    end

    assign instruction = memory[address[9:2]];

endmodule
