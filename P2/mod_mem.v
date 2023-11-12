// memory access stage
module mod_MEM (
        input clk, rst, memenable, memwrite, forward_mm,
        input [15:0] memdata, memdata_forward, addr,
        output [15:0] mem_out);

    wire [15:0] data_in;
    assign data_in = forward_mm ? memdata_forward : memdata;
    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(data_in), 
        .addr(addr), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule