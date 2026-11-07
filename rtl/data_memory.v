
module data_memory (
    input clk,
    input mem_read,
    input mem_write,
    input [2:0] funct3,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    reg [7:0] memory [0:1023];

    integer i;

    // Determine access size in bytes
    reg [2:0] access_size;

    always @(*) begin
        case (funct3)
            3'b000: access_size = 3'd1; // LB / SB
            3'b001: access_size = 3'd2; // LH / SH
            3'b010: access_size = 3'd4; // LW / SW
            3'b100: access_size = 3'd1; // LBU
            3'b101: access_size = 3'd2; // LHU
            default: access_size = 3'd0;
        endcase
    end

    // Check complete 32-bit address range.
    // Do not allow addresses to wrap around memory.
    wire access_valid =
        (access_size != 0) &&
        (address <= 32'd1023) &&
        ((address + access_size) <= 32'd1024);

    // Initialize memory
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 8'b0;
    end

    // Load operations
    always @(*) begin

        read_data = 32'b0;

        if (mem_read && access_valid) begin

            case (funct3)

                // LB: Load Byte (signed)
                3'b000:
                    read_data = {
                        {24{memory[address][7]}},
                        memory[address]
                    };

                // LH: Load Halfword (signed)
                3'b001:
                    read_data = {
                        {16{memory[address + 32'd1][7]}},
                        memory[address + 32'd1],
                        memory[address]
                    };

                // LW: Load Word
                3'b010:
                    read_data = {
                        memory[address + 32'd3],
                        memory[address + 32'd2],
                        memory[address + 32'd1],
                        memory[address]
                    };

                // LBU: Load Byte (unsigned)
                3'b100:
                    read_data = {
                        24'b0,
                        memory[address]
                    };

                // LHU: Load Halfword (unsigned)
                3'b101:
                    read_data = {
                        16'b0,
                        memory[address + 32'd1],
                        memory[address]
                    };

                default:
                    read_data = 32'b0;

            endcase
        end
    end

    // Store operations
    always @(posedge clk) begin

        if (mem_write && access_valid) begin

            case (funct3)

                // SB: Store Byte
                3'b000:
                    memory[address] <= write_data[7:0];

                // SH: Store Halfword
                3'b001: begin
                    memory[address] <= write_data[7:0];
                    memory[address + 32'd1] <= write_data[15:8];
                end

                // SW: Store Word
                3'b010: begin
                    memory[address] <= write_data[7:0];
                    memory[address + 32'd1] <= write_data[15:8];
                    memory[address + 32'd2] <= write_data[23:16];
                    memory[address + 32'd3] <= write_data[31:24];
                end

                default: begin
                end

            endcase
        end
    end

endmodule
