`include "dff.v"

//Tag Array of 64  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
// WriteEnable is 1 to set tag bits after data-array is done filling, 0 otherwise

module MetaDataArray(input clk, input rst, input [6:0] DataIn, input Write, input [63:0] BlockEnable, output [7:0] DataOut, output CacheHit, output [1:0] lru_sig);
	MBlock Mblk[63:0](.clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .Dout(DataOut), .CacheHit(CacheHit), .lru_sig(lru_sig));
endmodule

module MBlock( input clk,  input rst, input [6:0] Din, input WriteEnable, input Enable, output [7:0] Dout, output CacheHit, output [1:0] lru_sig);
	wire [6:0] t1;
	wire [6:0] t2;
	wire h1 = (t1 === 7'bz) ? 1'b0 : (t1 == Din);
	wire h2 = (t2 === 7'bz) ? 1'b0 : (t2 == Din);

	// lru wires
	wire lru1;
	wire lru2;
	assign lru_sig = {lru1, ~lru1};

	// assign hit and output
	assign CacheHit = (h1 | h2);
	assign Dout = h1 ? {lru_sig[0],t1} : {lru_sig[1], t2};

	// 2 blocks for 2 way set associative
	MCell mcw1[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(t1[6:0]));
	MCell mcw2[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(t2[6:0]));

	// lru bit
	LRUCell lc1(.clk(clk), .rst(rst), .Din(h1), .WriteEnable(CacheHit), .Enable(Enable), .Dout(lru1));
	LRUCell lc2(.clk(clk), .rst(rst), .Din(h2), .WriteEnable(CacheHit), .Enable(Enable), .Dout(lru2));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q : 1'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

module LRUCell(
	input clk, rst, Din, WriteEnable, Enable,
	output Dout
);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q : 1'bz;
	dff dfflru(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
