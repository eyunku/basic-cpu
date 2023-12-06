`include "array_helpers.v"
`include "metadata_array.v"
`include "data_array.v"
//cache.v, organizing my thoughts for the cache

// Cache is 2048B in size, 2-way set-associative, with cache blocks of 16B each
// data array would have 128 lines in total, each being 16 bytes wide:
// The meta-data array would have 128 total entries composed of 64 sets with 2 ways each
//
// then lru bit[7] and valid bit[6] and then tag[5:0]

// I-cache
// initialize a data-array and a metadata-array
// miss_en bit means, we are populating cache
module i_cache (
  input clk, rst,
  input [15:0] address, // address to be decoded
  input [15:0] data_in, // data coming in for cache loading
  input load_data, //  on when writing to data_array
  input load_tag, // on when writing to metadata_array
  output [15:0] data_out, // returns data on a hit (only valid on hits)
  output cache_miss // incure a miss
);
  // decode/encode wires
  wire [5:0] tag_str;
  wire [7:0] offset_onehot;
  wire [63:0] set_onehot;

  // tags from 2ways
  wire [7:0] tag_out;

  // data array
  wire [15:0] data1;
  wire [15:0] data2;
  
  // hit/miss logic
  wire [2:0] lru_sig;
  wire cache_hit;
  assign cache_miss = ~cache_hit;

  // data out on a hit
  assign data_out = cache_miss ? 1'bz : (lru_sig[1] ? data2 : data1);

  addr_tag_decode addressdecoder(
    .address(address),
    .tag_out(tag_str),
    .offset_onehot(offset_onehot),
    .set_onehot(set_onehot)
  );


  // the metadata arrays
  MetaDataArray MDarray(
    .clk(clk),
    .rst(rst),
    .DataIn({1'b1, tag_str}),
    .Write(load_tag),
    .BlockEnable(set_onehot),  // 64 bit encoded one-hot
    .DataOut(tag_out),
    .CacheHit(cache_hit),
    .lru_sig(lru_sig)
  );
  

  // the actual data_arr
  DataArray Dway1(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(load_data),
    .BlockEnable(set_onehot & {64{~lru_sig[0]}}),
    .WordEnable(offset_onehot),
    .DataOut(data1)
  );

  DataArray Dway2(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(load_data),
    .BlockEnable(set_onehot & {64{~lru_sig[1]}}),
    .WordEnable(offset_onehot),
    .DataOut(data2)
  );
  
  // logic for eviction policy
endmodule

// D-cache
// initialize a data-array and a metadata-array



// Note that the interaction between the memory and caches should occur at cache block (16-byte) granularity. Considering that the data ports are only 2 bytes wide, this would require a burst of 8 consecutive data transfers.