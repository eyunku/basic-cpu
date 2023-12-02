`include "dff.v"
// VALID AND DIRTYBIT FOR LRU TRACKING

// for each array, we track the valid bits
module ValidArray(
  input clk, rst, next_state, update,
  input [64:0] BlockEnable,
  output curr_state
);
  Cell Valid_cells[64:0](.clk(clk), .rst(rst), .Din(next_state), .WriteEnable(update), .Enable(BlockEnable), .Dout(curr_state));
endmodule

// tracks eviction policy of both arrays simultaneously and has LRU logic
// 0 -> way1, 1 -> way2 for which way was used in the input
module LRUArray(
  input clk, rst, lru_next, wen, 
  input [64:0] BlockEnable,
  output lru_out
);
  Cell dirtyarray_1[64:0](.clk(clk), .rst(rst), .Din(lru_next), .WriteEnable(wen), .Enable(BlockEnable), .Dout(~lru_out));
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
// offset: 2 offset bits
// set: 64 sets = 2^6 sets, so 6 set bits
// tag: 16 - 6 - 2 = 8 tag bits
module addr_tag_decode(
	input [15:0] address,
  	output [7:0] tag_out,
  	output [5:0] set_out,
	output [1:0] offset_out,
	output [63:0] set_onehot
);
  	assign tag_out = address[15:8];
  	assign set_out = address[7:2];
  	assign offset_out = address[1:0];

	encode_set_6_128(.set_str(set_out), .set_onehot(set_onehot));
endmodule

// for finding where in the dataarray we are
module encode_set_6_128(
	input [5:0] set_str,
	output [63:0] set_onehot
);
  	wire b1;
	wire [32:0] b33;
	wire [48:0] b49;
	wire [56:0] b57;
	wire [60:0] b61;
	wire [62:0] b63;

  	assign b1 = 1'b1;
	assign b33 = set_str[5] ? {b1, 32'b0} : {32'b0, b1};
	assign b49 = set_str[4] ? {b33, 16'b0} : {16'b0, b33};
	assign b57 = set_str[3] ? {b49, 8'b0} : {8'b0, b49};
	assign b61 = set_str[2] ? {b57, 4'b0} : {4'b0, b57};
	assign b63 = set_str[1] ? {b61, 2'b0} : {2'b0, b61};
	assign set_onehot = set_str[0] ? {b63, 1'b0} : {1'b0, b63};
endmodule
