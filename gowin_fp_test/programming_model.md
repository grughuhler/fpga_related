# Floating Point Test Project: Programming Model

This document summarizes the hardware/software programming model for interfacing the Raspberry Pi with the FPGA over SPI to perform 32-bit floating-point operations.

## 1. SPI Interface Configuration

The Raspberry Pi communicates with the FPGA as an SPI controller (master), and the FPGA acts as an SPI target (slave). 

The following hardware configuration is used:
- **Signals:** MOSI, MISO, SCLK, and active-low CS (Chip Select).
- **SPI Mode:** Mode 0 (`CPOL = 0`, `CPHA = 0`).
- **Clock Speed:** SCLK should be configured to 1 MHz - 2 MHz (to allow asynchronous sampling by the FPGA's 27 MHz system clock).
- **Data Endianness:** Little-Endian (Least Significant Byte first).

## 2. SPI Transaction Format

All SPI transactions are exactly 5 bytes in length:
1. **Byte 0 (Command Byte):** 
   - **Bit 7:** Write/Read Flag (`1` = Write, `0` = Read).
   - **Bits 6:0:** Register Address in words (`0`, `1`, `2`, or `3`).
2. **Bytes 1-4 (Data Bytes):**
   - 32 bits of little-endian data.
   - For a Write operation, the Raspberry Pi transmits the data on MOSI.
   - For a Read operation, the Raspberry Pi transmits dummy bytes (`0x00`) on MOSI while simultaneously receiving the register contents on MISO.

## 3. Register Map

The FPGA exposes four 32-bit registers to the Raspberry Pi:

| Word Address | Byte Offset | Register Name | Access | Description |
| :--- | :--- | :--- | :--- | :--- |
| `0` | `0x0` | **Control** | R/W | Status flags and operation trigger. |
| `1` | `0x4` | **Arg1** | R/W | 32-bit floating-point argument 1. |
| `2` | `0x8` | **Arg2** | R/W | 32-bit floating-point argument 2. |
| `3` | `0xC` | **Result** | R/O | 32-bit floating-point result (or comparison code). |

## 4. Control Register Details

The **Control** register (Word 0) contains command triggers and status flags.

| Bits | Field | Description |
| :--- | :--- | :--- |
| `31` | **Reset** | Write `1` to safely reset the FPGA logic. |
| `30` | **Ready** | Read `1` when the FPGA is ready for a new operation or an operation has completed. Read `0` when busy. |
| `29:4`| **Reserved** | Unused. Should be written as `0`. |
| `3:0` | **Operation** | The math operation to execute. |

### Operation Codes (Bits 3:0):
- `0x0` - **NOP**: No operation.
- `0x1` - **ADD**: Compute `Arg1 + Arg2`.
- `0x2` - **SUB**: Compute `Arg1 - Arg2`.
- `0x3` - **MULT**: Compute `Arg1 * Arg2`.
- `0x4` - **DIV**: Compute `Arg1 / Arg2`. (Div-by-zero must be prevented by software).
- `0x5` - **SQRT**: Compute `sqrt(Arg1)`. (Negative inputs must be prevented by software).
- `0x6` - **COMP**: Compare `Arg1` and `Arg2`.
- `0x7` - **LN**: Compute `ln(Arg1)`. (Negative or zero inputs must be prevented by software).
- *Others* - Treated as NOP.

## 5. Operation Execution Flow

To perform a calculation, the software must execute the following flow:

1. **Wait for Ready:**
   - Read the Control register until Bit 30 (`Ready`) is `1`.
2. **Write Arguments:**
   - Write the first floating-point operand to **Arg1** (Word 1).
   - If the operation requires two operands, write the second floating-point operand to **Arg2** (Word 2).
3. **Trigger Operation:**
   - Write to the **Control** register with the desired Operation code in bits 3:0. 
   - *Note: Writing a non-zero operation field automatically triggers the execution on the FPGA.*
4. **Wait for Completion:**
   - Read the Control register until Bit 30 (`Ready`) is `1`.
5. **Read Result:**
   - Read the **Result** register (Word 3) to get the final 32-bit floating-point value.

### Comparison Output format
For the **COMP** operation (`0x6`), the 32-bit value in the Result register uses specific integer encodings rather than a floating-point value:
- `0` = Equal
- `1` = Greater Than (`Arg1 > Arg2`)
- `2` = Less Than (`Arg1 < Arg2`)

### FPGA Reset Sequence
To reset the FPGA computation logic without triggering a new math operation, write `0x80000000` to the Control register. This sets the Reset bit (31) to `1` and the Operation bits (3:0) to `NOP`. Wait for the `Ready` bit to become `1` before issuing further commands.
