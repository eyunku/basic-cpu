// memory access stage

module MEM (clk, rst, SrcData2, alutomem, memenable, memwrite, mem_out);
    // inputs
    input clk, rst;
    input [15:0] SrcData2;
    input [15:0] alutomem;
    input memenable, memwrite;

    // output
    output [15:0] mem_out;

    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(SrcData2), 
        .addr(alutomem), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule