'include "goku_dff.v"
// flag.v

// flag register containing 3 bitcell registers
module flag_reg (input clk, input rst, input n_write, input v_write, input z_write, input n_in, input v_in, input z_in, output [2:0] flag_out);
  wire n_read;
  wire v_read;
  wire z_read;

  dff n (.q(n_read), .d(n_in), .wen(n_write), .clk(clk), .rst(rst));
  dff v (.q(v_read), .d(v_in), .wen(v_write), .clk(clk), .rst(rst));
  dff z (.q(z_read), .d(z_in), .wen(z_write), .clk(clk), .rst(rst));
  
  assign flag_out = {n_read, v_read, z_read};
endmodule

module test_bench_flag ();
  reg nw, vw, zw, nn, vn, zn, clk, rst;
  wire [2:0] nvz;

  flag_reg dut (.clk(clk), .rst(rst), .n_write(nw), .v_write(vw), .z_write(zw), .n_in(nn), .v_in(vn), .z_in(zn), .flag_out(nvz));

  initial begin
    clk = 0;
    #5;
    rst = 1;
    nw = 1; vw = 1; zw = 1; nn = 1; vn = 1; zn = 1; #20;
    rst = 0;
    nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 1; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0;
    nw = 0; vw = 1; zw = 0; nn = 1; vn = 1; zn = 1; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0; 
    nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 0; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0; 
    nw = 1; vw = 0; zw = 0; nn = 1; vn = 1; zn = 1; #20;
    $display("after setting zero bit, flag is %b", nvz);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule
