`timescale 1ns/1ps

module next_pc_tb;

reg [31:0] pc;
reg [31:0] branch_target;
reg branch_taken;

wire [31:0] next_pc_value;

next_pc uut (
    .pc(pc),
    .branch_target(branch_target),
    .branch_taken(branch_taken),
    .next_pc(next_pc_value)
);

initial begin

    pc = 32'd100;
    branch_target = 32'd200;

    // Normal execution
    branch_taken = 0;
    #10;
    $display("Normal execution: %d", next_pc_value);

    // Branch taken
    branch_taken = 1;
    #10;
    $display("Branch taken: %d", next_pc_value);

    $finish;

end

endmodule