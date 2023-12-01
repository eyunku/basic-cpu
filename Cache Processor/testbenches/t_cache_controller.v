`include "cache_controller.v"
`include "dff.v" 
`include "alu.v"

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

    initial begin
        // initialize controller
        clk = 1'b0; rst_n = 1'b0; miss_detected = 1'b0; miss_address = 16'h0; memory_data_in = 16'h0; memory_data_valid = 1'h0;
        #20
        rst_n = 1'b1;
        #40 // arbitrary jump

        // Case 1: at idle state, no transition occurs
        if (fsm_busy == 1'b1) begin
            $display("Case 1 Error");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end

        // Case 2: at idle state, transition to wait
        miss_detected = 1'b1; miss_address = 16'hFFF3; memory_data_in = 16'h1; memory_data_valid = 1'h0;
        #1 // initially check to see that fsm_busy is asserted, need to wait some bit to allow signals to pass through module
        if (fsm_busy == 1'b0) begin
            $display("Case 2 Error: fsm_busy not asserted in same cycle");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        #19 // check that other signals are properly asserted
        if (fsm_busy == 1'b0 | write_data_array == 1'b1 | write_tag_array == 1'b1 | memory_address != 16'hFFF0) begin
            $display("Case 2 Error: incorrect signals asserted when waiting for mem data");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end

        // Case 3a: waiting for memory block
        miss_detected = 1'b1; miss_address = 16'hFFF3; memory_data_in = 16'h1; memory_data_valid = 1'h1;
        #20
        if (fsm_busy == 1'b0 | write_data_array == 1'b1 | write_tag_array == 1'b1 | memory_address != 16'hFFF0) begin
            $display("Case 3a Error: waiting for cache chunk");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        // Case 3b: receive memory chunk
        #40 // skip 2 cycles instead of 4 as the previous cases already skipped 2 cycles
        // first chunk
        if (fsm_busy == 1'b0 | write_data_array == 1'b0 | write_tag_array == 1'b1 | memory_address != 16'hFFF0 | memory_data_out != 16'h1) begin
            $display("Case 3b Error: receive first cache chunk");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        #20
        miss_detected = 1'b1; miss_address = 16'hFFF3; memory_data_in = 16'h2; memory_data_valid = 1'h1;
        if (fsm_busy == 1'b0 | write_data_array == 1'b1 | write_tag_array == 1'b1 | memory_address != 16'hFFF2) begin
            $display("Case 3b Error: check memory request for second block");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        #60
        // second chunk
        if (fsm_busy == 1'b0 | write_data_array == 1'b0 | write_tag_array == 1'b1 | memory_address != 16'hFFF2 | memory_data_out != 16'h2) begin
            $display("Case 3b Error: receive second cache chunk");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
                    fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end

        // Case 4: receive last chunk, transition back to idle 
        #420
        miss_detected = 1'b1; miss_address = 16'hFFF3; memory_data_in = 16'h8; memory_data_valid = 1'h1;
        #60
        if (fsm_busy == 1'b1 | write_data_array == 1'b0 | write_tag_array == 1'b0 | memory_address != 16'hFFFE | memory_data_out != 16'h8) begin
            $display("Case 4 Error: receive eighth cache chunk");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
            fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        // Case 5: do it all over again
        miss_detected = 1'b0; // cache will have to implement a deassert on same cycle as write tag
        #20 // next cycle
        miss_detected = 1'b1; miss_address = 16'h0023; memory_data_in = 16'h16; memory_data_valid = 1'h1;
        #640
        if (fsm_busy == 1'b1 | write_data_array == 1'b0 | write_tag_array == 1'b0 | memory_address != 16'h2e | memory_data_out != 16'h16) begin
            $display("Case 5 Error: retrieve different cache block on another miss");
            $display("fsm_busy: %b write_data_array: %b write_tag_array: %b memory_address: %h memory_data_out: %h", 
            fsm_busy, write_data_array, write_tag_array, memory_address, memory_data_out);
        end
        $stop;
    end

    always begin
        #10;
        clk = ~clk;
    end
endmodule