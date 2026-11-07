
module alu (
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_control,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (ALU_control)

            4'b0000: result = A + B; 
            // ADD

            4'b0001: result = A - B;
            // SUB

            4'b0010: result = A & B;
            // AND

            4'b0011: result = A | B;
            // OR

            4'b0100: result = A ^ B;
            // XOR

            4'b0101: result = A << B[4:0];
            // SLL

            4'b0110: result = A >> B[4:0];
            // SRL

            4'b0111: result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            // SLT

            4'b1000: result = $signed(A) >>> B[4:0];
            // SRA

            4'b1001: result = (A < B) ? 32'd1 : 32'd0;
            // SLTU

            default: result = 32'b0;

        endcase
    end

    assign zero = (result == 32'b0);

endmodule
