// hazard unit

// it basically flushes but also needs to freeze the pc
// prevent PC reg and IF/ID reg from changing
// if ID/EX.MemRead and ((ID/EX.RegisterRt = IF/ID.RegisterRs) or (ID/EX.RegisterRt = IF/ID.RegisterRt)), then stall

/*
It is highly recommended to make a table that lists (for each instruction) the control signals needed at each pipeline
stage. Also, make a table listing the input signals and output signals for the data and control hazard detection units
(data hazard stalls and control hazard flushes). The data hazard detection unit should be aware of available data
forwarding and register bypassing
*/

// TODO: include stalling for branch rs  (2 stalls), may have to handelled elsewhere

module hazard_unit (dx_memread, fd_memread, dx_rt, fd_rs, fd_rt, stall_sig, rs_dep);
    // input
    input dx_memread, fd_memread;
    input [3:0] dx_rt, fd_rs, fd_rt;

    // output
    output stall_sig;
    output rs_dep;



    assign rs_dep = (dx_memread & (dx_rt == fd_rs)) ? 1'b1 : 1'b0; // may be used to find branchrs dependency
    
    // the ~fd_memread should prevent stalling for mem to mem case, also note that fd suffix refers to wires from the curr run of decode
    // assign flush_sig = branch != 2'b0; // somehow this signal is sent from the control signal to the IF/ID registers
    assign stall_sig = (dx_memread & ~fd_memread & ((dx_rt == fd_rs) | (dx_rt == fd_rt))) ? 1'b1 : 1'b0;


endmodule

// for the branch rs case we require the stall signal to come from the pc