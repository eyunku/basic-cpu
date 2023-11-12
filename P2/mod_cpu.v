`include "dff.v"
`include "register.v" 
`include "alu.v"
`include "control.v"
`include "flag.v"
`include "memory.v"
`include "pc_control.v"
`include "pc_register.v"
`include "pipe_register.v"
// `include "forwarding_logic.v"
`include "hazard_detection.v"


`include "mod_if.v"
`include "mod_id.v"
`include "mod_ex.v"
`include "mod_mem.v"
`include "mod_wb.v"
`include "mod_pipe.v"

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

    wire freeze_ID;
    wire nop_ID;
    wire taken_ID;
    // pc reg wires
    wire rst = ~rst_n;
    wire [15:0] pc_in_ID, pc_out_IF;
    // instruction memory wires
    wire [15:0] instruction_IF;

    mod_F mod_f(
        .clk(clk),
        .rst(rst),
        .freeze(freeze_ID),
        .branch(branch_ID),
        .pc_in(pc_in_ID),
        .pc_curr(pc),  // current PC
        .pc_curr2(pc_out_IF), // current PC + 2
        .instruction(instruction_IF));

    // ==== IF/ID Pipeline Register ====

    wire [15:0] instruction_ID, pc_out_ID;

    IF_ID_pipe if_id_pipe(
        .clk(clk),
        .rst(rst),
        .flush(taken_ID), // TODO: for branch not taken
        .freeze(freeze_ID), // for stalls
        .inst_i(instruction_IF), .inst_o(instruction_ID),
        .pc_i(pc_out_IF), .pc_o(pc_out_ID));

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

    // module for decode stage
    mod_ID mod_id(
        .clk(clk),
        .rst(rst),
        .flag(flag_out),
        .DstReg_in(DstReg_WB), // hanging
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
        .imm_16bit(imm_16bit_ID),
        .taken(taken_ID));

    // Hazard Unit
    wire fd_memwrite;
    wire dx_memread;
    wire stall_sig;

    assign fd_memwrite = memenable_ID & memwrite_ID;
    assign dx_memread = (memenable_EX & ~memwrite_EX);

    hazard_unit hazard (
        .fd_memwrite(fd_memwrite), 
        .fd_regwrite(regwrite_ID), 
        .fd_alusrc(alusrc_ID), 
        .fd_branchtaken(taken_ID), 
        .dx_memread(dx_memread), 
        .dx_regwrite(regwrite_EX), 
        .xm_regwrite(regwrite_MEM), 
        .branch(branch_ID), 
        .fd_rs(SrcReg1_ID), 
        .fd_rt(SrcReg2_ID), 
        .dx_rd(DstReg_EX), 
        .xm_rd(DstReg_MEM), 
        .fd_opcode(instruction_ID[3:0]), 
        .stall_sig(stall_sig)
    );

    assign freeze_ID = stall_sig;
    assign nop_ID = stall_sig;

    // ==== ID/EX Pipeline Register ====

    wire alusrc_EX, regwrite_EX, memenable_EX, memwrite_EX, memtoreg_EX, pcread_EX, halt_EX;
    wire [1:0] branch_EX;
    wire [3:0] aluop_EX;

    // Wires for forwarding + data hazard unit
    wire [3:0] SrcReg1_EX, SrcReg2_EX;

    wire [3:0] DstReg_EX;
    wire [15:0] SrcData1_EX, SrcData2_EX, imm_16bit_EX, pc_EX;

    ID_EX_pipe id_ex_pipe(
        .clk(clk),
        .rst(rst),
        .flush(nop_ID), // for stalls
        .alusrc_i(alusrc_ID), .alusrc_o(alusrc_EX),
        .regwrite_i(regwrite_ID), .regwrite_o(regwrite_EX),
        .memenable_i(memenable_ID), .memenable_o(memenable_EX),
        .memwrite_i(memwrite_ID), .memwrite_o(memwrite_EX),
        .memtoreg_i(memtoreg_ID), .memtoreg_o(memtoreg_EX),
        .pcread_i(pcread_ID), .pcread_o(pcread_EX),
        .halt_i(halt_ID), .halt_o(halt_EX),
        .branch_i(branch_ID), .branch_o(branch_EX),
        .aluop_i(aluop_ID), .aluop_o(aluop_EX),
        .SrcReg1_i(SrcReg1_ID), .SrcReg1_o(SrcReg1_EX),
        .SrcReg2_i(SrcReg2_ID), .SrcReg2_o(SrcReg2_EX),
        .DstReg_i(DstReg_out_ID), .DstReg_o(DstReg_EX),
        .SrcData1_i(SrcData1_ID), .SrcData1_o(SrcData1_EX),
        .SrcData2_i(SrcData2_ID), .SrcData2_o(SrcData2_EX),
        .imm_16bit_i(imm_16bit_ID), .imm_16bit_o(imm_16bit_EX),
        .pc_i(pc_in_ID), .pc_o(pc_EX));

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
    wire [3:0] SrcReg1_MEM, SrcReg2_MEM, DstReg_MEM;
    wire [15:0] SrcData2_MEM, aluout_MEM, pc_MEM;

    EX_MEM_pipe ex_mem_pipe(
        .clk(clk),
        .rst(rst),
        .regwrite_i(regwrite_EX), .regwrite_o(regwrite_MEM),
        .memenable_i(memenable_EX), .memenable_o(memenable_MEM),
        .memwrite_i(memwrite_EX), .memwrite_o(memwrite_MEM),
        .memtoreg_i(memtoreg_EX), .memtoreg_o(memtoreg_MEM),
        .halt_i(halt_EX), .halt_o(halt_MEM),
        .SrcReg1_i(SrcReg1_EX), .SrcReg1_o(SrcReg1_MEM),
        .SrcReg2_i(SrcReg2_EX), .SrcReg2_o(SrcReg2_MEM),
        .DstReg_i(DstReg_EX), .DstReg_o(DstReg_MEM),
        .SrcData2_i(SrcData2_EX), .SrcData2_o(SrcData2_MEM),
        .aluout_i(aluout_EX), .aluout_o(aluout_MEM),
        .pc_i(pc_EX), .pc_o(pc_MEM));

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
    wire [3:0] DstReg_WB;
    wire [15:0] aluout_WB, mem_WB, pc_WB;

    MEM_WB_pipe mem_wb_pipe(
        .clk(clk),
        .rst(rst),
        .regwrite_i(regwrite_MEM), .regwrite_o(regwrite_WB),
        .memtoreg_i(memtoreg_MEM), .memtoreg_o(memtoreg_WB),
        .halt_i(halt_MEM), .halt_o(halt_WB),
        .DstReg_i(DstReg_MEM), .DstReg_o(DstReg_WB),
        .aluout_i(aluout_MEM), .aluout_o(aluout_WB),
        .mem_i(mem), .mem_o(mem_WB),
        .pc_i(pc_MEM), .pc_o(pc_WB));

    // ==== WB module ====

    mod_WB mod_wb(
        .memtoreg(memtoreg_WB),
        .alutowb(aluout_WB),
        .mem(mem_WB),
        .DstData(DstData_WB));

    // set hlt bit
    assign hlt = halt_WB;
endmodule