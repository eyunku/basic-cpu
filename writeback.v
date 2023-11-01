// writeback stage

module WB (pcread, memtoreg, alutowb, mem_out, pc_curr, DstData);
    // inputs
    input pcread, memtoreg, alutowb;
    input [15:0] mem_out, pc_curr;

    // output
    output [15:0] DstData;


    //wire
    wire err;

    assign DstData = pcread ? pc_curr : (memtoreg ? mem_out : alutowb);
endmodule