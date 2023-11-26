// writeback stage

module mod_WB (
        input memtoreg,
        input [15:0] alutowb, mem,
        output [15:0] DstData);

    //wire
    assign DstData = memtoreg ? mem : alutowb;
    
endmodule