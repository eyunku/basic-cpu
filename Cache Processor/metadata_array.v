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

	MBlock Mblk[63:0](
		.clk(clk), .rst(rst), 
		.Din(DataIn), 
		.WriteEnable(Write), 
		.Enable(BlockEnable), 
		.Dout(DataOut), 
		.CacheHit(CacheHit), 
		.lru_sig(lru_sig), 
		.way(way)
	);
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
	// t1, t2 => {1 bit valid, 6 bit tag}
	wire [6:0] t1;
	wire [6:0] t2;
	wire h1 = (t1 == Din);
	wire h2 = (t2 == Din);
	assign CacheHit = h1 | h2;  // always a valid bit: 0 or 1

	// lru bit, 0 -> way1 is least recently used, and 1 -> way2 is least recently used
	// lru_inner is always a valid bit: 0 or 1
	wire lru_inner;

	// 2 blocks for 2 way set associative
	// assert: when WriteEnable=1, CacheHit=0, then lru_inner determines which mcw to write
	MCell mcw1[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable & ~lru_inner), .Enable(Enable), .Dout(t1));
	MCell mcw2[6:0](.clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable & lru_inner), .Enable(Enable), .Dout(t2));
	LRUCell lc1(.clk(clk), .rst(rst), .Din(h1), .WriteEnable(CacheHit & ~WriteEnable), .Enable(Enable), .Dout(lru_inner));

	// assign output
	assign Dout = (Enable & ~WriteEnable) ? (h1 ? t1 : (h2 ? t2 : 7'bz)) : 7'bz;
	assign lru_sig = Enable ? lru_inner : 1'bz;
	assign way = Enable ? (CacheHit ? h2 : 1'bz) : 1'bz;
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	// Instead of resolving read enable logic on MCell, can push it up to the block level
	dff dffm(.q(Dout), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

module LRUCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	dff dffm(.q(Dout), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
