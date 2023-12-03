`include "array-helpers.v"
//cache.v, organizing my thoughts for the cache

// Cache is 2048B in size, 2-way set-associative, with cache blocks of 16B each
// data array would have 128 lines in total, each being 16 bytes wide:
// The meta-data array would have 128 total entries composed of 64 sets with 2 ways each
//
// LRU dirty bit

// I-cache
// initialize a data-array and a metadata-array
module i_cache (
  input clk, rst,
  input [15:0] address,
  input [15:0] data_in,
  input wen,
  output [15:0] data_out,
  output cache_miss // ????
);
  // decode wires
  wire [7:0] tag_str;
  wire [7:0] tag_compare;
  wire [5:0] set_str;
  wire [1:0] offset_str;
  wire [63:0] set_onehot;
  
  
  addr_tag_decode decoder(
    .address(address),
    .tag_out(tag_str),
    .set_out(set_str),
    .offset_out(offset_str),
    .set_onehot(set_onehot)
  );

  // the metadata arrays
  MetaDataArray MDway1(
    .clk(clk),
    .rst(rst),
    .DataIn(tag_str),
    .Write(wen),
    .BlockEnable(set_str),  // 128 bit encoded one-hot
    .DataOut(tag_compare) // data out is 8 bit how?? isnt this being compared to the tag bits?
  );
  MetaDataArray MDway2(
    .clk(clk),
    .rst(rst),
    .DataIn(tag_str),
    .Write(wen),
    .BlockEnable(set_str),  // 128 bit encoded one-hot
    .DataOut(tag_compare) // data out is 8 bit how?? isnt this being compared to the tag bits?
  );

  // for tracking valid block
  ValidArray VAway1(
    .clk(clk),
    .rst(rst),
    .next_state(),
    .update(),
    .BlockEnable(),
    .curr_state()
  );
  ValidArray VAway2(
    .clk(clk),
    .rst(rst),
    .next_state(),
    .update(),
    .BlockEnable(),
    .curr_state()
  );

  

  // the actual data_arr
  DataArray Dway1(
    .clk(clk),
    .rst(rst),
    .DataIn(),
    .Write(), input [127:0] BlockEnable, input [7:0] WordEnable, output [15:0] DataOut
  );
  DataArray Dway2(
    .clk(clk),
    .rst(rst),
    .DataIn(),
    .Write(), input [127:0] BlockEnable, input [7:0] WordEnable, output [15:0] DataOut
  );
  
  cache_miss = ~tag_compare == tag_str;
  // ternary for handelling cache miss
endmodule

// D-cache
// initialize a data-array and a metadata-array



// Note that the interaction between the memory and caches should occur at cache block (16-byte) granularity. Considering that the data ports are only 2 bytes wide, this would require a burst of 8 consecutive data transfers.
