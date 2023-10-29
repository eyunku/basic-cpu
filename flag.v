// flag.v

// flag register containing 3 bitcell registers
module flag_reg (input clk, input rst, input [2:0] write, input [2:0] in, output [2:0] flag_out);
  wire n_read;
  wire v_read;
  wire z_read;

  dff n (.q(n_read), .d(in[2]), .wen(write[2]), .clk(clk), .rst(rst));
  dff v (.q(v_read), .d(in[1]), .wen(write[1]), .clk(clk), .rst(rst));
  dff z (.q(z_read), .d(in[0]), .wen(write[0]), .clk(clk), .rst(rst));
  
  assign flag_out = {n_read, v_read, z_read};
endmodule
