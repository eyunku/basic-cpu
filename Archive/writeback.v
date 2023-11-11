// writeback stage

module WB (pcread, memtoreg, alutowb, pc_curr, mem_out, DstData);
    // inputs
    input pcread, memtoreg;
    input [15:0] pc_curr, mem_out, alutowb;

    // output
    output [15:0] DstData;


    //wire
    carry_lookahead pcs_adder(.a(pc_curr), .b(16'h2), .sum(pcs), .overflow(), .mode(1'b0));
    assign DstData = pcread ? pcs : (memtoreg ? mem_out : alutowb);
endmodule