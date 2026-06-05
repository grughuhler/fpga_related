# Makefile for Icarus Verilog Simulation

# Output executable name
TARGET = tb_fp_top

# Source files (relative to this directory)
SRC_DIR = ../src
SRCS = \
    $(SRC_DIR)/fp_top.sv \
    $(SRC_DIR)/spi_target.sv \
    $(SRC_DIR)/fp_math_core.sv \
    mock_gowin_ips.sv \
    tb_fp_top.sv

# Compiler and flags
CC = iverilog
CFLAGS = -g2012

# Default target: compile and run
all: build run

# Build the simulation executable
build: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

# Run the simulation
run: $(TARGET)
	vvp $(TARGET)

# Clean up generated files
clean:
	rm -f $(TARGET) fp_top.vcd

.PHONY: all build run clean
