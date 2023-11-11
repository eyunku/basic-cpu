module t_fd_plreg ();
  reg clk, rst, freeze, flush;
  reg [15:0] pc_in, instruction_in;
  wire [15:0] pc_out, instruction_out;

  

  IF_ID_pl_reg dut (
        //inputs
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .flush(flush),
        .instruction_in(instruction_in),
        .pc_in(pc_in),
        .instruction_out(instruction_out),
        .pc_out(pc_out)
        );

  initial begin
    freeze = 0; flush = 0;
    clk = 0;
    #5;
    rst = 1;
    #20;
    rst = 0;
    instruction_in = 16'h0001; pc_in = 16'h0002; #20;
    $display("stall signal recieved is %b and %b", instruction_out, pc_out);

    instruction_in = 16'h0002; pc_in = 16'h0001; #20;
    $display("stall signal recieved is %b and %b", instruction_out, pc_out);

    instruction_in = 16'h0003; pc_in = 16'h0005; #20;
    $display("stall signal recieved is %b and %b", instruction_out, pc_out);

    flush = 1;
    instruction_in = 16'h0004; pc_in = 16'h0006; #20;
    $display("stall signal recieved is %b and %b", instruction_out, pc_out);

    instruction_in = 16'h0005; pc_in = 16'h0007; #20;
    $display("stall signal recieved is %b and %b", instruction_out, pc_out);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule