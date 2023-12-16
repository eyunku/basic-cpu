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

    // === i_cache wires ===
    reg [15:0] insns_address_i;
    reg [15:0] mem_data_i;
    reg mem_data_valid_i;
    reg mem_tag_valid_i;
    wire [15:0] insns_data_out_i;
    wire cache_miss_i;

    i_cache dut_cache_I (
        .clk(clk), .rst(rst),
        .address(insns_address_i),
        .data_in(mem_data_i),
        .load_data(mem_data_valid_i),
        .load_tag(mem_tag_valid_i),
        .data_out(insns_data_out_i),
        .cache_miss(cache_miss_i)
    );

    cache_fill_FSM dut_controller_I (
        .clk(clk), .rst(rst),
        .miss_detected(),
        .miss_address(),
        .memory_data_in(),
        .memory_data_valid(),
        .fsm_busy(), // TODO breaks, fix is to manually set fsm
        .write_data_array(),
        .write_tag_array(),
        .memory_address(),
        .memory_data_out()
    );


    // === d_cache wires ===
    reg [15:0] insns_address_d;
    reg [15:0] mem_data_d;
    reg [15:0] insns_data_write_d;
    reg insns_write_d;
    reg mem_data_valid_d;
    reg mem_tag_valid_d;
    wire [15:0] insns_data_out_d;
    wire cache_miss_d;

    d_cache dut_cache_D (
        .clk(clk), .rst(rst),
        .address(insns_address_d),
        .data_in(mem_data_d),
        .data_write(insns_data_write_d),
        .write(),
        .load_data(mem_data_valid_d),
        .load_tag(mem_tag_valid_d),
        .data_out(insns_data_out_d),
        .cache_miss(cache_miss_d)
    ); 
    
    cache_fill_FSM dut_controller_D (
        .clk(clk), .rst(rst),
        .miss_detected(),
        .miss_address(),
        .memory_data_in(),
        .memory_data_valid(),
        .fsm_busy(),
        .write_data_array(),
        .write_tag_array(),
        .memory_address(),
        .memory_data_out()
    );

    cache_to_mem dut_arbitration (
        .clk(clk), .rst(rst), 
        .d_enable(), .d_write(), .i_enable(), 
        .d_addr(), .d_data(), .i_addr(),
        .d_valid(), .i_valid(),
        .data_out()
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
        #640

        $display("data_out_i: %h data_out_d: %h", data_out_i, data_out_d);
        $stop;
        $finish;
    end
    
    always begin
        #10;
        clk = ~clk;
    end
endmodule