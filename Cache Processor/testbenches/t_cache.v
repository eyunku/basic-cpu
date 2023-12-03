`include "../cache.v"

/*
* Some issues that can be forseen
* What if a LLB is called after a LW? possible that hazard interprets 0xYY as rs and rt registers
* What about imm values? Possible to interpret imm as another register
* How does hazard unit differentiate between a non-branch/branch command?
*/

module t_cache ();
    reg clk, rst, en, write;
    reg [15:0] address, data_in;
    wire [15:0] data_out;
    wire cache_miss;  

    i_cache dut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .data_in(data_in),
        .en(en),
        .write(write),
        .data_out(data_out),
        .cache_miss(cache_miss)
    );  

    // INITIAL CACHE MISS
    // POPULATE CACHE
    // CACHE HIT
    // DIFF TAG BITS
    initial begin
        // INITIALIZE EVERYTHING
        clk = 0; rst = 1; write = 0;
        #10; #40; rst = 0;
        // TEST INITIAL CACHE MISS
        address = 16'b0000001000001000; // tag 1, set 1, offset 0
        data_in = 16'hFACE; en = 0;
        #20;
        // SAME ADDRESS MISS SINCE WE HAVENT WRITTEN YET
        address = 16'b0000001000001000; // tag 1, set 1, offset 0
        data_in = 16'hFACE; en = 0;
        #20;
        // WRITE INTO ARRAYS
        address = 16'b0000001000001000; // tag 1, set 1, offset 0
        data_in = 16'hFACE; en = 1;
        #20;
        // SAME ADDRESS HIT SINCE WE HAVE NOW WRITTEN
        address = 16'b0000001000001000; // tag 1, set 1, offset 0
        data_in = 16'hFACE; en = 0;
        #20;
        // DIFF TAG INCURE MISS
        address = 16'b0000011000001000; // tag 3, set 1, offset 0
        data_in = 16'hFACE; en = 0;
        #20;
        $stop;
    end
  
    always begin
        #10;
        clk = ~clk;
    end

endmodule