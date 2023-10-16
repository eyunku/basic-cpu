module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
wire b1;
wire [8:0] b9;
wire [12:0] bc;
wire [14:0] be;

assign b1 = 1'b1;
assign b9 = RegId[3] ? {b1, 8'b00000000} : {8'b00000000, b1};
assign bc = RegId[2] ? {b9, 4'b0000} : {4'b0000, b9};
assign be = RegId[1] ? {bc, 2'b00} : {2'b00, bc};
assign Wordline = RegId[0] ? {be, 1'b0} : {1'b0, be};
endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
// temp wires for holding the combined input
wire b1;
wire [8:0] b9;
wire [12:0] bc;
wire [14:0] be;
wire [15:0] bf;

assign b1 = 1'b1;
assign b9 = RegId[3] ? {b1, 8'b00000000} : {8'b00000000, b1};
assign bc = RegId[2] ? {b9, 4'b0000} : {4'b0000, b9};
assign be = RegId[1] ? {bc, 2'b00} : {2'b00, bc};
assign bf = RegId[0] ? {be, 1'b0} : {1'b0, be};
assign Wordline = WriteReg ? bf : 16'b0000000000000000;
endmodule

module BitCell (input clk,  input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);
// based on the decodings we return the contents of the registers needed
wire w1;

dff thisreg (.q(w1), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

assign Bitline1 = ReadEnable1 ? w1: 1'bz;
assign Bitline2 = ReadEnable2 ? w1: 1'bz;
endmodule


// Goku's D-flipflop
module dff (q, d, wen, clk, rst);
output q; //DFF output
input d; //DFF input
input wen; //Write Enable
input clk; //Clock
input rst; //Reset (used synchronously)

reg state;

assign q = state;

always @(posedge clk) begin
state = rst ? 0 : (wen ? d : state);
end
endmodule


module Register (input clk,  input rst, input [15:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);
BitCell b1(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
BitCell b2(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
BitCell b3(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
BitCell b4(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
BitCell b5(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
BitCell b6(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
BitCell b7(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
BitCell b8(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
BitCell b9(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
BitCell b10(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
BitCell b11(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
BitCell b12(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
BitCell b13(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
BitCell b14(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
BitCell b15(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
BitCell b16(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
endmodule

module Register0 (input ReadEnable1, input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);
  assign Bitline1 = ReadEnable1 ? 16'b0 : 16'bz;
  assign Bitline2 = ReadEnable2 ? 16'b0 : 16'bz;
endmodule

module RegisterFile(input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);
// decode instruction input
wire [15:0] w_ren1, w_ren2, w_wen;
ReadDecoder_4_16 decode_ren1 (.RegId(SrcReg1), .Wordline(w_ren1));
ReadDecoder_4_16 decode_ren2 (.RegId(SrcReg2), .Wordline(w_ren2));
WriteDecoder_4_16 decode_wen (.RegId(Dstreg), .WriteReg(WriteReg), .Wordline(w_wen));

// enable options are already set in the previous wires, so just reference them for the 16 registers now
// has 16 registers these are the output wires

Register0 r0 (.ReadEnable1(w_ren1[0]), .ReadEnable2(w_ren2[0]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r1 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[1]), .ReadEnable2(w_ren2[1]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r2 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[2]), .ReadEnable2(w_ren2[2]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r3 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[3]), .ReadEnable2(w_ren2[3]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r4 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[4]), .ReadEnable2(w_ren2[4]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r5 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[5]), .ReadEnable2(w_ren2[5]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r6 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[6]), .ReadEnable2(w_ren2[6]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r7 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[7]), .ReadEnable2(w_ren2[7]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r8 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[8]), .ReadEnable2(w_ren2[8]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register r9 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[9]), .ReadEnable2(w_ren2[9]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register ra (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[10]), .ReadEnable2(w_ren2[10]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register rb (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[11]), .ReadEnable2(w_ren2[11]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register rc (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[12]), .ReadEnable2(w_ren2[12]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register rd (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[13]), .ReadEnable2(w_ren2[13]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register re (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[14]), .ReadEnable2(w_ren2[14]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register rf (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WriteReg), .ReadEnable1(w_ren1[15]), .ReadEnable2(w_ren2[15]), .Bitline1(SrcData1), .Bitline2(SrcData2));
endmodule

// flag register containing 3 bitcell registers
module flag_reg (input clk, input rst, input n_write, input v_write, input z_write, input n_in, input v_in, input z_in, output n_out, output v_out, output z_out);
  wire n_read;
  wire v_read;
  wire z_read;
  BitCell bitn (.clk(clk), .rst(rst), .D(n_in), .WriteEnable(n_write), .ReadEnable1(1), .ReadEnable2(0), .Bitline1(n_read), .Bitline2());
  BitCell bitv (.clk(clk), .rst(rst), .D(v_in), .WriteEnable(v_write), .ReadEnable1(1), .ReadEnable2(0), .Bitline1(v_read), .Bitline2());
  BitCell bitz (.clk(clk), .rst(rst), .D(z_in), .WriteEnable(z_write), .ReadEnable1(1), .ReadEnable2(0), .Bitline1(z_read), .Bitline2());
  
  assign n_out = n_read;
  assign v_out = v_read;
  assign z_out = z_read;
endmodule

module test_bench_flag ();
reg nw, vw, zw, nn, vn, zn, clk, rst;
wire n, v, z;

flag_reg dut (.clk(clk), .rst(rst), .n_write(nw), .v_write(vw), .z_write(zw), .n_in(nn), .v_in(vn), .z_in(zn), .n_out(n), .v_out(v), .z_out(z));

initial begin
clk = 0;
#5;
rst = 1;
nw = 1; vw = 1; zw = 1; nn = 1; vn = 1; zn = 1; #20;
rst = 0;
nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z);
rst = 0;
nw = 0; vw = 1; zw = 0; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z);
rst = 0; 
nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 0; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z);
rst = 0; 
nw = 1; vw = 0; zw = 0; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z);
$stop;
end

always begin
#10;
clk = ~clk;
end

endmodule


module test_bench_RF ();
reg clk, rst, wr;
reg [3:0] sr1, sr2, dr;
reg [15:0] dd;
wire [15:0] sd1, sd2;

RegisterFile dut (.clk(clk), .rst(rst), .SrcReg1(sr1), .SrcReg2(sr2), .DstReg(dr), .WriteReg(wr), .DstData(dd), .SrcData1(sd1), .SrcData2(sd2));

initial begin
clk = 0;
#5;
rst = 1; sr1 = 4'hA; sr2 = 4'hA; #20;
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'hFACE; #20;
$display("first write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'h1111; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'hFACE; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'h0; sr2 = 4'hA; wr = 1; dr = 4'h0; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'h0; sr2 = 4'h0; wr = 0; dr = 4'h0; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
$stop;
end

always begin
#10;
clk = ~clk;
end

endmodule
