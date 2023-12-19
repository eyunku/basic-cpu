`include "../multicycle_memory.v"
`include "../cache_arbitration.v"

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
            $display("Case 1 Error: no action expected");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Case 2: write + read block
        d_enable = 1'b1; d_write = 1'b1; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'hFFFF; i_addr = 16'h0;
        #20
        // should not recieve any output after write
        if (d_valid == 1'b1 | i_valid == 1'b1) begin
            $display("Case 2 Error: no output after write expected");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Read request by cache-D
        d_enable = 1'b1; d_write = 1'b0; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'h0; i_addr = 16'h0;
        #80
        if (d_valid == 1'b0 | i_valid == 1'b1 | data_out != 16'hFFFF) begin
            $display("Case 2 Error: output after read expected");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Case 3: read request from cache-I and write request from cache-D in parallel
        d_enable = 1'b1; d_write = 1'b1; i_enable = 1'b1; 
        d_addr = 16'h2; d_data = 16'h1234; i_addr = 16'h2;
        #20
        // Write request is deasserted, read request is maintained
        d_enable = 1'b0; d_write = 1'b0; i_enable = 1'b1; 
        d_addr = 16'h2; d_data = 16'h1234; i_addr = 16'h2;
        #60
        // 4 cycles since write request and 3 cycles since read request
        // Check that read was not prioritized over a write
        if (d_valid == 1'b1 | i_valid == 1'b1) begin
            $display("Case 3 Error: cache-I read is prioritized over cache-D write");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end
        #20
        // Check for read request
        if (d_valid == 1'b1 | i_valid == 1'b0 | data_out != 16'h1234) begin
            $display("Case 3 Error: read request after write expected");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

        // Case 4: check incoming read requests from both caches
        d_enable = 1'b1; d_write = 1'b0; i_enable = 1'b1; 
        d_addr = 16'h0; d_data = 16'hFFFF; i_addr = 16'h2;
        #80
        // Check that cache-D was requested first
        if (d_valid == 1'b0 | i_valid == 1'b1 | data_out != 16'hFFFF) begin
            $display("Case 4 Error: cache-D read request expected");
            $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        end

    
        $stop;
    end

    always begin
        #10;
        clk = ~clk;
    end
endmodule