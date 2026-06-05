module FP_Add_Sub_Top (
    input  logic clk,
    input  logic rstn,
    input  logic op,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    output logic [31:0] result
);
    logic [31:0] pipe [3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) pipe[i] <= 0;
            result <= 0;
        end else begin
            pipe[0] <= (op == 0) ? (data_a + data_b) : (data_a - data_b);
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            result  <= pipe[2]; // 4 cycles total
        end
    end
endmodule

module FP_Mult_Top (
    input  logic clk,
    input  logic rstn,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    output logic [31:0] result
);
    logic [31:0] pipe [3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) pipe[i] <= 0;
            result <= 0;
        end else begin
            pipe[0] <= data_a * data_b;
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            result  <= pipe[2];
        end
    end
endmodule

module FP_Div_Top (
    input  logic clk,
    input  logic rstn,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    output logic [31:0] result
);
    logic [31:0] pipe [3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) pipe[i] <= 0;
            result <= 0;
        end else begin
            pipe[0] <= (data_b != 0) ? (data_a / data_b) : 0;
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            result  <= pipe[2];
        end
    end
endmodule

module FP_Sqrt_Top (
    input  logic clk,
    input  logic rstn,
    input  logic [31:0] data_a,
    output logic [31:0] result
);
    logic [31:0] pipe [3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) pipe[i] <= 0;
            result <= 0;
        end else begin
            pipe[0] <= data_a >> 1; // mock sqrt
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            result  <= pipe[2];
        end
    end
endmodule

module FP_Comp_Top (
    input  logic clk,
    input  logic rstn,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    output logic aeb,
    output logic agb
);
    logic aeb_pipe[3:0];
    logic agb_pipe[3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) begin
                aeb_pipe[i] <= 0;
                agb_pipe[i] <= 0;
            end
            aeb <= 0;
            agb <= 0;
        end else begin
            aeb_pipe[0] <= (data_a == data_b);
            agb_pipe[0] <= (data_a > data_b);
            aeb_pipe[1] <= aeb_pipe[0];
            agb_pipe[1] <= agb_pipe[0];
            aeb_pipe[2] <= aeb_pipe[1];
            agb_pipe[2] <= agb_pipe[1];
            aeb <= aeb_pipe[2];
            agb <= agb_pipe[2];
        end
    end
endmodule

module FP_Natural_Logarithm_Top (
    input  logic clk,
    input  logic rstn,
    input  logic ce,
    input  logic [31:0] data,
    output logic [31:0] result,
    output logic nan,
    output logic zero
);
    logic [31:0] pipe [3:0];
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for(int i=0; i<4; i++) pipe[i] <= 0;
            result <= 0;
            nan <= 0;
            zero <= 0;
        end else if (ce) begin
            // Mock Natural Logarithm: bitwise inversion for testing SPI pipeline
            pipe[0] <= ~data;
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
            result  <= pipe[2];
            nan <= 0;
            zero <= (data == 0);
        end
    end
endmodule
