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
  input clk, rst, enable,
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
  wire [6:0] tag_out;

  // data array
  wire [15:0] data1;
  wire [15:0] data2;
  
  // hit/miss logic
  wire lru_sig; // used by data when loading
  wire way; // used by data when we hit: 0 -> way1, 1 -> way2
  wire [63:0] cache_hit;
  assign cache_miss = enable ? (~ (| cache_hit)) : 1'b0;

  // which data way to use for eviction: 0 -> way1, 1 -> way2
  wire dataway = cache_miss ? lru_sig : way;

  // data out on a hit
  assign data_out = (cache_miss | ~enable) ? 16'hzzzz : (dataway ? data2 : data1);

  addr_tag_decode addressdecoder(
    .address(address),
    .tag_out(tag_str),
    .offset_onehot(offset_onehot),
    .set_onehot(set_onehot)
  );
  // assert offset_onehot is onehot
  // assert set_onehot is onehot

  // the metadata arrays
  MetaDataArray MDarray(
    .clk(clk),
    .rst(rst),
    .DataIn({1'b1, tag_str}),
    .Write(load_tag),
    .BlockEnable(set_onehot & {64{enable}}),  // 64 bit encoded one-hot
    .DataOut(tag_out),
    .CacheHit(cache_hit),
    .lru_sig(lru_sig),
    .way(way)
  );
  

  // the actual data_arrs
  DataArray Dway1(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(load_data),
    .BlockEnable(set_onehot & {64{~dataway}} & {64{enable}}),
    .WordEnable(offset_onehot),
    .DataOut(data1)
  );

  DataArray Dway2(
    .clk(clk),
    .rst(rst),
    .DataIn(data_in),
    .Write(load_data),
    .BlockEnable(set_onehot & {64{dataway}} & {64{enable}}),
    .WordEnable(offset_onehot),
    .DataOut(data2)
  );
  
  // logic for eviction policy
endmodule



// D-cache
// initialize a data-array and a metadata-array
module d_cache (
  input clk, rst, enable,
  input [15:0] address, // address to be decoded
  input [15:0] data_in, // data coming in for cache loading
  input [15:0] data_write, // data coming in from cache write
  input write,
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
  wire [6:0] tag_out;

  // data array
  wire [15:0] data_load;
  wire [15:0] data1;
  wire [15:0] data2;
  
  // hit/miss logic
  wire lru_sig; // used by data when loading
  wire way; // used by data when we hit: 0 -> way1, 1 -> way2
  wire [63:0] cache_hit;
  assign cache_miss = enable ? (~(| cache_hit)) : 1'b0;

  // which data way to use: 0 -> way1, 1 -> way2
  // TODO dataway can be z's
  wire dataway = cache_miss ? lru_sig : way;

  // data out on a hit
  assign data_out = (cache_miss | ~enable) ? 16'hzzzz : (dataway ? data2 : data1);

  addr_tag_decode addressdecoder(
    .address(address),
    .tag_out(tag_str),
    .offset_onehot(offset_onehot),
    .set_onehot(set_onehot)
  );
  // assert offset_onehot is onehot
  // assert set_onehot is onehot

  // the metadata arrays
  MetaDataArray MDarray(
    .clk(clk),
    .rst(rst),
    .DataIn({1'b1, tag_str}),
    .Write(load_tag),
    .BlockEnable(set_onehot & {64{enable}}),  // 64 bit encoded one-hot
    .DataOut(tag_out),
    .CacheHit(cache_hit),
    .lru_sig(lru_sig),
    .way(way)
  );
  

  // the actual data_arrs
  assign data_load = (write & ~cache_miss) ? data_write : data_in;
  DataArray Dway1(
    .clk(clk),
    .rst(rst),
    .DataIn(data_load),
    .Write(load_data | (write & ~cache_miss)),
    .BlockEnable(set_onehot & {64{~dataway}} & {64{enable}}),
    .WordEnable(offset_onehot),
    .DataOut(data1)
  );

  DataArray Dway2(
    .clk(clk),
    .rst(rst),
    .DataIn(data_load),
    .Write(load_data | (write & ~cache_miss)),
    .BlockEnable(set_onehot & {64{dataway}} & {64{enable}}),
    .WordEnable(offset_onehot),
    .DataOut(data2)
  );
  
  // logic for eviction policy
endmodule


// Note that the interaction between the memory and caches should occur at cache block (16-byte) granularity. Considering that the data ports are only 2 bytes wide, this would require a burst of 8 consecutive data transfers.