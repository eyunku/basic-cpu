// memory access stage

module MEM (clk, rst, SrcData1, alutomem, memenable, memwrite, mem_out);
    // inputs
    input clk, rst;
    input [15:0] SrcData1;
    input [15:0] alutomem;
    input memenable, memwrite;

    // output
    output mem_out;

    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(SrcData1), 
        .addr(alutomem), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule