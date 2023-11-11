module t_decode ();
    reg clk, rst;
    reg [15:0] instruction, DstData;
    wire [15:0] SrcData1, SrcData2;
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [3:0] aluop;
    wire [1:0] branch;

    ID dut(
        //inputs
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .DstData(DstData),
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
    instruction = 16'hAAAA; DstData = 16'hFFFF; #20;
    rst = 0;
    instruction = 16'hA151; DstData = 16'hFFFF; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0;
    instruction = 16'hA151; DstData = 16'hFFFF; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0; 
    instruction = 16'h0321; DstData = 16'hFFFF; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0; 
    instruction = 16'h0321; DstData = 16'hFFFF; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule