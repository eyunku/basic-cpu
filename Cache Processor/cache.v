//cache.v, organizing my thoughts for the cache

// Cache is 2048B in size, 2-way set-associative, with cache blocks of 16B each
// data array would have 128 lines in total, each being 16 bytes wide:
// The meta-data array would have 128 total entries composed of 64 sets with 2 ways each
//
// LRU dirty bit

// decoder for tag and set bits
// an address comes in and is split into the tag and set bits
// offset: 2 offset bits
// set: 64 sets = 2^6 sets, so 6 set bits
// tag: 16 - 6 - 2 = 8 tag bits
module addr_tag_decode (
  input [15:0] address,
  output [7:0] tag_out,
  output [5:0] set_out,
  output [1:0] offset_out
);
  assign tag_out = address[15:8];
  assign set_out = address[7:2];
  assign offset_out = address[1:0];
endmodule

// for finding where in the dataarray we are
module encode_set_6_128(
  input set_str;
  output set_onehot;
);
  wire b1;
wire [8:0] b9;
wire [12:0] bc;
wire [14:0] be;

assign b1 = 1'b1;
assign b9 = set_str[3] ? {b1, 8'b00000000} : {8'b00000000, b1};
assign bc = set_str[2] ? {b9, 4'b0000} : {4'b0000, b9};
assign be = set_str[1] ? {bc, 2'b00} : {2'b00, bc};
assign set_onehot = RegId[0] ? {be, 1'b0} : {1'b0, be};
endmodule



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
  
  
  
  addr_tag_decode decoder(
    .address(address),
    .tag_out(tag_str),
    .set_out(set_str),
    .offset_out(offset_str)
  );

  // the metadata array
  MetaDataArray tag_arr(
    .clk(clk),
    .rst(rst),
    .DataIn(tag_str),
    .Write(wen),
    .BlockEnable(set_str),  // 128 bit encoded one-hot
    .DataOut(tag_compare) // data out is 8 bit how?? isnt this being compared to the tag bits?
  );

  // the actual data_arr
  DataArray data_arr(
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
