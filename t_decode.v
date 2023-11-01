module test_bench_flag ();
    reg clk, rst;
    reg [15:0] SrcData1;
    wire [15:0] instruction, pc_curr;
    wire [3:0] opcode;
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [3:0] aluop;
    wire [1:0] branch;

    ID dut(
        //inputs
        .clk(clk),
        .rst(rst),
        .pc_curr(pc_curr),
        .instruction(instruction),
        //outputs
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .sextimm(sextimm),
        //control signal outputs
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .memenable(memenable), 
        .memwrite(memwrite), 
        .aluop(aluop), 
        .memtoreg(memtoreg), 
        .branch(branch), 
        .alusext(alusext), 
        .pcread(pcread), 
        .rdsrc(rdsrc)
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