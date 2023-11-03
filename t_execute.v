// testbench for execute stage

module t_execution ();
    reg clk, rst;
    reg [15:0] SrcData1, SrcData2, sextimm;
    reg [3:0] aluop;
    reg alusrc;
    wire [15:0] aluout;
    wire [2:0] flag_bits;

    EX dut(
        //inputs
        .clk(clk),
        .rst(rst),
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .sextimm(sextimm),
        .aluop(aluop),
        .alusrc(alusrc),
        //outputs
        .aluout(aluout),
        //.err(err),
        .flag_out(flag_bits)
    );


  initial begin
    clk = 0;
    #5;
    rst = 1;
    aluop = 4'b0000; SrcData1 = 16'h000A; SrcData2 = 16'h000A; sextimm = 16'h0001; alusrc = 0; #20;
    rst = 0;
    aluop = 4'b0000; SrcData1 = 16'h000A; SrcData2 = 16'h000A; sextimm = 16'h0001; alusrc = 0; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0;
    aluop = 4'b0000; SrcData1 = 16'h000A; SrcData2 = 16'h000A; sextimm = 16'h0001; alusrc = 1; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0; 
    aluop = 4'b0000; SrcData1 = 16'hFFF6; SrcData2 = 16'h000A; sextimm = 16'h0001; alusrc = 0; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    rst = 0; 
    aluop = 4'b0000; SrcData1 = 16'hFED4; SrcData2 = 16'h000A; sextimm = 16'hFED4; alusrc = 1; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);

    aluop = 4'b0000; SrcData1 = 16'hFED4; SrcData2 = 16'h000A; sextimm = 16'h000A; alusrc = 1; #20;
    $display("registers got is %b and %b", SrcData1, SrcData2);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule