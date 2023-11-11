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

module hazard_unit (
        input fd_memread, dx_memread, branchtaken, branch, dx_regwrite, xm_regwrite
        input [3:0] fd_rs, fd_rt, dx_rd, xm_rd,
        output stall_sig);

    wire load_stall, branch_stall;

    // Load-stall case (freezes PC, freezes IF/ID register, sends NOP to ID/EX)
    // Stalls until LW gets to MEM stage
    assign load_stall = ((dx_memread & ~fd_memread) & (dx_rd == fd_rs) | (dx_rd == fd_rt));

    // Branch-stall case (freezes PC, freezes IF/ID register, sends NOP to ID/EX)
    // Stalls until dependency issue is resolved at WB stage
    // Conditions:
    //  is a BR branch (fd_rs)
    //  branch is taken
    //  Either EX or MEM will write to dst register
    assign branch_stall = ((branchtaken & branch == 2'b10) & 
                          ((dx_rd == fd_rs & dx_regwrite) | (xm_rd == fd_rs & xm_regwrite)));
    assign stall_sig = load_stall & branch_stall;
        
    // the ~fd_memread should prevent stalling for mem to mem case, also note that fd suffix refers to wires from the curr run of decode
    // assign flush_sig = branch != 2'b0; // somehow this signal is sent from the control signal to the IF/ID registers
endmodule

// for the branch rs case we require the stall signal to come from the pc