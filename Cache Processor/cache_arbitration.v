// d_read will be enabled in two scenarios
// cache controller, when a read miss occurs
// cache, when a write is being donw

// i_read will only be enabled when a read miss occurs

// d_addr will be determined based on two scenarios
// cache controller, determines incoming address to read from memory
// cache, determines address to write to memory

// d_data will be sent when cache wants to write to memory

// i_addr is the addr that cache_i wants to read from memory

// output is determined by cache_to_mem
// depending on which cache requested memory, cache_to_mem will send
// the information through the corresponding output and asser the proper valid signals

// NOTE: features not incoporated into the interface yet (may have to handle this outside)
// - On either a read miss or write for cache_d, the proper d_addr must be provided (MUX required)
// - Cache will have to determine when to stop requesting writes

module cache_to_mem(
    input clk, rst,
    input d_enable, d_write, i_enable,
    input [15:0] d_addr, d_data, i_addr,
    output d_valid, i_valid,
    output [15:0] data_out
);
    parameter CACHE_D = 2'h2;
    parameter CACHE_I = 2'h1;
    parameter CACHE_NONE = 2'h0;

    wire enable, wr;
    wire [1:0] who;
    wire [15:0] addr;
    // Determine which cache controller receives data_out
    // prioritize cache_d requests
    assign who = (d_enable | d_enable & d_write) ? CACHE_D :
                 (i_enable) ? CACHE_I : CACHE_NONE;

    // set memory input based on cache
    assign enable = (who == CACHE_D) ? d_enable : 
                    (who == CACHE_I) ? i_enable : 1'b0;
    assign wr = (who == CACHE_D) ? d_write : 1'b0;
    assign addr = (who == CACHE_D) ? d_addr : i_addr;

    /** 
    * multi-cycle module here 
    **/
    // note: 
    // d_data is already handled by wr
    // d_out can be sent to both caches, just need to ensure that proper valid bits are set
    wire data_valid;
    memory4c main_mem (
        .clk(clk), 
        .rst(rst),
        .enable(enable),
        .wr(wr), 
        .data_in(d_data), 
        .addr(addr),  
        .data_valid(data_valid), 
        .data_out(data_out)
    );

    assign d_valid = (who == CACHE_D) ? data_valid : 1'b0;
    assign i_valid = (who == CACHE_I) ? data_valid : 1'b0;
endmodule