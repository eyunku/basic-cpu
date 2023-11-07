// hazard unit

// if ID/EX.MemRead and ((ID/EX.RegisterRt = IF/ID.RegisterRs) or (ID/EX.RegisterRt = IF/ID.RegisterRt)), then stall

module (dx_memread, dx_rt, fd_rs, fd_rt, stall_sig);
    // input
    input dx_memread;
    input [3:0] dx_rt, fd_rs, fd_rt;

    // output
    output stall_sig;

    
    assign stall_sig = (dx_memread & (dx_rt == fd_rs) | (dx_rt = fd_rt)) ? 1'b1 : 1'b0;

endmodule