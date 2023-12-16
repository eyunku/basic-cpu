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
    wire [15:0] insns_data_out_i;
    wire cache_miss_i;

    // === i_cache controller ===
    wire [15:0] memory_address_i, mem_data_i;
    wire fsm_busy_i;
    wire mem_data_valid_i;
    wire mem_tag_valid_i;

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
        .miss_detected(cache_miss_i),
        .miss_address(insns_address_i),
        .memory_data_in(mem_data_out),
        .memory_data_valid(i_valid),
        .fsm_busy(fsm_busy_i), // TODO breaks, fix is to manually set fsm
        .write_data_array(mem_data_valid_i),
        .write_tag_array(mem_tag_valid_i),
        .memory_address(memory_address_i),
        .memory_data_out(mem_data_i)
    );

    // === d_cache wires ===
    reg [15:0] insns_address_d;
    reg [15:0] insns_data_in_d;
    reg insns_write_d;
    wire [15:0] insns_data_out_d;
    wire cache_miss_d;
    
    // === d_cache controller ===
    wire [15:0] memory_address_d, mem_data_d;
    wire mem_data_valid_d;
    wire mem_tag_valid_d;
    wire fsm_busy_d;

    d_cache dut_cache_D (
        .clk(clk), .rst(rst),
        .address(insns_address_d),
        .data_in(mem_data_d),
        .data_write(insns_data_in_d),
        .write(insns_write_d),
        .load_data(mem_data_valid_d),
        .load_tag(mem_tag_valid_d),
        .data_out(insns_data_out_d),
        .cache_miss(cache_miss_d)
    ); 
    
    cache_fill_FSM dut_controller_D (
        .clk(clk), .rst(rst),
        .miss_detected(cache_miss_d),
        .miss_address(insns_address_d),
        .memory_data_in(mem_data_out),
        .memory_data_valid(d_valid),
        .fsm_busy(fsm_busy_d),
        .write_data_array(mem_data_valid_d),
        .write_tag_array(mem_tag_valid_d),
        .memory_address(memory_address_d),
        .memory_data_out(mem_data_d)
    );

    // === arbitration ===
    wire [15:0] d_addr, mem_data_out;
    wire d_valid;
    wire i_valid;

    assign d_addr = (insns_write_d) ? insns_data_in_d : memory_address_d;
    cache_to_mem dut_arbitration (
        .clk(clk), .rst(rst), 
        .d_enable(fsm_busy_d | insns_write_d), .d_write(insns_write_d), .i_enable(fsm_busy_i), 
        .d_addr(d_addr), .d_data(insns_data_in_d), .i_addr(memory_address_i),
        .d_valid(d_valid), .i_valid(i_valid),
        .data_out(mem_data_out)
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
        #640

        $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);
        $stop;
        $finish;
    end
    
    always begin
        #10;
        clk = ~clk;
    end
endmodule