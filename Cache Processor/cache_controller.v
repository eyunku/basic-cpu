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
    input clk, rst,
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
    // Define state and addr register
    wire state_curr, done, transition;
    wire [15:0] addr_curr, addr_next;

    // State transition, WAIT/IDLE
    assign transition = (miss_detected & ~state_curr) | done; // TODO, done relies on state_curr, state_curr relies on done implicit (transition)
    dff STATE (.q(state_curr), .d(~state_curr), .wen(transition), .clk(clk), .rst(rst));

    // Current Address for retrieving block
    dff ADDR[15:0] (.q(addr_curr[15:0]), .d(addr_next[15:0]), .wen(1'b1), .clk(clk), .rst(rst));

    // Pipeline to verify incoming data is associated to requested memory address
    wire [15:0] addr_0, addr_1, addr_pipe_out;
    cache_PIPE pipe_0 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .addr_in(addr_curr),
        .addr_out(addr_0)
    );
    cache_PIPE pipe_1 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .addr_in(addr_0),
        .addr_out(addr_1)
    );
    cache_PIPE pipe_2 (
        .wen(state_curr), .rst(rst), .clk(clk), 
        .addr_in(addr_1),
        .addr_out(addr_pipe_out)
    );

    // Checks that last chunk has been handled
    assign done = (addr_pipe_out[3:0] == 4'hE) & (addr_curr[3:0] == 4'hE) & state_curr & memory_data_valid;

    wire [15:0] chunk_next;
    carry_lookahead next_chunk_address (.a(addr_curr), .b(16'h2), .sum(chunk_next), .overflow(), .mode(1'b0));
    assign addr_next = (miss_detected & ~state_curr) ? (miss_address & ~16'hF) : 
                       (memory_data_valid & (addr_pipe_out == addr_curr) & state_curr) ? chunk_next : addr_curr;

    assign memory_address = addr_next;
    assign memory_data_out = memory_data_in;
    assign fsm_busy = (state_curr & ~done) | (miss_detected & ~state_curr);
    assign write_data_array = memory_data_valid & (addr_pipe_out == addr_curr);
    assign write_tag_array = done;
endmodule

module cache_PIPE(
        input wen, rst, clk,
        input [15:0] addr_in,
        output [15:0] addr_out
    );
    dff ADDR[15:0] (.q(addr_out[15:0]), .d(addr_in[15:0]), .wen(wen), .clk(clk), .rst(rst));
endmodule