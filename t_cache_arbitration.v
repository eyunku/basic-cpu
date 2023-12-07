`include "multicycle_memory.v"
`include "cache_arbitration.v"

module t_arbitration();
    reg clk, rst;
    reg d_enable, d_write, i_enable;
    reg [15:0] d_addr, d_data, i_addr;
    wire d_valid, i_valid;
    wire [15:0] data_out;

    cache_to_mem dut (
        .clk(clk), .rst(rst), 
        .d_enable(d_enable), .d_write(d_write), .i_enable(i_enable), 
        .d_addr(d_addr), .d_data(d_data), .i_addr(i_addr),
        .d_valid(d_valid), .i_valid(i_valid),
        .data_out(data_out)
    );

    /**
    * Scenario Considerations
    * - Incoming request from one of the caches
    * - Incoming request from both of the caches (How to handle)
    * - Read request action
    * - Write request action
    **/

    // Case 1: no action

    // Case 2: write request

    // Case 2a: read request from either cache-I or cache-D

    // Case 2b: two read requests from either cache

    // Case 3a: write request from cache-D

    // Case 3b: read request from cache-I and write request from cache-D

    initial begin
        clk = 1'b0; rst = 1'b1;
        #80
        rst = 1'b0;
        #20
        // Case 1: no action taken
        d_enable = 1'b0; d_write = 1'b0; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'h0; i_addr = 16'h0;
        #20
        if (d_valid == 1'b1 | i_valid == 1'b1) begin
            $display("Case 1 Error: no action");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Case 2: write + read block
        d_enable = 1'b1; d_write = 1'b1; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'hFFFF; i_addr = 16'h0;
        #20
        d_enable = 1'b1; d_write = 1'b0; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'h0; i_addr = 16'h0;
        #80
        $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);

        // Case 3: read request + write request in parallel
        d_enable = 1'b1; d_write = 1'b1; i_enable = 1'b1; 
        d_addr = 16'h2; d_data = 16'h1234; i_addr = 16'h2;
        #80
        $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        // Read request after to check proper write
        d_enable = 1'b0; d_write = 1'b0; i_enable = 1'b1; 
        d_addr = 16'h2; d_data = 16'h1234; i_addr = 16'h2;
        #80
        $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);

        // Case 4: read requests from both blocks
        d_enable = 1'b1; d_write = 1'b0; i_enable = 1'b1; 
        d_addr = 16'h0; d_data = 16'hFFFF; i_addr = 16'h2;
        #80
        $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
    
        $stop;
    end

    always begin
        #10;
        clk = ~clk;
    end
endmodule