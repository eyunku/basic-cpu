`include "hazard_detection.v"

// Some issues that can be forseen
// What if a LLB is called after a LW? possible that hazard interprets 0xYY as rs and rt registers
// What about imm values? Possible to interpret imm as another register
// How does hazard unit differentiate between a non-branch/branch command?

module t_hazard ();
  reg memread_ID, memread_EX, branchtaken, branch, regwrite_EX, regwrite_MEM;
  reg [3:0] rs_ID, rt_ID, rd_EX, rd_MEM;
  wire stall_sig;

  hazard_unit dut (
        //inputs
        .fd_memread(fd_memread), 
        .dx_memread(dx_memread), 
        .branchtaken(branchtaken), 
        .branch(branch), 
        .dx_regwrite(dx_regwrite),
        .stall_sig(stall_sig),
        .xm_regwrite(xm_regwrite),
        .fd_rs(fd_rs),
        .fd_rt(fd_rt),
        .dx_rd(dx_rd),
        .xm_rd(xm_rd),
        .stall_sig(stall_sig),
        );

  // No stall instance
  // Load-Stall instance
  // Branching on rs stall
  // Edge case: mem-mem
  initial begin
    fd_memread = 0; dx_memread, branchtaken, branch, dx_regwrite, xm_regwrite;
    fd_rs, fd_rt, dx_rd, xm_rd;

    memread_EX = 0; memread_ID = 1;  // ADD followed by LW
    DstReg_EX = 4'h5; SrcReg1_ID = 4'h4; SrcReg2_ID = 4'h5;
    #20
    $display("stall: %b branch_stall: %b", stall_sig, rs_dep);
    memread_EX = 0; memread_ID = 0;  // ADD followed by ADD
    DstReg_EX = 4'h5; SrcReg1_ID = 4'h4; SrcReg2_ID = 4'h5;
    #20
    $display("stall: %b branch_stall: %b", stall_sig, rs_dep);
    memread_EX = 1; memread_ID = 0; // LW followed by ADD, no dependencies
    DstReg_EX = 4'h5; SrcReg1_ID = 4'h4; SrcReg2_ID = 4'h4;
    #20
    $display("stall: %b branch_stall: %b", stall_sig, rs_dep);

    memread_EX = 1; memread_ID = 0;  // LW followed by ADD, load-stall
    DstReg_EX = 4'h5; SrcReg1_ID = 4'h4; SrcReg2_ID = 4'h5;
    #20
    $display("stall: %b branch_stall: %b", stall_sig, rs_dep);

    memread_EX = 0; memread_ID = 0;  // LW followed by ADD, load-stall
    DstReg_EX = 4'h5; SrcReg1_ID = 4'h4; SrcReg2_ID = 4'h5;
    $stop;
  end
  
  // always begin
  //   #10;
  //   clk = ~clk;
  // end

endmodule