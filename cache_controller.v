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

    // Define state and addr register
    wire state_curr, done, transition;
    wire [15:0] addr_curr, addr_next;

    // TODO test out on clk edge
    assign transition = (miss_detected & ~state_curr) | done;
    dff STATE (.q(state_curr), .d(~state_curr), .wen(transition), .clk(clk), .rst(rst));

    dff ADDR[15:0] (.q(addr_curr[15:0]), .d(addr_next[15:0]), .wen(1'b1), .clk(clk), .rst(rst));

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

    assign done = (addr_pipe_out[3:0] == 4'hE) & (addr_curr[3:0] == 4'hE) & state_curr & valid_pipe_out;

    wire [15:0] chunk_next;
    carry_lookahead next_chunk_address (.a(addr_curr), .b(16'h2), .sum(chunk_next), .overflow(), .mode(1'b0));
    assign addr_next = (miss_detected & ~state_curr) ? (miss_address & ~16'hF) : 
                       (valid_pipe_out & addr_pipe_out == addr_curr & state_curr) ? chunk_next : addr_curr;

    assign memory_address = addr_curr;
    assign memory_data_out = data_pipe_out;
    assign fsm_busy = (state_curr & ~done) | (miss_detected & ~state_curr);
    assign write_data_array = valid_pipe_out & (addr_pipe_out == addr_curr);
    assign write_tag_array = done;
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

/**
* Adds two input bits, putting the result into a sum bit.
* Takes in a carry bit.
**/
module full_adder(a, b, cin, s);
    input a, b, cin;
    output s;

    // sum bit determined by a XOR b XOR cin
    assign s = a ^ b ^ cin;
endmodule

/**
* Generates the generate, propagate and carry out bits.
**/
module carry_block(a, b, cin, g, p, cout);
    input a, b, cin;
    output g, p, cout;

    // create wires for generate and propagate bits
    wire g, p;

    assign g = a & b;
    assign p = a | b;

    // use generate and propagate bits to generate carry-out
    assign cout = g | (p & cin);
endmodule

/**
* 4 bit carry adder. Uses 4 full adders.
* Mode of 1 means subtraction, mode of 0 means addition.
**/
module carry_lookahead_4bit(a, b, cin, sum, cout, mode);
    input[3:0] a, b; // 4-bit inputs to add
    input mode, cin;
    output[3:0] sum;
    output cout;

    // create subtract mode
    wire[3:0] negb;
    assign negb = ~b;

    // wires to store generate and propagate bits
    wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;

    // wire cx_y connects the carry out for bit x to the carry in for bit y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    full_adder  f0(.a(a[0]), .b(mode ? negb[0] : b[0]), .cin(cin), .s(sum[0]));
    carry_block c0(.a(a[0]), .b(mode ? negb[0] : b[0]), .cin(cin), .p(p0), .g(g0), .cout(c0_1));

    full_adder  f1(.a(a[1]), .b(mode ? negb[1] : b[1]), .cin(c0_1), .s(sum[1]));
    carry_block c1(.a(a[1]), .b(mode ? negb[1] : b[1]), .cin(c0_1), .p(p1), .g(g1), .cout(c1_2));

    full_adder  f2(.a(a[2]), .b(mode ? negb[2] : b[2]), .cin(c1_2), .s(sum[2]));
    carry_block c2(.a(a[2]), .b(mode ? negb[2] : b[2]), .cin(c1_2), .p(p2), .g(g2), .cout(c2_3));

    full_adder  f3(.a(a[3]), .b(mode ? negb[3] : b[3]), .cin(c2_3), .s(sum[3]));
    carry_block c3(.a(a[3]), .b(mode ? negb[3] : b[3]), .cin(c2_3), .p(p3), .g(g3), .cout(c3_4));
    
    // generate carry-out of whole module
    assign cout = g3 | (p3 & c3_4);
endmodule

/**
* 16-bit CLA, created from 4 4-bit CLAs. Mode of 1 means subtraction, mode of 0 means addition.
* Outputs the relevant flag bit data into a 3-bit register.
**/
module carry_lookahead(a, b, sum, overflow, mode);
    input[15:0] a, b;
    input mode;
    output[15:0] sum;
    output overflow;

    wire[15:0] b_in;
    wire[15:0] CLASum;

    // wire cx_y connects the carry out of module x to the carry in of module y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    // largest negative and positive values
    wire[15:0] neg, pos;
    assign neg = 16'h8000;
    assign pos = 16'h7fff;

    assign b_in = mode ? ~b : b;
    carry_lookahead_4bit cla0(.a(a[3:0]), .b(b_in[3:0]), .cin(mode), .sum(CLASum[3:0]), .cout(c0_1), .mode(1'b0));
    carry_lookahead_4bit cla1(.a(a[7:4]), .b(b_in[7:4]), .cin(c0_1), .sum(CLASum[7:4]), .cout(c1_2), .mode(1'b0));
    carry_lookahead_4bit cla2(.a(a[11:8]), .b(b_in[11:8]), .cin(c1_2), .sum(CLASum[11:8]), .cout(c2_3), .mode(1'b0));
    carry_lookahead_4bit cla3(.a(a[15:12]), .b(b_in[15:12]), .cin(c2_3), .sum(CLASum[15:12]), .cout(c3_4), .mode(1'b0));

    // check if arithmetic operation is saturated
    assign sum = (a[15] & b_in[15] & ~CLASum[15]) ? neg : 
                 ((~a[15] & ~b_in[15] & CLASum[15]) ? pos : CLASum);
    assign overflow = (a[15] & b_in[15] & ~CLASum[15]) | (~a[15] & ~b_in[15] & CLASum[15]);
endmodule