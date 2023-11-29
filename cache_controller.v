`include "dff.v"
/**
* Cache Specifications
* - Data and address ports of cache and memory are 16 bits wide each
* - Cache capacity is 2KB (2048 B), memory is 64KB (65536B), block size is 16B
* - On read/write misses, need to bring correct block from memory to cache
* - A single data transfer between cache and memory is done in block size (16B), data transfer granularity is 2B,
*   will need to sequentially grab 8 chunks of data from memory and insert them word-by-word into cache block
* - Memory access latency is 4 cycles for each 2 byte word
* - Cache is write through, no data should be written back from cache to memory upon eviction (no dirty bit)
* - Cache controller stalls processor on a miss, stall signal is deasserted once entire cache block is brought
*   into the cache
**/

module cache_fill_FSM (
    input clk, rst_n,
    input miss_detected, // active high when tag match logic detects a miss
    input [15:0] miss_address, // address that missed the cache
    input [15:0] memory_data_in, // data returned by memory (after delay)
    input memory_data_valid, // active high indicates valid data returning on memory bus
    output fsm_busy, // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output write_data_array, // write enable to cache data array to signal when filling with memory_data
    output write_tag_array, // write enable to cache tag array to signal when all words are filled in to data array
    output [15:0] memory_address, // address to read from memory
    output [15:0] memory_data_out
);

    wire rst;
    assign rst = ~rst_n;
    // Define different states
    parameter IDLE = 4'h0; // initial state, no miss detected or 
    parameter WAIT_0 = 4'h1; // next state if miss detected, stall for four cycles
    parameter WAIT_1 = 4'h2; 
    parameter WAIT_2 = 4'h3;
    parameter WAIT_3 = 4'h4; // stay at this state until memory_data_valid bit is asserted (received data)

    // Define state and addr register
    wire state_curr, state_next;
    wire [15:0] addr_curr, addr_next;

    assign state_curr = 1'b1;
    assign addr_curr = 16'hFFFF;

    // Pipeline for propagating data, 4 cycles
    wire valid_0, valid_1, valid_pipe_out;
    wire [15:0] addr_0, data_0;
    wire [15:0] addr_1, data_1;
    wire [15:0] addr_pipe_out, data_pipe_out;

    cache_PIPE pipe_0 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .valid_in(memory_data_valid), .addr_in(addr_curr), .data_in(memory_data_in),
        .valid_out(valid_0), .addr_out(addr_0), .data_out(data_0)
    );

    cache_PIPE pipe_1 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .valid_in(valid_0), .addr_in(addr_0), .data_in(data_0),
        .valid_out(valid_1), .addr_out(addr_1), .data_out(data_1)
    );

    cache_PIPE pipe_2 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .valid_in(valid_1), .addr_in(addr_1), .data_in(data_1),
        .valid_out(valid_pipe_out), .addr_out(addr_pipe_out), .data_out(data_pipe_out)
    );

    assign memory_address = addr_pipe_out;
    assign memory_data_out = data_pipe_out;
    assign fsm_busy = state_curr;
    assign write_data_array = valid_pipe_out;
    assign write_tag_array = 1'b1;
endmodule

module cache_PIPE(
        input wen, rst, clk, valid_in,
        input [15:0] addr_in, data_in,
        output valid_out,
        output [15:0] addr_out, data_out
    );
    dff ADDR[15:0] (.q(addr_out[15:0]), .d(addr_in[15:0]), .wen(wen), .clk(clk), .rst(rst));
    dff DATA[15:0] (.q(data_out[15:0]), .d(data_in[15:0]), .wen(wen), .clk(clk), .rst(rst));
    dff VALID (.q(valid_out), .d(valid_in), .wen(wen), .clk(clk), .rst(rst));
endmodule