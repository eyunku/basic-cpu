// hazard unit

// it basically flushes but also needs to freeze the pc
// prevent PC reg and IF/ID reg from changing
// if ID/EX.MemRead and ((ID/EX.RegisterRt = IF/ID.RegisterRs) or (ID/EX.RegisterRt = IF/ID.RegisterRt)), then stall

module (dx_memread, fd_memread, dx_rt, fd_rs, fd_rt, stall_sig);
    // input
    input dx_memread, fd_memread;
    input [3:0] dx_rt, fd_rs, fd_rt;

    // output
    output stall_sig;

    
    assign stall_sig = (dx_memread & ~fd_memread & (dx_rt == fd_rs) | (dx_rt = fd_rt)) ? 1'b1 : 1'b0;
    // the ~fd_memread should prevent stalling for mem to mem case
    // assign flush_sig = branch != 2'b0; // somehow this signal is sent from the control signal to the IF/ID registers

    // include no stalling for MEM to MEM
    // flush signal should be moved to control unit and can use the branch signal for it

endmodule