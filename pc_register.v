// special pc 16bit register

module pc_16bit_reg (clk, rst, freeze_n, pc_in, pc_out);
    // input
    input clk, rst, freeze_n;
    input [15:0] pc_in;
    // output
    output [15:0] pc_out;

    wire [15:0] hanging;
    wire freeze = freeze_n;
  
    dff b0 (.q(pc_out[0]), .d(pc_in[0]), .wen(freeze), .clk(clk), .rst(rst));
    dff b1 (.q(pc_out[1]), .d(pc_in[1]), .wen(freeze), .clk(clk), .rst(rst));
    dff b2 (.q(pc_out[2]), .d(pc_in[2]), .wen(freeze), .clk(clk), .rst(rst));
    dff b3 (.q(pc_out[3]), .d(pc_in[3]), .wen(freeze), .clk(clk), .rst(rst));
    dff b4 (.q(pc_out[4]), .d(pc_in[4]), .wen(freeze), .clk(clk), .rst(rst));
    dff b5 (.q(pc_out[5]), .d(pc_in[5]), .wen(freeze), .clk(clk), .rst(rst));
    dff b6 (.q(pc_out[6]), .d(pc_in[6]), .wen(freeze), .clk(clk), .rst(rst));
    dff b7 (.q(pc_out[7]), .d(pc_in[7]), .wen(freeze), .clk(clk), .rst(rst));
    dff b8 (.q(pc_out[8]), .d(pc_in[8]), .wen(freeze), .clk(clk), .rst(rst));
    dff b9 (.q(pc_out[9]), .d(pc_in[9]), .wen(freeze), .clk(clk), .rst(rst));
    dff bA (.q(pc_out[10]), .d(pc_in[10]), .wen(freeze), .clk(clk), .rst(rst));
    dff bB (.q(pc_out[11]), .d(pc_in[11]), .wen(freeze), .clk(clk), .rst(rst));
    dff bC (.q(pc_out[12]), .d(pc_in[12]), .wen(freeze), .clk(clk), .rst(rst));
    dff bD (.q(pc_out[13]), .d(pc_in[13]), .wen(freeze), .clk(clk), .rst(rst));
    dff bE (.q(pc_out[14]), .d(pc_in[14]), .wen(freeze), .clk(clk), .rst(rst));
    dff bF (.q(pc_out[15]), .d(pc_in[15]), .wen(freeze), .clk(clk), .rst(rst));
  
  endmodule // rewrite this
