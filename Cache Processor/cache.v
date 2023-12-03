`include "array_helpers.v"
`include "metadata_array.v"
`include "data_array.v"
//cache.v, organizing my thoughts for the cache

// Cache is 2048B in size, 2-way set-associative, with cache blocks of 16B each
// data array would have 128 lines in total, each being 16 bytes wide:
// The meta-data array would have 128 total entries composed of 64 sets with 2 ways each
//
// LRU dirty bit

// I-cache
// initialize a data-array and a metadata-array
// 
module i_cache (
  input clk, rst,
  input [15:0] address,
  input [15:0] data_in,
  input en, write,
  output [15:0] data_out,
  output cache_miss
);
  // decode/encode wires
  wire [6:0] tag_str;
  wire [7:0] offset_onehot;
  wire [63:0] set_onehot;

  // tags from 2ways
  wire [7:0] tag1;
  wire [7:0] tag2;

  wire lru; // least recently used line
  wire [15:0] data1;
  wire [15:0] data2;
  
  // hit/miss logic
  wire hit1 = (tag_str == tag1[6:0]) & tag1[7];
  wire hit2 = (tag_str == tag2[6:0]) & tag2[7];
  assign cache_miss = ~hit1 & ~hit2; 
  // data out on a hit
  assign data_out = cache_miss ? 1'bz : (hit2 ? data2 : data1);


  addr_tag_decode decoder(
    .address(address),
    .tag_out(tag_str),
    .offset_onehot(offset_onehot),
    .set_onehot(set_onehot)
  );

  // the metadata arrays
  MetaDataArray MDway1(
    .clk(clk),
    .rst(rst),
    .DataIn({1'b1, tag_str}),
    .Write(en & ~lru & cache_miss),
    .BlockEnable(set_onehot),  // 64 bit encoded one-hot
    .DataOut(tag1)
  );
  MetaDataArray MDway2(
    .clk(clk),
    .rst(rst),
    .DataIn({1'b1, tag_str}),
    .Write(en & lru & cache_miss),
    .BlockEnable(set_onehot),  // 64 bit encoded one-hot
    .DataOut(tag2)
  );


  // controlling least recently used and eviction policy
  LRUArray dirtybit(
    .clk(clk),
    .rst(rst),
    .mru(hit2),
    .wen(~cache_miss),
	  .BlockEnable(set_onehot),
	  .lru(lru)
  );
  

  // the actual data_arr
  DataArray Dway1(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(en & ~lru & cache_miss),
    .BlockEnable(set_onehot),
    .WordEnable(offset_onehot),
    .DataOut(data1)
  );
  DataArray Dway2(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(en & lru & cache_miss),
    .BlockEnable(set_onehot),
    .WordEnable(offset_onehot),
    .DataOut(data2)
  );
  
  // logic for eviction policy
endmodule

// D-cache
// initialize a data-array and a metadata-array



// Note that the interaction between the memory and caches should occur at cache block (16-byte) granularity. Considering that the data ports are only 2 bytes wide, this would require a burst of 8 consecutive data transfers.