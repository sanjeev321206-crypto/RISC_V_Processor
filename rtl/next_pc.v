module next_pc (
    input [31:0] pc,
    input [31:0] branch_target,
    input branch_taken,
    output [31:0] next_pc
);

    assign next_pc = branch_taken ? branch_target : pc + 32'd4;

endmodule