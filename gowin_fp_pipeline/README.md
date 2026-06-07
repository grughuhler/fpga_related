# Floating Point Multiplication Test Project

This project shows the Gowin 32-bit floating point multiplication soft IP block in action and shows how its operation is pipelined.

It is built with the Gowin EDA IDE and is intended to be run using the Gowin Analysis Oscilloscope tool.  This allows viewing the inputs to and outputs from the IP block on a clock-by-clock basis.  You can see that a new result is produced every clock, but the latency of the operation is 3 clocks.  This means the results from the inputs on clock N appear on clock N + 3.

See YouTube video: (XXX not there yet XXX)

The FPGA image is self-checking.  An LED will light if answers are incorrect.

## Gowin IDE

You must use the professional version of the Gowin IDE to run the IP generation tool to generate floating point soft IPs.  But you can build and run this project using the educational version.  Both versions are free and available from the Gowin website.  But, you must request a (free) license to use the professional verison.

There are project files for both the Tang Nano 9K and 20K boards.  Just use the project file that matches the board you have.

There is a little trick to support both boards using the same source code via conditional compilation.  You can set an include path in the project file.  The 9K and the 20K boards use different include paths.  These allows them to include different versions of global_defs.v.

## Pins Used

No connections to the FPGA board are needed.  The project uses only buttons and LEDs on the board itself.

## Running and viewing results

Load the project onto the FPGA.  Start Gowin Analysis Oscilloscope (GAO) and press button 1 on the board to force a reset.  GAO should stop and show you the floating point multiplication block's inputs and output.
