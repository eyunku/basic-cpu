// memory access stage
module mod_MEM (
        input clk, rst, memenable, memwrite,
        input [15:0] SrcData2, aluout,
        output [15:0] mem_out);

    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(SrcData2), 
        .addr(aluout), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule