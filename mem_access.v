// memory access stage

module MEM (clk, rst, SrcData1, aluout, memenable, memwrite, mem_out);
    // inputs
    input clk, rst;
    input [15:0] SrcData1;
    input [15:0] aluout;
    input memenable, memwrite;

    // output
    output mem_out;
    
    //wires
    assign alutowb = aluout;

    main_memory cpu_memory (
        .data_out(mem_out), 
        .data_in(SrcData1), 
        .addr(aluout), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst)
    );

endmodule