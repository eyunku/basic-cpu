`include "cache_controller.v"

module t_cache_controller();
    reg clk, rst_n;
    reg miss_detected; // active high when tag match logic detects a miss
    reg [15:0] miss_address; // address that missed the cache
    reg [15:0] memory_data_in; // data returned by memory (after delay)
    reg memory_data_valid; // active high indicates valid data returning on memory bus
    wire fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    wire write_data_array; // write enable to cache data array to signal when filling with memory_data
    wire write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array
    wire [15:0] memory_address; // address to read from memory
    wire [15:0] memory_data_out;

    cache_fill_FSM dut (
        .clk(clk),
        .rst_n(rst_n),
        .miss_detected(miss_detected),
        .miss_address(miss_address),
        .memory_data_in(memory_data_in),
        .memory_data_valid(memory_data_valid),
        .fsm_busy(fsm_busy),
        .write_data_array(write_data_array),
        .write_tag_array(write_tag_array),
        .memory_address(memory_address),
        .memory_data_out(memory_data_out)
    );

    // Case 1: at idle state, no transition

    // Case 2: at idle state, transition IW

    // Case 3a: at wait state, no transition occurs
    // Case 3b: at wait state, transition WW occurs

    // Case 4: at wait state, transition WI occurs

    // Case 5: rst_n is asserted, check that state reverts to idle

    initial begin
        clk = 1'b0; rst_n = 1'b0; miss_detected = 1'b0; miss_address = 16'h0; memory_data_in = 16'h0; memory_data_valid = 1'h0; #40
        rst_n = 1'b1; #20
        miss_detected = 1'b1; miss_address = 16'hFFFE;
        #20
        memory_data_in = 16'h1111; memory_data_valid = 1'h1;
        #60
        $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        #20
        memory_data_in = 16'h1112; memory_data_valid = 1'h1;
        $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
            fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        #60
        $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
            fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        $stop;
    end

    always begin
        #10;
        clk = ~clk;
    end
endmodule