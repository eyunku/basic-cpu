`include "../hazard_detection.v"

/*
* Some issues that can be forseen
* What if a LLB is called after a LW? possible that hazard interprets 0xYY as rs and rt registers
* What about imm values? Possible to interpret imm as another register
* How does hazard unit differentiate between a non-branch/branch command?
*/

module t_hazard ();
    reg fd_memwrite, fd_regwrite, fd_alusrc, fd_branchtaken, dx_memread, dx_regwrite, xm_regwrite;
    reg [1:0] branch;
    reg [3:0] fd_rs, fd_rt, dx_rd, xm_rd, fd_opcode;
    wire stall_sig;

  hazard_unit dut (
    .fd_memwrite(fd_memwrite), 
    .fd_regwrite(fd_regwrite), 
    .fd_alusrc(fd_alusrc), 
    .fd_branchtaken(fd_branchtaken), 
    .dx_memread(dx_memread), 
    .dx_regwrite(dx_regwrite), 
    .xm_regwrite(xm_regwrite), 
    .branch(branch), 
    .fd_rs(fd_rs), 
    .fd_rt(fd_rt), 
    .dx_rd(dx_rd), 
    .xm_rd(xm_rd), 
    .fd_opcode(fd_opcode), 
    .stall_sig(stall_sig)
  );

  // No stall instance
  // Load-Stall instance
  // Branching on rs stall
  // Edge case: mem-mem
  initial begin
    // ADD R3 R1 R2 -> LW R2 0(R4)
    fd_memwrite = 1'b0; fd_regwrite = 1'b1; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b0; dx_memread = 1'b1; dx_regwrite = 1'b1; xm_regwrite = 1'b1;
    branch = 2'b00;
    fd_rs = 4'h1; fd_rt = 4'h2; dx_rd = 4'h2; xm_rd = 4'h2; fd_opcode = 4'h0;
    #20
    $display("stall: %b", stall_sig);
    // SW R3 0(R2) -> LW R2 0(R4)
    fd_memwrite = 1'b1; fd_regwrite = 1'b0; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b0; dx_memread = 1'b0; dx_regwrite = 1'b1; xm_regwrite = 1'b1;
    branch = 2'b00;
    fd_rs = 4'h2; fd_rt = 4'h0; dx_rd = 4'h2; xm_rd = 4'h2; fd_opcode = 4'b1001;
    #20
    $display("stall: %b", stall_sig);
    // BR ccc R5 -> ADD R5 R2 R1
    fd_memwrite = 1'b0; fd_regwrite = 1'b0; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b1; dx_memread = 1'b0; dx_regwrite = 1'b1; xm_regwrite = 1'b1;
    branch = 2'b10;
    fd_rs = 4'h5; fd_rt = 4'h2; dx_rd = 4'h5; xm_rd = 4'h5; fd_opcode = 4'b1101;
    #20
    $display("stall: %b", stall_sig);
    // BR ccc R5 -> ... -> ADD R5 R2 R1
    fd_memwrite = 1'b0; fd_regwrite = 1'b0; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b1; dx_memread = 1'b1; dx_regwrite = 1'b1; xm_regwrite = 1'b1;
    branch = 2'b10;
    fd_rs = 4'h5; fd_rt = 4'h2; dx_rd = 4'h4; xm_rd = 4'h5; fd_opcode = 4'b1101;
    #20
    $display("stall: %b", stall_sig);
    // BR ccc R5 -> PCS R5
    fd_memwrite = 1'b0; fd_regwrite = 1'b0; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b1; dx_memread = 1'b0; dx_regwrite = 1'b1; xm_regwrite = 1'b0;
    branch = 2'b10;
    fd_rs = 4'h5; fd_rt = 4'h2; dx_rd = 4'h5; xm_rd = 4'h4; fd_opcode = 4'b1001;
    #20
    $display("stall: %b", stall_sig);

    // BR ccc R5 -> SW R5 0(R4)
    fd_memwrite = 1'b0; fd_regwrite = 1'b0; fd_alusrc = 1'b0; 
    fd_branchtaken = 1'b1; dx_memread = 1'b0; dx_regwrite = 1'b0; xm_regwrite = 1'b0;
    branch = 2'b10;
    fd_rs = 4'h5; fd_rt = 4'h2; dx_rd = 4'h5; xm_rd = 4'h4; fd_opcode = 4'b1001;
    #20
    $display("stall: %b", stall_sig);
    $stop;
  end
  
  // always begin
  //   #10;
  //   clk = ~clk;
  // end

endmodule