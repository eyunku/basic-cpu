`include "dff.v"
// DIRTYBIT FOR LRU TRACKING

// tracks eviction policy of both arrays simultaneously and has LRU logic
// mru: 0 -> way1: 1 -> way2 for which way was used in the input
// lru: 0 -> way1 : 1 -> way2 is the least recently used block
// the dff tracks which way is lru
module LRUArray(
	input clk, rst, mru, wen, 
	input [64:0] BlockEnable,
	output lru
);
	Cell dirtyarray_1[64:0](.clk(clk), .rst(rst), .Din(~mru), .WriteEnable(wen), .Enable(BlockEnable), .Dout(lru));
endmodule

// general single cell that contains a single bit
module Cell(
	input clk, rst, Din, WriteEnable, Enable,
	output Dout
);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule


// DECODER AND ENCODER LOGIC

// decoder for tag and set bits
// an address comes in and is split into the tag and set bits
// offset: 3 offset bits
// set: 64 sets = 2^6 sets, so 6 set bits
// tag: 16 - 6 - 3 = 7 tag bits
module addr_tag_decode(
	input [15:0] address,
  	output [6:0] tag_out,
	output [7:0] offset_onehot,
	output [63:0] set_onehot
);
  	assign tag_out = address[15:9];
  	wire [5:0] set_out = address[8:3];
  	wire [2:0] offset_out = address[2:0];

	onehot_3_8 encoder_offset(.b3_str(offset_out), .b8_onehot(offset_onehot));
	onehot_6_64 encoder_set(.b6_str(set_out), .b64_onehot(set_onehot));
endmodule

// for finding where in the dataarray we are
module onehot_6_64(
	input [5:0] b6_str,
	output [63:0] b64_onehot
);
  	wire b1;
	wire [32:0] b33;
	wire [48:0] b49;
	wire [56:0] b57;
	wire [60:0] b61;
	wire [62:0] b63;

  	assign b1 = 1'b1;
	assign b33 = b6_str[5] ? {b1, 32'b0} : {32'b0, b1};
	assign b49 = b6_str[4] ? {b33, 16'b0} : {16'b0, b33};
	assign b57 = b6_str[3] ? {b49, 8'b0} : {8'b0, b49};
	assign b61 = b6_str[2] ? {b57, 4'b0} : {4'b0, b57};
	assign b63 = b6_str[1] ? {b61, 2'b0} : {2'b0, b61};
	assign b64_onehot = b6_str[0] ? {b63, 1'b0} : {1'b0, b63};
endmodule

// general module for creating a onehot of a 3 bit string
module onehot_3_8(
	input [2:0] b3_str,
	output [7:0] b8_onehot
);
  	wire b1;
	wire [4:0] b5;
	wire [6:0] b7;

  	assign b1 = 1'b1;
	assign b5 = b3_str[2] ? {b1, 4'b0} : {4'b0, b1};
	assign b7 = b3_str[1] ? {b5, 2'b0} : {2'b0, b5};
	assign b8_onehot = b3_str[0] ? {b7, 1'b0} : {1'b0, b7};
endmodule
