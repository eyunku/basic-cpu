// Fetches next instruction from PC
module mod_F (
        input clk, rst, freeze, taken, i_valid,
        input [1:0] branch,
        input [15:0] pc_in,
        input [15:0] mem_data_out,
        output fsm_busy_i,
        output [15:0] pc_curr, // for t_cpu to display
        output [15:0] pc_curr2, // pc_curr + 2. for IF_ID pipeline reg
        output [15:0] instruction,
        output [15:0] memory_address_i);

    wire [15:0] pc_next;

    // ==== i_cache wires ====
    wire cache_miss_i;
    wire [15:0] load_addr_i;

    // ==== i_cache controller ====
    wire [15:0] mem_data_i;
    wire mem_data_valid_i;
    wire mem_tag_valid_i;

    // TODO Might be issues if a cache_miss occurs when a branch is taken occurs
    pc_16bit_reg pc_reg (
        .clk(clk), 
        .rst(rst),
        .freeze(freeze | fsm_busy_i), // prevents pc from incrementing
        .pc_in(pc_next), 
        .pc_out(pc_curr));

    // When should cache be disabled?
    // branching, disable cache + reset controller back to original state

    // fsm_busy
    // stall pc_reg + send nop to pipeline reg IF/ID

    carry_lookahead sub2_i (
        .a(memory_address_i), 
        .b(16'h2), 
        .sum(load_addr_i), 
        .overflow(), 
        .mode(1'b1)
    );
    
    i_cache cache_I (
        .clk(clk), .rst(rst),
        .enable(~((branch[0] | branch[1]) & taken)),
        .address(pc_curr),
        .data_in(mem_data_i),
        .load_addr(load_addr_i),
        .load_data(mem_data_valid_i),
        .load_tag(mem_tag_valid_i),
        .data_out(instruction),
        .cache_miss(cache_miss_i)
    );

    cache_fill_FSM controller_I (
        .clk(clk), .rst(rst | ((branch[0] | branch[1]) & taken)),
        .miss_detected(cache_miss_i),
        .miss_address(pc_curr),
        .memory_data_in(mem_data_out),
        .memory_data_valid(i_valid),
        .fsm_busy(fsm_busy_i),
        .write_data_array(mem_data_valid_i),
        .write_tag_array(mem_tag_valid_i),
        .memory_address(memory_address_i),
        .memory_data_out(mem_data_i)
    );

    // adder
    carry_lookahead next(.a(pc_curr), .b(16'h2), .sum(pc_curr2), .overflow(), .mode(1'b0));
    // mux
    assign pc_next = (fsm_busy_i) ? pc_curr :
                     (instruction[15:12] == 4'hF & ~taken) ? pc_curr : 
                     ((branch[0] | branch[1]) & taken) ? pc_in : pc_curr2;
endmodule
