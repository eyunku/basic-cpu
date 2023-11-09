// writeback stage

module mod_WB (
        input pcread, memtoreg,
        input [15:0] pc_in, alutowb, mem,
        output [15:0] DstData);

    //wire
    assign DstData = pcread ? pc_in : (memtoreg ? mem : alutowb);
    
endmodule