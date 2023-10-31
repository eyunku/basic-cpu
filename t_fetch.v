module test_bench_flag ();
  reg bsig;
  reg clk, rst;
  reg [15:0] SrcData1;
  wire [15:0] instruction, pc_curr;
  wire [3:0] opcode;

  IF dut (
        //inputs
        .clk(clk),
        .rst(rst),
        .br_sig(branch),
        .SrcData1(SrcData1),
        //outputs
        .pc_out(pc_curr),
        .instruction(instruction),
        .opcode(opcode)
        );

  initial begin
    clk = 0;
    #5;
    rst = 1;
    bsig = 0; SrcData1 = 16'h1111; #20;
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and opcode %b", instruction, opcode);
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and opcode %b", instruction, opcode);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and opcode %b", instruction, opcode);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; #20;
    $display("pc: %b", pc_curr);
    $display("instruction got is %b and opcode %b", instruction, opcode);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule