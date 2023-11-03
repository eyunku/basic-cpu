// special pc 16bit register

module pc_16bit_reg (clk, rst, pc_in, pc_out);
    // input
    input clk, rst;
    input [15:0] pc_in;
    // output
    output [15:0] pc_out;

    wire [15:0] hanging;
  
    dff b0 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b1 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b2 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b3 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b4 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b5 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b6 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b7 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b8 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff b9 (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bA (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bB (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bC (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bD (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bE (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
    dff bF (.q(pc_out[0]), .d(pc_in[0]), .wen(1), .clk(clk), .rst(rst));
  
  endmodule // rewrite this
