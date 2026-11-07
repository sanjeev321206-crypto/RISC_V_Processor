`timescale 1ns/1ps

module immediate_generator_tb;

reg [31:0] instruction;
wire [31:0] immediate;

immediate_generator uut (
    .instruction(instruction),
    .immediate(immediate)
);

initial begin

    // I-type: ADDI x5, x1, 10
    instruction = 32'h00A08293;
    #10;
    $display("I-type immediate: %h", immediate);

    // S-type: SW x5, 8(x1)
    instruction = 32'h0050A423;
    #10;
    $display("S-type immediate: %h", immediate);

    // B-type: BEQ x1, x2, 8
    instruction = 32'h00208463;
    #10;
    $display("B-type immediate: %h", immediate);

    // U-type: LUI x5, 0x12345
    instruction = 32'h123452B7;
    #10;
    $display("U-type immediate: %h", immediate);

    // J-type: JAL x1, 8
    instruction = 32'h008000EF;
    #10;
    $display("J-type immediate: %h", immediate);

    $finish;

end

endmodule