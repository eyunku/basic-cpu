module test_bench_flag ();
  reg [2:0], write, in;
  reg clk, rst;
  wire [2:0] nvz;

  flag_reg dut (.clk(clk), .rst(rst), .write(write), .in(in), .flag_out(nvz));

  initial begin
    clk = 0;
    #5;
    rst = 1;
    write = 3'b111; in = 3'b111; #20;
    rst = 0;
    write = 3'b001; in = 3'b111; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0;
    write = 3'b010; in = 3'b111; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0; 
    write = 3'b001; in = 3'b110; #20;
    $display("after setting zero bit, flag is %b", nvz);
    rst = 0; 
    write = 3'b100; in = 3'b111; #20;
    $display("after setting zero bit, flag is %b", nvz);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule