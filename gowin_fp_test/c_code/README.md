# Floating Point Test Program (`fp`)

This directory contains the Raspberry Pi C program (`fp`) used to interface with the FPGA over SPI to test 32-bit floating-point operations.

## Requirements

1. **Enable SPI on Raspberry Pi:**
   SPI must be enabled on your Raspberry Pi for this program to communicate with the FPGA. 
   - Run `sudo raspi-config`
   - Navigate to **Interface Options** > **SPI** and select `<Yes>` to enable it.
   - Reboot the Raspberry Pi if prompted.
   
2. The program expects the SPI device `/dev/spidev0.0` to be available. If it cannot connect to the SPI device, the program will fall back to a "disconnected mode" allowing you to test the command parser without crashing.

## How to Build

To compile the program, simply run `make` inside this directory:

```bash
make
```

This will generate the `fp` executable.

## Usage

Run the compiled executable:

```bash
./fp
```

You will drop into an interactive prompt (`fp> `) where you can execute the following commands using floating point numbers:
- `add <arg1> <arg2>`
- `sub <arg1> <arg2>`
- `mult <arg1> <arg2>`
- `div <arg1> <arg2>`
- `sqrt <arg1>`
- `ln <arg1>`
- `comp <arg1> <arg2>`
- `reset` (Sends a safe reset signal to the FPGA)
- `exit` or `quit`

*Note: The hardware wiring guide for connecting the Raspberry Pi Zero to the FPGA is documented at the top of the `fp.c` source file.*
