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

// fd_memwrite (fd_memenable & fd_memwrite), consider case where LW is followed by SW
// dx_memread (dx_memenable & ~dx_memwrite), check that lw occurs
// branchtaken and branch, identify if a branch stall occurs
// dx_regwrite and xm_regwrite, for branch stalls, considers case where dst register isn't written to (SW)
// fd_rs and fd_rt, to check for Raw dependency
// stall_sig, occurs whenever a load_stall or branch_stall occurs



// LW R3 5(R4)
// LW R2 5(R3)

// ADD R2
// ROR R2 R3 2
// fd_rs = R3
// fd_rt = R2

module hazard_unit (
        input fd_memwrite, fd_regwrite, fd_alusrc, fd_branchtaken, dx_memread, dx_regwrite, xm_regwrite,
        input [1:0] branch,
        input [3:0] fd_rs, fd_rt, dx_rd, xm_rd, fd_opcode,
        output stall_sig);

    wire load_stall, branch_stall;

    // Load-stall case (freezes PC, freezes IF/ID register, sends NOP to ID/EX)
    // Stalls until LW gets to MEM stage
    wire dx_zero_reg; // 
    wire rs_used;
    wire rt_used;
    wire rs_dep;
    wire rt_dep;

    assign dx_zero_reg = dx_rd == 4'h0;
    assign rs_used = fd_regwrite & ~(fd_opcode == 4'b1110);
    assign rt_used = rs_used & ~fd_alusrc;

    assign rs_dep = dx_rd == fd_rs;
    assign rt_dep = dx_rd == fd_rt;

    assign load_stall = (~dx_zero_reg & dx_memread & ~fd_memwrite & (dx_memread & ~fd_memwrite) & ((rs_used & rs_dep) | (rt_used & rt_dep)));

    // Branch-stall case (freezes PC, freezes IF/ID register, sends NOP to ID/EX)
    // Stalls until dependency issue is resolved at WB stage
    // Conditions:
    //  is a BR branch (fd_rs)
    //  branch is taken
    //  Either EX or MEM will write to dst register

    wire xm_zero_reg;
    wire br_rs_occur;
    wire dx_branch_stall;
    wire xm_branch_stall;

    assign xm_zero_reg = xm_rd == 4'h0;
    assign br_rs_occur = fd_branchtaken & (branch == 2'b10);
    assign dx_branch_stall = ~dx_zero_reg & (dx_rd == fd_rs) & dx_regwrite;
    assign xm_branch_stall = ~xm_zero_reg & (xm_rd == fd_rs) & xm_regwrite;

    assign branch_stall = (br_rs_occur & (dx_branch_stall | xm_branch_stall));

    assign stall_sig = load_stall | branch_stall;    
    // the ~fd_memread should prevent stalling for mem to mem case, also note that fd suffix refers to wires from the curr run of decode
    // assign flush_sig = branch != 2'b0; // somehow this signal is sent from the control signal to the IF/ID registers
endmodule

// for the branch rs case we require the stall signal to come from the pc