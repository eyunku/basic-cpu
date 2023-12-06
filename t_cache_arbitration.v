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

    initial begin
        clk = 1'b0; rst = 1'b1;
        #80
        rst = 1'b0;
        #20
        d_enable = 1'b0; d_write = 1'b0; i_enable = 1'b0; 
        d_addr = 16'h0; d_data = 16'h0; i_addr = 16'h0;
        #20
        $display("d_valid: %b i_valid: %b data_out: %h", d_valid, i_valid, data_out);
        $stop;
    end

    always begin
        #10;
        clk = ~clk;
    end
endmodule