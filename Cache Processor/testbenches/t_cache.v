`include "../cache.v"

/*
* Some issues that can be forseen
* What if a LLB is called after a LW? possible that hazard interprets 0xYY as rs and rt registers
* What about imm values? Possible to interpret imm as another register
* How does hazard unit differentiate between a non-branch/branch command?
*/

module t_cache ();
    reg clk, rst, load_data, load_tag, write;
    reg [15:0] address, data_in;
    wire [15:0] data_out;
    wire cache_miss;  

    d_cache dut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .data_in(data_in),
        .write(write),
        .load_data(load_data),
        .load_tag(load_tag),
        .data_out(data_out),
        .cache_miss(cache_miss)
    );  

    // INITIAL CACHE MISS
    // POPULATE CACHE
    // CACHE HIT
    // DIFF TAG BITS
    initial begin
        // INITIALIZE EVERYTHING
        clk = 0; rst = 1; load_data = 0; load_tag = 0; write = 0;
        #10; #40; rst = 0;
        // TEST INITIAL CACHE MISS on invalid
        address = 16'b0000000000000000; // tag 0, set 0, offset 0
        data_in = 16'hFACE;
        #20;

        // TEST LOADING IN VALUES
        address = 16'b0000000000000000; // tag 1, set 1, offset 0
        data_in = 16'h00AA;
        load_data = 1;
        #20;
        address = 16'b0000000000000010; // tag 1, set 1, offset 0
        data_in = 16'h00AB;
        #20;
        address = 16'b0000000000000100; // tag 1, set 1, offset 0
        data_in = 16'h00AC;
        #20;
        address = 16'b0000000000000110; // tag 1, set 1, offset 0
        data_in = 16'h00AD;
        #20;
        address = 16'b0000000000001000; // tag 1, set 1, offset 0
        data_in = 16'h00BA;
        #20;
        address = 16'b0000000000001010; // tag 1, set 1, offset 0
        data_in = 16'h00BB;
        #20;
        address = 16'b0000000000001100; // tag 1, set 1, offset 0
        data_in = 16'h00BC;
        #20;
        // FINAL BLOCK TO LOAD AND THEN TAG LOAD
        address = 16'b0000000000001110; // tag 1, set 1, offset 0
        data_in = 16'h00BD;
        load_tag = 1;
        #20;

        // SAME ADDR SHOULD HIT
        address = 16'b0000000000000000; // tag 3, set 1, offset 0
        load_tag = 0; load_data = 0;
        #20;
        // SAME BLOCK SHOULD HIT
        address = 16'b0000000000000110; // tag 3, set 1, offset 0
        #20;
        // DIFF ADDRESS SHOULD MISS
        address = 16'b0000011000001000; // tag 3, set 1, offset 0
        #20;

        // TEST LOADING IN DIFF TAG
        address = 16'b1000000000000000; // tag 1, set 1, offset 0
        data_in = 16'h00DA;
        load_data = 1;
        #20;
        address = 16'b1000000000000010; // tag 1, set 1, offset 0
        data_in = 16'h00DB;
        #20;
        address = 16'b1000000000000100; // tag 1, set 1, offset 0
        data_in = 16'h00DC;
        #20;
        address = 16'b1000000000000110; // tag 1, set 1, offset 0
        data_in = 16'h00DD;
        #20;
        address = 16'b1000000000001000; // tag 1, set 1, offset 0
        data_in = 16'h00CA;
        #20;
        address = 16'b1000000000001010; // tag 1, set 1, offset 0
        data_in = 16'h00CB;
        #20;
        address = 16'b1000000000001100; // tag 1, set 1, offset 0
        data_in = 16'h00CC;
        #20;
        // FINAL BLOCK TO LOAD AND THEN TAG LOAD
        address = 16'b1000000000001110; // tag 1, set 1, offset 0
        data_in = 16'h00CD;
        load_tag = 1;
        #20;


        // SAME ADDR SHOULD HIT
        address = 16'b1000000000000000; // tag 3, set 1, offset 0
        load_tag = 0; load_data = 0;
        #20;
        // SAME BLOCK SHOULD HIT AND WRITE NEW DATA
        address = 16'b1000000000000110; // tag 3, set 1, offset 0
        write = 1;
        data_in = 16'h00FF;
        #20;
        address = 16'b1000000000000110; // tag 3, set 1, offset 0
        write = 0;
        #20;
        // DIFF ADDRESS SHOULD MISS
        address = 16'b0000011000001000; // tag 3, set 1, offset 0
        #20;
        $stop;
    end
  
    always begin
        #10;
        clk = ~clk;
    end

endmodule