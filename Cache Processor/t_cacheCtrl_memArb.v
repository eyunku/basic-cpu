`include "multicycle_memory.v"
`include "cache_arbitration.v"
`include "cache_controller.v"
`include "dff.v" 
`include "alu.v"

module t_integration_Controller_Arbitration();
    reg clk, rst_n, rst;

    // Cache_I arguments
    reg miss_detected_I; // active high when tag match logic detects a miss
    reg [15:0] miss_address_I; // address that missed the cache
    wire fsm_busy_I; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    wire write_data_array_I; // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array_I; // write enable to cache tag array to signal when all words are filled in to data array
    wire [15:0] memory_address_I; // address to read from memory
    wire [15:0] memory_data_out_I;

    // Cache_D arguments
    reg miss_detected_D; // active high when tag match logic detects a miss
    reg [15:0] miss_address_D; // address that missed the cache
    wire fsm_busy_D; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    wire write_data_array_D; // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array_D; // write enable to cache tag array to signal when all words are filled in to data array
    wire [15:0] memory_address_D; // address to read from memory
    wire [15:0] memory_data_out_D;

    // Arbitration arguments
    reg d_write;
    reg [15:0] d_data;
    wire d_valid, i_valid;
    wire [15:0] data_out;

    cache_fill_FSM dut_cache_I (
        .clk(clk), .rst_n(rst_n),
        .miss_detected(miss_detected_I),
        .miss_address(miss_address_I),
        .memory_data_in(data_out),
        .memory_data_valid(i_valid),
        .fsm_busy(fsm_busy_I),
        .write_data_array(write_data_array_I),
        .write_tag_array(write_tag_array_I),
        .memory_address(memory_address_I),
        .memory_data_out(memory_data_out_I)
    );
    
    cache_fill_FSM dut_cache_D (
        .clk(clk), .rst_n(rst_n),
        .miss_detected(miss_detected_D),
        .miss_address(miss_address_D),
        .memory_data_in(data_out),
        .memory_data_valid(d_valid),
        .fsm_busy(fsm_busy_D),
        .write_data_array(write_data_array_D),
        .write_tag_array(write_tag_array_D),
        .memory_address(memory_address_D),
        .memory_data_out(memory_data_out_D)
    );

    cache_to_mem dut_arbitration (
        .clk(clk), .rst(rst), 
        .d_enable(fsm_busy_D | d_write), .d_write(d_write), .i_enable(fsm_busy_I), 
        .d_addr(memory_address_D), .d_data(d_data), .i_addr(memory_address_I),
        .d_valid(d_valid), .i_valid(i_valid),
        .data_out(data_out)
    );

    initial begin
        clk = 1'b0; rst_n = 1'b0; rst = 1'b1;
        miss_detected_I = 1'b0; miss_address_I = 16'h0;
        miss_detected_D = 1'b0; miss_address_D = 16'h0;
        d_write = 1'b0; d_data = 16'h0000;
        #20
        rst_n = 1'b1; rst = 1'b0;
        #20
        $display("write_data_array_I: %b write_tag_array_I: %b memory_data_out_I: %h",
                write_data_array_I, write_tag_array_I, memory_data_out_I);
        $stop
    end
    
    always begin
        #10;
        clk = ~clk;
    end

endmodule