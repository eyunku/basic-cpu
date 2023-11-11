`include "dff.v"
`include "register.v" 
`include "alu.v"
`include "control.v"
`include "flag.v"
`include "memory.v"
`include "pc_control.v"
`include "pc_register.v"

`include "mod_IF.v"
`include "mod_ID.v"
`include "mod_EX.v"
`include "mod_MEM.v"
`include "mod_WB.v"


// ==== FETCH stage ====
// Split up PC control
// PC + 2 is done in fetch
// Branching is done in decode
// Resolution is done in fetch w/ branching signal from pc_control

// Passes out instruction and PC + 2

// fetch takes in:
// branch signal to determine next PC
// freeze signal for stalling PC

// Pipeline at this stage takes in:
// flush signal for branch not taken
// freeze signal for stalls
// instruction and PC + 2

// ==== DECODE stage ====
// Decode should emit rs and rt registers for hazard
// If neither rs or rt are used, emit 0000
// ALUSrc to differentiate between usage of rt or imm
// Branch = 2 for branching edge case

// Dealing with BR RAW dependency
// Possible Solutions: 
// Delay until after EX + ID Forwarding (EX-ID, MEM-ID)
// Delay until writeback + register bypassing

// PCS should be resolved in decode and piped through the rs register
// mux on both SrcData1 wire and SrcData2 wire using pcread signal
// pass in SrcData1 and (pc + 2) for mux 1
// pass in SrcData2 and 16'h0 for mux 2

// Decode should pass out:
// Control signals for other stages
// Immediate value, SrcData1 and SrcData2
// Register ID's for rd, rs, rt
// the next PC for branching

// ==== Execute stage ====
// 

// ==== WRITEBACK stage ====
// PC and halt are set at writeback

// Clean up PCS path

module mod_CPU (
        input clk, rst_n,
        output hlt,
        output [15:0] pc);

    // ==== FETCH module ====

    wire freeze = 1'b0;
    // pc reg wires
    wire rst = ~rst_n;
    wire [15:0] pc_in_ID, pc_out_IF;
    // instruction memory wires
    wire [15:0] instruction_IF;

    mod_F mod_f(
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .branch(branch_ID),
        .pc_in(pc_in_ID),
        .pc_out(pc_out_IF),
        .instruction(instruction_IF));

    // ==== IF/ID Pipeline Register ====
    wire [15:0] instruction_ID, pc_out_ID;

    // IFID IFID_pipe(
    //     .rst(rst),
    //     .clk(clk),
    //     .flush(flush), // for branch not taken
    //     .freeze(freeze), // for stalls
    //     .instruction_in(instruction_IF),
    //     .pc_in(pc_out_IF),
    //     .instruction_out(instruction_ID),
    //     .pc_out(pc_out_ID),
    // );

    assign instruction_ID = instruction_IF;
    assign pc_out_ID = pc_out_IF;

    // ==== DECODE module ====

    // wires for CONTROL UNIT
    wire regwrite_ID, alusrc_ID, memenable_ID, memwrite_ID, memtoreg_ID, pcread_ID, alusext_ID, rdsrc_ID, halt_ID;
    wire [1:0] branch_ID;
    wire [3:0] aluop_ID;

    // wires for DECODE
    // reg wires
    wire [3:0] SrcReg1_ID, SrcReg2_ID, DstReg_out_ID;
    wire [15:0] SrcData1_ID, SrcData2_ID;
    wire [15:0] imm_16bit_ID;
    wire [15:0] DstData_WB;

    mod_ID mod_id(
        .clk(clk),
        .rst(rst),
        .flag(flag_out),
        .DstReg_in(), // hanging
        .instruction(instruction_ID),
        .pc(pc_out_IF),
        .DstData(DstData_WB),
        .regwrite(regwrite_ID),
        .alusrc(alusrc_ID),
        .memenable(memenable_ID),
        .memwrite(memwrite_ID),
        .memtoreg(memtoreg_ID),
        .pcread(pcread_ID),
        .rdsrc(rdsrc_ID),
        .halt(halt_ID),
        .branch(branch_ID),
        .aluop(aluop_ID),
        .SrcReg1(SrcReg1_ID),
        .SrcReg2(SrcReg2_ID),
        .DstReg_out(DstReg_out_ID),
        .SrcData1(SrcData1_ID),
        .SrcData2(SrcData2_ID),
        .new_pc(pc_in_ID),
        .imm_16bit(imm_16bit_ID));

    // ==== ID/EX Pipeline Register ====
    wire regwrite_EX, memenable_EX, memwrite_EX, memtoreg_EX, pcread_EX, halt_EX;
    wire [1:0] branch_EX;
    wire [3:0] aluop_EX;

    // Wires for forwarding + data hazard unit
    wire [3:0] SrcReg1_EX, SrcReg2_EX;

    wire [3:0] DstReg_EX;
    wire [15:0] SrcData1_EX, SrcData2_EX, imm_16bit_EX, pc_EX;

    // IDEX IDEX_pipe(
    //     .rst(rst),
    //     .clk(clk),
    //     .regwrite(reg)
    // );

    assign regwrite_EX = regwrite_ID;
    assign alusrc_EX = alusrc_ID;
    assign memenable_EX = memenable_ID;
    assign memwrite_EX = memwrite_ID;
    assign memtoreg_EX = memtoreg_ID;
    assign pcread_EX = pcread_ID; // May not need to pass this wire through
    assign halt_EX = halt_ID;
    assign branch_EX = branch_ID;
    assign aluop_EX = aluop_ID;

    assign SrcReg1_EX = SrcReg1_ID;
    assign SrcReg2_EX = SrcReg2_ID;
    assign DstReg_EX = DstReg_out_ID;
    assign SrcData1_EX = SrcData1_ID;
    assign SrcData2_EX = SrcData2_ID;
    assign imm_16bit_EX = imm_16bit_ID;
    assign pc_EX = pc_in_ID;

    // ==== EXECUTION module ====

    // wires for flag reg
    wire [2:0] flag_out;
    // wires for alu
    wire [15:0] aluout_EX;

    mod_EX mod_ex(
        .clk(clk),
        .rst(rst),
        .alusrc(alusrc_EX),
        .memenable(memenable_EX),
        .branch(branch_EX),
        .pcread(pcread_EX),
        .aluop(aluop_EX),
        .SrcData1(SrcData1_EX),
        .SrcData2(SrcData2_EX),
        .imm_16bit(imm_16bit_EX),
        .aluout(aluout_EX),
        .flag_out(flag_out));

    // ==== EX/MEM Pipeline Register ====
    wire regwrite_MEM, memenable_MEM, memwrite_MEM, memtoreg_MEM, halt_MEM;
    wire [3:0] SrcReg1_MEM, SrcReg2_MEM;
    wire [15:0] DstReg_MEM, SrcData2_MEM, aluout_MEM, pc_MEM;

    assign regwrite_MEM = regwrite_EX;
    assign memenable_MEM = memenable_EX;
    assign memwrite_MEM = memwrite_EX;
    assign memtoreg_MEM = memtoreg_EX;
    assign halt_MEM = halt_EX;

    // Forwarding unit (mem-mem)
    assign SrcReg1_MEM = SrcReg1_EX;
    assign SrcReg2_MEM = SrcReg2_EX;
    
    assign DstReg_MEM = DstReg_EX;
    assign SrcData2_MEM = SrcData2_EX;
    assign aluout_MEM = aluout_EX;
    assign pc_MEM = pc_EX;

    // ==== MEMORY module ====

    wire [15:0] mem;

    mod_MEM mod_mem(
        .clk(clk),
        .rst(rst),
        .memenable(memenable_MEM),
        .memwrite(memwrite_MEM),
        .memdata(SrcData2_MEM),
        .addr(aluout_MEM),
        .mem_out(mem));

    // ==== MEM/WB Pipeline Register ====
    wire regwrite_WB, memtoreg_WB, halt_WB;
    wire [15:0] DstReg_WB, aluout_WB, mem_WB, pc_WB;

    assign DstReg_WB = DstReg_MEM;
    assign regwrite_WB = regwrite_MEM;
    assign memtoreg_WB = memtoreg_MEM;
    assign halt_WB = halt_MEM;

    assign aluout_WB = aluout_MEM;
    assign mem_WB = mem;
    assign pc_WB = pc_MEM;

    // ==== WB module ====

    mod_WB mod_wb(
        .memtoreg(memtoreg_WB),
        .alutowb(aluout_WB),
        .mem(mem_WB),
        .DstData(DstData_WB));

    // set hlt bit
    assign hlt = halt_WB;
    // TODO pc is set to curr_pc + 2
    assign pc = pc_WB;
endmodule