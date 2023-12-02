// extra bits to track alongside metadata-array and data-array

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
