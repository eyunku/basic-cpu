// module t_pc_reg ();
//   reg clk, rst, pc_write, pc_read;
//   reg [15:0] pc_in;
//   wire [15:0] pc_out;

//   pc_16bit_reg dut (
//     .clk(clk),
//     .rst(rst),
//     .pc_in(pc_in),
//     .pc_out(pc_out)
//   );

//   initial begin
//     clk = 0;
//     #5;
//     rst = 1;
//     pc_in = 16'b0; #20
//     rst = 0;
//     $display("pc_out should be 16'bx: %b", pc_out);
//     pc_in = 16'h1111; #20
//     rst = 0;
//     $display("pc_out should be 16'bz: %b", pc_out);
//     pc_in = 16'h2222; #20
//     rst = 0;
//     $display("pc_out 16'h1111: %b", pc_out);
//   end

//   always begin
//     #10;
//     clk = ~clk;
//   end
// endmodule

`include "register.v"
`include "dff.v"

module test_bench_RF ();
reg clk, rst, WriteReg;
reg [3:0] SrcReg1, SrcReg2, DstReg;
reg [15:0] DstData;
wire [15:0] SrcData1, SrcData2;

RegisterFile dut (
  .clk(clk), 
  .rst(rst), 
  .SrcReg1(SrcReg1), 
  .SrcReg2(SrcReg2), 
  .DstReg(DstReg), 
  .WriteReg(WriteReg), 
  .DstData(DstData), 
  .SrcData1(SrcData1), 
  .SrcData2(SrcData2)
);

initial begin
  clk = 1;
  rst = 1; #10
  // after we write reg1, read reg1 and reg2
  rst = 0; SrcReg1 = 4'h1; SrcReg2 = 4'h2; WriteReg = 1; DstReg = 4'h1; DstData = 16'h1; #10;
  $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2); #10;
  $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2); #10;
  $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2);
  // rst = 0; SrcReg1 = 4'h1; SrcReg2 = 4'h2; WriteReg = 1; DstReg = 4'h2; DstData = 16'h2; #20;
  // $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2);
  // rst = 0; SrcReg1 = 4'h1; SrcReg2 = 4'h2; WriteReg = 0; DstReg = 4'h3; DstData = 16'h3; #20;
  // $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2);
  // rst = 0; SrcReg1 = 4'h1; SrcReg2 = 4'h2; WriteReg = 0; DstReg = 4'h2; DstData = 16'h4; #20;
  // $display("DstData: %h DstReg: %h SrcData1: %h SrcData2: %h", DstData, DstReg, SrcData1, SrcData2);

  // rst = 1; sr1 = 4'hA; sr2 = 4'hA; #20;
  // rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'hFACE; #20;
  // $display("first write and read output is %b and %b", sd1, sd2);
  // rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'h1111; #20;
  // $display("second write and read output is %b and %b", sd1, sd2);
  // rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'hFACE; #20;
  // $display("second write and read output is %b and %b", sd1, sd2);
  // rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'h2222; #20;
  // $display("second write and read output is %b and %b", sd1, sd2);
  // rst = 0; sr1 = 4'h0; sr2 = 4'hA; wr = 1; dr = 4'h0; dd = 16'h2222; #20;
  // $display("second write and read output is %b and %b", sd1, sd2);
  // rst = 0; sr1 = 4'h0; sr2 = 4'h0; wr = 0; dr = 4'h0; dd = 16'h2222; #20;
  // $display("second write and read output is %b and %b", sd1, sd2);

  $stop;
end

always begin
  #10;
  clk = ~clk;
end

endmodule