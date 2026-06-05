# Floating Point Test Project

This project provides a complete hardware/software stack for testing 32-bit floating-point math IP blocks on a Gowin FPGA (Tang Nano 20K), controlled via an SPI interface by a Raspberry Pi Zero.  Its purpose is to test and demonstrate the floating point soft IP blocks that Gowin offers.  These do things like add, subtract, multiply, divide, compare, and compute square roots.  The numbers are standard IEEE 32-bit floats and so are compatible with the C float type on a Raspberri Pi (and other computers).

See YouTube video: (XXX not there yet XXX)

This README focuses on the FPGA SystemVerilog implementation and simulation. For information on building and running the Raspberry Pi C program, please see the [c_code/README.md](c_code/README.md). For detailed SPI register mappings and the hardware programming model, see [programming_model.md](programming_model.md) and [spec.txt](spec.txt).

## Gowin IDE

The Tang Nano 20K FPGA code is built using the Gowin IDE available for free from the Gowin Semiconductor website.  You must have the professional version of the Gowin EDA Tools IDE (rather than the educational version) if you want to use the IDE's IP generation tool to generate instances of the blocks.  Both the pro and educational versions are free, but you must request a license from Gowin to use the pro version.  Getting access to more soft IP blocks is one of the main advantages of the pro version.

I believe you can build this project using the educational version because I included the key (encrypted?) output files from the IP generator, but you will definitely want the pro version to actually work with these IP blocks.

To build, just open the project file using the Gowin project file for the FPGA on the Tang Nano 20K.  Then, build and flash normally.  See other getting started videos for help with that.

The soft floating point blocks are expensive in terms of FPGA resources.  This project uses most of them so it is probably far too large to work on a Tang Nano 9K.  The division, sqrt, and natural logarithm blocks are particularly costly.  If you removed these three, there is a good chance the project would fit on a 9K.

## Use of AI

Most of the C and FPGA code was created using Google's Gemini AI via antigravity.  This worked very well.  The AI made zero initial mistakes based on the prompt in spec.txt.  I also provided it with PDF's of the block user manuals and with a text file showing example floating point block instantiations.  At the last minute, I prompted the AI to create and run tests using iverilog on Linux.  It created the needed testbench without any trouble.  I have not reviewed the testbench, though.

The development productivity enhancement provided by AI continues to astound me.

I added a couple of features to the code myself later.

The AI wrote most of the following text as well as the (not very good) programming model document.

## Pins Used

For the FPGA, see the cst file.

For the Raspberry Pi Zero, see c_code/fp.c.

## SystemVerilog Source Structure (`src/`)

The FPGA logic is located in the `src/` directory and is broken down into modular SystemVerilog (`.sv`) files:

*   **`fp_top.sv`**: The top-level physical wrapper. It maps the physical FPGA pins (`sysclk`, `MOSI`, `MISO`, `SCLK`, `CS`, `btn1`) to the internal logic and safely inverts the active-high button to generate an internal active-low reset (`rstn`).
*   **`spi_target.sv`**: Handles the asynchronous SPI communication. It uses 2-stage flip-flop synchronizers to safely bring the SPI signals into the 27 MHz system clock domain. It tracks the 5-byte SPI transactions and explicitly handles the serialization/deserialization of **Little-Endian** 32-bit data payloads.
*   **`fp_math_core.sv`**: The core logic and execution state machine. It contains the 4 exposed registers (Control, Arg1, Arg2, Result) and orchestrates the connections to the floating-point math IP blocks. It enforces a strict 4-clock cycle pipeline delay (`DELAY_CYCLES = 4`) after an operation is triggered before latching the result and flagging the `Ready` bit.

### Simulation Files (`testbench/`)
Because the proprietary Gowin Floating-Point IPs cannot be simulated locally using open-source tools without their encrypted models, the project includes a `testbench/` directory with:
*   **`mock_gowin_ips.sv`**: Drop-in mock replacements for the Gowin IPs (`FP_Add_Sub_Top`, `FP_Mult_Top`, `FP_Div_Top`, `FP_Sqrt_Top`, `FP_Comp_Top`, `FP_Natural_Logarithm_Top`). These use integer math and bitwise operations to flawlessly simulate the 4-cycle pipeline latency required to test the state machine.
*   **`tb_fp_top.sv`**: The `iverilog` test bench. It simulates the 27 MHz system clock and bit-bangs the SPI bus to verify the entire system-level operation.

## Running Tests with Icarus Verilog (`iverilog`)

You can run a complete system-level simulation locally using Icarus Verilog.

1.  Navigate to the testbench directory:
    ```bash
    cd testbench
    ```
2.  Build and run the simulation using `make`:
    ```bash
    make
    ```

You can also run individual Makefile targets:
*   `make build` - Only compiles the SystemVerilog files into the `tb_fp_top` executable.
*   `make run` - Executes the simulation using `vvp`.
*   `make clean` - Removes the compiled executable and generated `.vcd` waveform files.

### Interpreting the Results
When you run the simulation, the test bench will output the results of several system-level SPI transactions (Add, Sub, Mult, Div, Sqrt, Comp, Nat Log). 

Because the `mock_gowin_ips.sv` modules use simple integer math instead of IEEE 754 floating-point math (to maintain compatibility with `iverilog`), the input arguments and expected outputs are displayed as raw 32-bit hex values. A successful run will show the computed result matching the expected result for all operations.

Additionally, running the test automatically generates a `fp_top.vcd` file. You can open this file using **GTKWave** to inspect the internal waveforms, state machine transitions, and SPI signal framing.
