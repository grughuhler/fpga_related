`timescale 1ns/1ps

module tb_fp_top;

    logic sysclk;
    logic btn1;
    logic SCLK;
    logic CS;
    logic MOSI;
    logic MISO;

    fp_top dut (
        .sysclk(sysclk),
        .btn1(btn1),
        .SCLK(SCLK),
        .CS(CS),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    // 27 MHz clock (~37.037 ns period)
    always #18.5 sysclk = ~sysclk;

    // SPI simulation tasks
    task spi_write(input logic [6:0] addr, input logic [31:0] data);
        integer i;
        logic [7:0] cmd;
        cmd = {1'b1, addr}; // Write = 1
        
        CS = 0;
        #200;
        
        // Send command byte
        for (i=7; i>=0; i--) begin
            MOSI = cmd[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        
        // Send data bytes Little Endian
        // Byte 0
        for (i=7; i>=0; i--) begin
            MOSI = data[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        // Byte 1
        for (i=15; i>=8; i--) begin
            MOSI = data[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        // Byte 2
        for (i=23; i>=16; i--) begin
            MOSI = data[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        // Byte 3
        for (i=31; i>=24; i--) begin
            MOSI = data[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        
        #200;
        CS = 1;
        #1000;
    endtask

    task spi_read(input logic [6:0] addr, output logic [31:0] out_data);
        integer i;
        logic [7:0] cmd;
        logic [31:0] recv;
        cmd = {1'b0, addr}; // Read = 0
        
        CS = 0;
        #200;
        
        // Send command byte
        for (i=7; i>=0; i--) begin
            MOSI = cmd[i];
            #500; SCLK = 1; #500; SCLK = 0;
        end
        
        MOSI = 0; // Dummy
        
        // Read data bytes Little Endian
        // Byte 0
        for (i=7; i>=0; i--) begin
            #500; SCLK = 1; recv[i] = MISO; #500; SCLK = 0;
        end
        // Byte 1
        for (i=15; i>=8; i--) begin
            #500; SCLK = 1; recv[i] = MISO; #500; SCLK = 0;
        end
        // Byte 2
        for (i=23; i>=16; i--) begin
            #500; SCLK = 1; recv[i] = MISO; #500; SCLK = 0;
        end
        // Byte 3
        for (i=31; i>=24; i--) begin
            #500; SCLK = 1; recv[i] = MISO; #500; SCLK = 0;
        end
        
        #200;
        CS = 1;
        #1000;
        
        out_data = recv;
    endtask

    initial begin
        logic [31:0] stat;
        logic [31:0] res;
        
        $dumpfile("fp_top.vcd");
        $dumpvars(0, tb_fp_top);
        
        sysclk = 0;
        SCLK = 0;
        CS = 1;
        MOSI = 0;
        btn1 = 1; // Active high reset
        
        #200;
        btn1 = 0; // release reset
        #200;
        
        // Test 1: Write Arg1, Arg2, Trigger Add
        $display("Testing Add with Little-Endian Hex data...");
        spi_write(7'd1, 32'h11223344); 
        spi_write(7'd2, 32'h00000011); 
        spi_write(7'd0, 32'd1); // Trigger Add
        
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Add Result: %h (Expected 11223355)", res);

        // Test 2: Sub
        $display("Testing Sub...");
        spi_write(7'd1, 32'h11223344); 
        spi_write(7'd2, 32'h00000011); 
        spi_write(7'd0, 32'd2); // Trigger Sub
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Sub Result: %h (Expected 11223333)", res);

        // Test 3: Mult
        $display("Testing Mult...");
        spi_write(7'd1, 32'h00000005); 
        spi_write(7'd2, 32'h00000006); 
        spi_write(7'd0, 32'd3); // Trigger Mult
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Mult Result: %h (Expected 0000001e for 30)", res);

        // Test 4: Div
        $display("Testing Div...");
        spi_write(7'd1, 32'h00000014); // 20
        spi_write(7'd2, 32'h00000004); // 4
        spi_write(7'd0, 32'd4); // Trigger Div
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Div Result: %h (Expected 00000005)", res);

        // Test 5: Sqrt (Mocked as A >> 1)
        $display("Testing Sqrt...");
        spi_write(7'd1, 32'h00000010); // 16
        spi_write(7'd0, 32'd5); // Trigger Sqrt
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Sqrt Result: %h (Expected 00000008)", res);

        // Test 6: Comp
        $display("Testing Comp...");
        spi_write(7'd1, 32'h0000000A); // 10
        spi_write(7'd2, 32'h00000005); // 5
        spi_write(7'd0, 32'd6); // Trigger Comp
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Comp Result: %h (Expected 00000001 for Greater Than)", res);

        // Test 7: Nat Log (Mocked as ~A)
        $display("Testing Nat Log...");
        spi_write(7'd1, 32'h000000FF); // 255
        spi_write(7'd0, 32'd7); // Trigger Nat Log
        stat = 0;
        while ((stat & (1<<30)) == 0) spi_read(7'd0, stat);
        spi_read(7'd3, res);
        $display("Nat Log Result: %h (Expected ffffff00)", res);

        #1000;
        $finish;
    end

endmodule
