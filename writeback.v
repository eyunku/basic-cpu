// writeback stage

module WB (pcread, memtoreg, alutowb, memtowb, DstData);
    // inputs
    input pcread, memtoreg;
    input [15:0] memtowb, alutowb;

    // output
    output [15:0] DstData;


    //wire
    assign DstData = pcread ? pc_curr : (memtoreg ? mem_out : alutowb);
endmodule