
module program_counter (
    input clk,
    input reset,
    input pc_enable,
    input [31:0] next_pc_value,
    output reg [31:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0;
        else if (pc_enable)
            pc <= next_pc_value;
    end

endmodule
