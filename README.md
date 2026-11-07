# 32-bit Single-Cycle RISC-V Processor

A 32-bit single-cycle RISC-V processor implemented using **Verilog HDL**, with individual hardware modules, simulation testbenches, and automated regression testing using Icarus Verilog.

## 1. Project Overview

This project implements an educational 32-bit RISC-V processor based on a subset of the RV32I instruction set architecture.

The processor follows a single-cycle architecture, in which instruction fetch, decoding, execution, memory access, and writeback are coordinated within one instruction cycle.

The design is divided into independent Verilog modules to improve readability, modularity, testing, and future development.

The project also includes individual testbenches and an automated regression script to verify the functionality of the implemented modules.

## 2. Features

The processor currently implements the following features:

- 32-bit datapath and program counter.
- Single-cycle processor architecture.
- 32 general-purpose 32-bit registers.
- Register x0 hardwired to zero.
- Instruction fetching and decoding.
- Immediate generation for supported instruction formats.
- Arithmetic and logical operations.
- Shift operations and comparison operations.
- Conditional branching.
- JAL and JALR jump instructions.
- LUI and AUIPC instructions.
- Byte-addressable data memory.
- Little-endian memory organization.
- Byte, halfword, and word load/store operations.
- Active-high asynchronous program counter reset.

## 3. Processor Architecture

The processor consists of the following major functional units:

1. **Program Counter (PC):** Maintains the address of the current instruction.
2. **Instruction Memory:** Supplies instructions using the current PC.
3. **Instruction Decoder:** Extracts opcode, register addresses, and function fields.
4. **Immediate Generator:** Generates sign-extended immediate values.
5. **Control Unit:** Generates control signals based on the decoded instruction.
6. **Register File:** Stores and provides operands from the general-purpose registers.
7. **ALU:** Performs arithmetic, logical, shift, and comparison operations.
8. **Data Memory:** Handles supported load and store operations.
9. **Writeback Logic:** Selects the value written back to the destination register.
10. **Next-PC Logic:** Determines the next instruction address for sequential execution, branches, and jumps.

### Simplified Data Flow

```text
             +------------------+
             |  Program Counter |
             +--------+---------+
                      |
                      v
             +------------------+
             | Instruction      |
             | Memory           |
             +--------+---------+
                      |
                      v
             +------------------+
             | Instruction      |
             | Decoder          |
             +--------+---------+
                      |
          +-----------+-----------+
          |                       |
          v                       v
 +------------------+    +------------------+
 | Immediate        |    | Control Unit     |
 | Generator        |    |                  |
 +------------------+    +------------------+
          |                       |
          +-----------+-----------+
                      |
                      v
             +------------------+
             | Register File    |
             +--------+---------+
                      |
                      v
             +------------------+
             | ALU              |
             +--------+---------+
                      |
             +--------+---------+
             |                  |
             v                  v
      +-------------+    +----------------+
      | Data Memory |    | Writeback      |
      +------+------+    | Selection      |
             |           +--------+-------+
             +--------------------+
                                  |
                                  v
                         Register File
```

The next-PC selection logic handles sequential execution, conditional branches, JAL, and JALR.

## 4. RTL Module Description

The RTL implementation is divided into the following modules:

| Module | Responsibility |
|---|---|
| `riscv_cpu.v` | Top-level processor integration |
| `program_counter.v` | Program counter and reset functionality |
| `instruction_memory.v` | Instruction storage and fetching |
| `instruction_decoder.v` | Instruction field extraction |
| `immediate_generator.v` | Immediate value generation |
| `control_unit.v` | Instruction control signal generation |
| `register_file.v` | General-purpose register storage |
| `alu.v` | Arithmetic and logical operations |
| `alu_mux.v` | ALU second-operand selection |
| `data_memory.v` | Load and store operations |
| `next_pc.v` | Standalone next-PC selection logic |

**Note:** The top-level CPU currently implements its next-PC selection logic directly inside `riscv_cpu.v`. The standalone `next_pc.v` module is maintained and tested separately.

## 5. Instruction Support

The implementation supports a subset of RV32I functionality, including:

### Arithmetic and Logical Operations

- ADD, SUB
- AND, OR, XOR
- SLT, SLTU

### Shift Operations

- SLL
- SRL
- SRA

### Immediate Operations

- ADDI
- ANDI, ORI, XORI
- SLTI, SLTIU
- SLLI, SRLI, SRAI

### Branch Operations

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

### Jump Operations

- JAL
- JALR

### Upper Immediate Operations

- LUI
- AUIPC

### Memory Operations

- LB, LH, LW
- LBU, LHU
- SB, SH, SW

This is a partial implementation and should not be considered a fully RV32I-compliant processor.

## 6. Memory Organization

The data memory is implemented as a byte-addressable memory containing 1024 bytes.

Its main characteristics are:

- 1024 bytes of storage.
- Little-endian byte ordering.
- Byte, halfword, and word accesses.
- Signed and unsigned load operations.
- Store operations for byte, halfword, and word data.
- Bounds checking for memory accesses.
- Unaligned accesses are permitted by the current implementation.

Invalid load accesses return zero, while invalid store accesses are ignored.

These are implementation-specific memory policies. The processor does not currently implement architectural memory-access exceptions or misalignment traps.

## 7. Reset Functionality

The program counter uses an active-high asynchronous reset.

When reset is asserted, the PC is immediately set to address zero.

The reset testbenches verify:

- Initial reset behavior.
- Normal PC advancement.
- PC hold behavior when disabled.
- Runtime reset during execution.
- Resumption of instruction execution after reset.

The register file has simulation-time initialization but does not have a dedicated reset input. Resetting the CPU therefore does not reset the register file or data memory.

## 8. Project Directory Structure

```text
RISC_V_Processor/
│
├── archive/
│   └── riscv_datapath_obsolete.v
│
├── build/
│   └── Generated simulation executables
│
├── docs/
│
├── rtl/
│   ├── alu.v
│   ├── alu_mux.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── immediate_generator.v
│   ├── instruction_decoder.v
│   ├── instruction_memory.v
│   ├── next_pc.v
│   ├── program_counter.v
│   ├── register_file.v
│   └── riscv_cpu.v
│
├── test