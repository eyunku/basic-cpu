module t_fetch ();
  reg bsig;
  reg clk, rst;
  reg [2:0] flag_bits;
  reg [15:0] SrcData1;
  wire [15:0] instruction, pc_curr;

  IF dut (
        //inputs
        .clk(clk),
        .rst(rst),
        .br_sig(bsig),
        .SrcData1(SrcData1),
        .flag_bits(flag_bits),
        //outputs
        .pc_out(pc_curr),
        .instruction(instruction)
        );

  initial begin
    clk = 0;
    #5;
    rst = 1;
    #20;
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and pc %b", instruction, pc_curr);
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and pc %b", instruction, pc_curr);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and pc %b", instruction, pc_curr);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and pc %b", instruction, pc_curr);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule