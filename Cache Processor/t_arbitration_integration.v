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

    /**
    * Case 1: no cache misses or writes
    * 
    * Case 2: read request from cache-I
    **/

    // Will only check that output from cache controller to upper level modules (cpu + cache) function correctly
    // Will do extra checks for writes
    initial begin
        clk = 1'b0; rst_n = 1'b0; rst = 1'b1;
        miss_detected_I = 1'b0; miss_address_I = 16'h0;
        miss_detected_D = 1'b0; miss_address_D = 16'h0;
        d_write = 1'b0; d_data = 16'h0000;
        #20
        rst_n = 1'b1; rst = 1'b0;
        #20
        // Case 1
        if (write_data_array_I == 1'b1 | write_tag_array_I == 1'b1 | 
            write_data_array_D == 1'b1 | write_tag_array_D == 1'b1) begin
            $display("Case 1 Error: no load/write requests expected");
            // Recieved by Cache-I and Cache-D
            $display("write_data_array_I: %b write_tag_array_I: %b memory_data_out_I: %h",
                    write_data_array_I, write_tag_array_I, memory_data_out_I);
            $display("write_data_array_D: %b write_tag_array_D: %b memory_data_out_D: %h",
                    write_data_array_D, write_tag_array_D, memory_data_out_D);
            // Cache-I request to controller
            $display("fsm_busy_I: %b memory_address_I: %h", fsm_busy_I, memory_address_I);
            // Cache-D request to controller
            $display("fsm_busy_D: %b memory_address_D: %h", fsm_busy_D, memory_address_D);
            // output from arbitration module
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Case 2: read request from cache-I
        miss_detected_I = 1'b1; miss_address_I = 16'h000F;
        miss_detected_D = 1'b0; miss_address_D = 16'h0;
        d_write = 1'b0; d_data = 16'h0000;
        #1
        // fsm_busy check
        if (fsm_busy_I == 1'b0 | fsm_busy_D == 1'b1) begin
            $display("Case 2 Error: fsm_busy not asserted properly for cache-I");
            // Recieved by Cache-I and Cache-D
            $display("write_data_array_I: %b write_tag_array_I: %b memory_data_out_I: %h",
                    write_data_array_I, write_tag_array_I, memory_data_out_I);
            $display("write_data_array_D: %b write_tag_array_D: %b memory_data_out_D: %h",
                    write_data_array_D, write_tag_array_D, memory_data_out_D);
            // Cache-I request to controller
            $display("fsm_busy_I: %b memory_address_I: %h", fsm_busy_I, memory_address_I);
            // Cache-D request to controller
            $display("fsm_busy_D: %b memory_address_D: %h", fsm_busy_D, memory_address_D);
            // output from arbitration module
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end
        #79
        miss_detected_I = 1'b0;
        // first read is done correctly
        if (fsm_busy_I == 1'b0 | write_data_array_I == 1'b0 | write_tag_array_I == 1'b1 |
            fsm_busy_D == 1'b1 | write_data_array_D == 1'b1 | write_data_array_D == 1'b1) begin
            $display("Case 2 Error: expected 2 byte chunk from memory");
            // Recieved by Cache-I and Cache-D
            $display("write_data_array_I: %b write_tag_array_I: %b memory_data_out_I: %h",
                    write_data_array_I, write_tag_array_I, memory_data_out_I);
            $display("write_data_array_D: %b write_tag_array_D: %b memory_data_out_D: %h",
                    write_data_array_D, write_tag_array_D, memory_data_out_D);
            // Cache-I request to controller
            $display("fsm_busy_I: %b memory_address_I: %h", fsm_busy_I, memory_address_I);
            // Cache-D request to controller
            $display("fsm_busy_D: %b memory_address_D: %h", fsm_busy_D, memory_address_D);
            // output from arbitration module
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end
        #560
        // last read is done correctly
        if (fsm_busy_I == 1'b1 | write_data_array_I == 1'b0 | write_tag_array_I == 1'b0 |
            fsm_busy_D == 1'b1 | write_data_array_D == 1'b1 | write_data_array_D == 1'b1) begin
            $display("Case 2 Error: expected 2 byte chunk from memory");
            // Recieved by Cache-I and Cache-D
            $display("write_data_array_I: %b write_tag_array_I: %b memory_data_out_I: %h",
                    write_data_array_I, write_tag_array_I, memory_data_out_I);
            $display("write_data_array_D: %b write_tag_array_D: %b memory_data_out_D: %h",
                    write_data_array_D, write_tag_array_D, memory_data_out_D);
            // Cache-I request to controller
            $display("fsm_busy_I: %b memory_address_I: %h", fsm_busy_I, memory_address_I);
            // Cache-D request to controller
            $display("fsm_busy_D: %b memory_address_D: %h", fsm_busy_D, memory_address_D);
            // output from arbitration module
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end
        $stop;
    end
    
    always begin
        #10;
        clk = ~clk;
    end

endmodule