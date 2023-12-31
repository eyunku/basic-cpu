`include "dff.v"

//Tag Array of 64  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
// WriteEnable is 1 to set tag bits after data-array is done filling, 0 otherwise

module MetaDataArray(
	input clk, rst,
	input [6:0] DataIn,
	input Write,
	input [63:0] BlockEnable,
	output [6:0] DataOut,
	output [63:0] CacheHit,
	output lru_sig,
	output way
	);
	MBlock Mblk[63:0](.clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .Dout(DataOut), .CacheHit(CacheHit), .lru_sig(lru_sig), .way(way));
endmodule

module MBlock(
	input clk, rst,
	input [6:0] Din,
	input WriteEnable,
	input Enable,
	output [6:0] Dout,
	output CacheHit,
	output lru_sig,
	output way
	);

	wire [6:0] t1;
	wire [6:0] t2;
	wire h1 = (t1 === 7'bz) ? 1'b0 : (t1 == Din);
	wire h2 = (t2 === 7'bz) ? 1'b0 : (t2 == Din);
	assign Dout = h1 ? t1 : (h2 ? t2 : 7'bz);

	// assign hit and output
	assign CacheHit = h1 | h2;
	assign way = Enable ? h2 : 1'bz;

	// 2 blocks for 2 way set associative
	MCell mcw1[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable & ~lru_sig), .Enable(Enable), .Dout(t1));
	MCell mcw2[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable & lru_sig), .Enable(Enable), .Dout(t2));

	// lru bit, 0 -> way1 is least recently used, and 1 -> way2 is least recently used
	LRUCell lc1(.clk(clk), .rst(rst), .Din(h1), .WriteEnable(CacheHit), .Enable(Enable), .Dout(lru_sig));
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
	assign Dout = (Enable) ? q : 1'bz;
	dff dfflru(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
