`timescale 1ns/1ps

module instruction_memory_tb;

reg [31:0] address;
wire [31:0] instruction;

instruction_memory uut (
    .address(address),
    .instruction(instruction)
);

initial begin

    address = 32'd0;
    #10;
    $display("Address 0: %h", instruction);

    address = 32'd4;
    #10;
    $display("Address 4: %h", instruction);

    address = 32'd8;
    #10;
    $display("Address 8: %h", instruction);

    address = 32'd12;
    #10;
    $display("Address 12: %h", instruction);

    $finish;

end

endmodule