`include "multicycle_memory.v"
`include "cache_arbitration.v"
`include "cache_controller.v"
`include "dff.v" 
`include "alu.v"

`include "cache.v"
`include "array_helpers.v"
`include "metadata_array.v"
`include "data_array.v"

// TODO create a mux that selects correct address to pipe into cache

module t_cache_integration();
    reg clk, rst;

    // === i_cache wires ===
    reg [15:0] insns_address_i;
    reg enable_i;
    wire [15:0] insns_data_out_i;
    wire cache_miss_i;
    wire [15:0] load_addr_i;

    // === i_cache controller ===
    wire [15:0] memory_address_i, mem_data_i;
    wire fsm_busy_i;
    wire mem_data_valid_i;
    wire mem_tag_valid_i;

    // === d_cache wires ===
    reg enable_d;
    reg [15:0] insns_address_d;
    reg [15:0] insns_data_in_d;
    reg insns_write_d;
    wire [15:0] insns_data_out_d;
    wire cache_miss_d;
    wire [15:0] load_addr_d;
    
    // === d_cache controller ===
    wire [15:0] memory_address_d, mem_data_d;
    wire mem_data_valid_d;
    wire mem_tag_valid_d;
    wire fsm_busy_d;
    
    // === arbitration ===
    wire [15:0] d_addr, mem_data_out;
    wire d_valid;
    wire i_valid;

    carry_lookahead sub2_i (
        .a(memory_address_i), 
        .b(16'h2), 
        .sum(load_addr_i), 
        .overflow(), 
        .mode(1'b1)
    );
    
    i_cache dut_cache_I (
        .clk(clk), .rst(rst),
        .enable(enable_i),
        .address(insns_address_i),
        .data_in(mem_data_i),
        .load_addr(load_addr_i),
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

    carry_lookahead sub2_d (
        .a(memory_address_d), 
        .b(16'h2), 
        .sum(load_addr_d), 
        .overflow(), 
        .mode(1'b1)
    );

    d_cache dut_cache_D (
        .clk(clk), .rst(rst),
        .enable(enable_d),
        .address(insns_address_d),
        .data_in(mem_data_d),
        .data_write(insns_data_in_d),
        .load_addr(),
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

    assign d_addr = (insns_write_d) ? insns_address_d : memory_address_d;
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

    initial begin
        $dumpfile("t_cache_integration.vcd");
        $dumpvars(0, t_cache_integration);

        clk = 1'b0; rst = 1'b1;
        insns_address_i = 16'h0000;
        insns_address_d = 16'h0000; insns_data_in_d = 16'h0000; insns_write_d = 1'b0;
        #40
        enable_i = 1'b0; enable_d = 1'b0; rst = 1'b0;
        #40

        // I-cache read misses, no memory access
        enable_i = 1'b1;
        enable_d = 1'b0;
        insns_address_i = 16'h0000;
        #660; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hits, no memory access
        insns_address_i = 16'h0002;
        #40; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hits; D-cache memory miss
        enable_d = 1'b1;
        insns_address_i = 16'h0004;
        insns_address_d = 16'h0010;
        #660; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hits; D-cache memory hits
        insns_address_i = 16'h0006;
        insns_address_d = 16'h0012;
        #40; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read misses; D-cache memory hits
        insns_address_i = 16'h0040;
        insns_address_d = 16'h0014;
        #660; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read misses; D-cache memory miss
        insns_address_i = 16'h0080;
        insns_address_d = 16'h0040;
        #1320; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hit; D-cache memory hit
        insns_address_i = 16'h0042;
        insns_address_d = 16'h0016;
        #40; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read miss (write to 2nd way), no memory access
        enable_d = 1'b0;
        insns_address_i = 16'h1000;
        #660; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hits (1st way is still where), no memory access
        insns_address_i = 16'h0008;
        #40; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);

        // I-cache read hits (2nd way is still where), no memory access
        insns_address_i = 16'h1002;
        #40; $display("insns_data_out_i: %h insns_data_out_d: %h", insns_data_out_i, insns_data_out_d);
        $stop;
        $finish;
    end
    
    always begin
        #10;
        clk = ~clk;
    end
endmodule
