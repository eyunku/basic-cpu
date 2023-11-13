// flag.v

// flag register containing 3 dff registers
module flag_reg (clk, rst, flag_en, in, flag_out);
  // input
  input clk, rst, flag_en;
  input [2:0] in;
  // output
  output [2:0] flag_out;

  dff n (.q(flag_out[2]), .d(in[2]), .wen(flag_en), .clk(clk), .rst(rst));
  dff v (.q(flag_out[1]), .d(in[1]), .wen(flag_en), .clk(clk), .rst(rst));
  dff z (.q(flag_out[0]), .d(in[0]), .wen(flag_en), .clk(clk), .rst(rst));
endmodule
