`include "multicycle_memory.v"
`include "cache_arbitration.v"
`include "cache_controller.v"
`include "dff.v" 
`include "alu.v"

`include "cache.v"
`include "array_helpers.v"
`include "metadata_array.v"
`include "data_array.v"

module t_cache_integration();
    reg clk, rst;

    // cache_I arguments
    reg [15:0] address_i;    
    wire [15:0] data_out_i;
    wire cache_miss_i;

    // cache_D arguments
    reg [15:0] address_d;  
    reg [15:0] write_data_d;
    reg write_d;
    wire [15:0] data_out_d;
    wire cache_miss_d;

    // cache_D arguments

    // cache_I controller arguments
    wire fsm_busy_I; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    wire write_data_array_I; // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array_I; // write enable to cache tag array to signal when all words are filled in to data array
    wire [15:0] memory_address_I; // address to read from memory
    wire [15:0] memory_data_out_I;

    // cache_D controller arguments
    wire fsm_busy_D; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    wire write_data_array_D; // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array_D; // write enable to cache tag array to signal when all words are filled in to data array
    wire [15:0] memory_address_D; // address to read from memory
    wire [15:0] memory_data_out_D;

    // Arbitration arguments
    wire d_valid, i_valid;
    wire [15:0] data_out;

    wire [15:0] choose;

    assign choose = write_d ? address_d : memory_address_D;

    i_cache dut_cache_I (
        .clk(clk), .rst(rst),
        .address(address_i),
        .data_in(memory_data_out_I),
        .load_data(write_data_array_I),
        .load_tag(write_tag_array_I),
        .data_out(data_out_i),
        .cache_miss(cache_miss_i)
    );

    cache_fill_FSM dut_controller_I (
        .clk(clk), .rst(rst),
        .miss_detected(cache_miss_i),
        .miss_address(address_i),
        .memory_data_in(data_out),
        .memory_data_valid(i_valid),
        .fsm_busy(fsm_busy_I), // TODO breaks, fix is to manually set fsm
        .write_data_array(write_data_array_I),
        .write_tag_array(write_tag_array_I),
        .memory_address(memory_address_I),
        .memory_data_out(memory_data_out_I)
    );

    d_cache dut_cache_D (
        .clk(clk), .rst(rst),
        .address(address_d),
        .data_in(memory_data_out_D),
        .data_write(write_data_d),
        .write(write_d),
        .load_data(write_data_array_D),
        .load_tag(write_tag_array_D),
        .data_out(data_out_d),
        .cache_miss(cache_miss_d)
    ); 
    
    cache_fill_FSM dut_controller_D (
        .clk(clk), .rst(rst),
        .miss_detected(cache_miss_d),
        .miss_address(address_d),
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
        .d_enable(fsm_busy_D | write_d), .d_write(write_d), .i_enable(fsm_busy_I), 
        .d_addr(choose), .d_data(write_data_d), .i_addr(memory_address_I),
        .d_valid(d_valid), .i_valid(i_valid),
        .data_out(data_out)
    );

    /**
    * Case 1: no cache misses or writes
    * 
    * Case 2: read request from cache-I
    *
    * Case 3: write from cache-D
    **/

    // Will only check that output from cache controller to upper level modules (cpu + cache) function correctly
    // Will do extra checks for writes
    initial begin
        clk = 1'b0; rst = 1'b1; #80
        rst = 1'b1; #20
        address_i = 16'h0; address_d = 16'h0; 
        write_data_d = 16'h0; write_d = 16'h0;
        #20

        $display("data_out_i: %h data_out_d: %h", data_out_i, data_out_d);
        $stop;
        $finish;
    end
    
    always begin
        #10;
        clk = ~clk;
    end

endmodule