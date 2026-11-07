
`timescale 1ns/1ps

module alu_tb;

    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALU_control;

    wire [31:0] result;
    wire zero;

    integer errors;

    alu uut (
        .A(A),
        .B(B),
        .ALU_control(ALU_control),
        .result(result),
        .zero(zero)
    );

    initial begin
        errors = 0;

        $display("\n========== ALU EXTENDED VERIFICATION ==========");

        // Test 1: SRA - Arithmetic Right Shift
        A = 32'hFFFFFFF0;
        B = 32'd2;
        ALU_control = 4'b1000;
        #10;
        $display("SRA  Result = %h | Expected = FFFFFFFC", result);
        if (result !== 32'hFFFFFFFC) errors = errors + 1;

        // Test 2: SLTU - Unsigned Less Than
        A = 32'd10;
        B = 32'd20;
        ALU_control = 4'b1001;
        #10;
        $display("SLTU Result = %h | Expected = 00000001", result);
        if (result !== 32'd1) errors = errors + 1;

        // Test 3: SLTU - Unsigned Greater Than
        A = 32'd30;
        B = 32'd20;
        ALU_control = 4'b1001;
        #10;
        $display("SLTU Result = %h | Expected = 00000000", result);
        if (result !== 32'd0) errors = errors + 1;

        // Test 4: SRL - Logical Right Shift
        A = 32'hFFFFFFF0;
        B = 32'd2;
        ALU_control = 4'b0110;
        #10;
        $display("SRL  Result = %h | Expected = 3FFFFFFC", result);
        if (result !== 32'h3FFFFFFC) errors = errors + 1;

        // Test 5: SLL - Logical Left Shift
        A = 32'd3;
        B = 32'd2;
        ALU_control = 4'b0101;
        #10;
        $display("SLL  Result = %h | Expected = 0000000C", result);
        if (result !== 32'd12) errors = errors + 1;

        // Final result
        $display("\nErrors detected: %0d", errors);

        if (errors == 0)
            $display("ALL EXTENDED ALU TESTS PASSED!");
        else
            $display("ALU VERIFICATION FAILED!");

        $display("==============================================");

        $finish;
    end

endmodule
