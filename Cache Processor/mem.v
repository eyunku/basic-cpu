// memory access stage
module mod_MEM (
        input clk, rst, memenable, memwrite, forward_mm, d_valid,
        input [15:0] memdata, memdata_forward, addr, mem_data_out,
        output fsm_busy_d,
        output [15:0] mem_out, d_addr, d_data);

    wire [15:0] data_in;
    assign data_in = forward_mm ? memdata_forward : memdata;
    assign d_data = data_in;

    // === d_cache wires ===
    wire [15:0] insns_data_out_d;
    wire cache_miss_d;
    wire [15:0] load_addr_d;
    
    // === d_cache controller ===
    wire [15:0] memory_address_d, mem_data_d;
    wire mem_data_valid_d;
    wire mem_tag_valid_d;
    wire fsm_busy_d;

    carry_lookahead sub2_d (
        .a(memory_address_d), 
        .b(16'h2), 
        .sum(load_addr_d), 
        .overflow(), 
        .mode(1'b1)
    );

    d_cache cache_d (
        .clk(clk), .rst(rst),
        .enable(memenable),
        .address(addr),
        .data_in(mem_data_d),
        .data_write(data_in),
        .load_addr(load_addr_d),
        .write(memwrite),
        .load_data(mem_data_valid_d),
        .load_tag(mem_tag_valid_d),
        .data_out(mem_out),
        .cache_miss(cache_miss_d)
    ); 
    
    cache_fill_FSM controller_d (
        .clk(clk), .rst(rst),
        .miss_detected(cache_miss_d),
        .miss_address(addr),
        .memory_data_in(mem_data_out),
        .memory_data_valid(d_valid),
        .fsm_busy(fsm_busy_d),
        .write_data_array(mem_data_valid_d),
        .write_tag_array(mem_tag_valid_d),
        .memory_address(memory_address_d),
        .memory_data_out(mem_data_d)
    );

    assign d_addr = (memwrite) ? addr : memory_address_d;

endmodule