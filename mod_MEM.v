// memory access stage
module mod_MEM (
        input clk, rst, memenable, memwrite,
        input [15:0] memdata, addr,
        output [15:0] mem_out);

    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(memdata), 
        .addr(addr), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule