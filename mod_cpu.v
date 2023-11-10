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

module mod_CPU (
        input clk, rst_n,
        output hlt,
        output [15:0] pc);

    // ==== FETCH module ====

    wire freeze = 1'b0;
    // pc reg wires
    wire rst = ~rst_n;
    wire [15:0] pc_in, pc_out;
    // instruction memory wires
    wire [15:0] instruction;

    mod_F mod_f(
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .branch(branch),
        .pc_in(pc_in),
        .pc_out(pc_out),
        .instruction(instruction));

    // ==== DECODE module ====

    // wires for CONTROL UNIT
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [1:0] branch;
    wire [3:0] aluop;

    // wires for DECODE
    // reg wires
    wire [3:0] SrcReg1, SrcReg2, DstReg_out;
    wire [15:0] DstData, SrcData1, SrcData2;
    wire [15:0] imm_16bit;

    mod_ID mod_id(
        .clk(clk),
        .rst(rst),
        .flag(flag_out),
        .DstReg_in(), // hanging
        .instruction(instruction),
        .pc(pc_out),
        .DstData(DstData),
        .regwrite(regwrite),
        .alusrc(alusrc),
        .memenable(memenable),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .alusext(alusext),
        .pcread(pcread),
        .rdsrc(rdsrc),
        .branch(branch),
        .aluop(aluop),
        .SrcReg1(SrcReg1),
        .SrcReg2(SrcReg2),
        .DstReg_out(DstReg_out),
        .SrcData1_out(SrcData1),
        .SrcData2_out(SrcData2),
        .new_pc(pc_in),
        .imm_16bit(imm_16bit));

    // ==== EXECUTION module ====

    // wires for flag reg
    wire [2:0] flag_out;
    // wires for alu
    wire [15:0] aluout;

    mod_EX mod_ex(
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .alusrc(alusrc),
        .memenable(memenable),
        .branch(branch),
        .pcread(pcread),
        .aluop(aluop),
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .imm_16bit(imm_16bit),
        .aluout(aluout),
        .flag_out(flag_out));

    // ==== MEMORY module ====

    wire [15:0] mem;

    mod_MEM mod_mem(
        .clk(clk),
        .rst(rst),
        .memenable(memenable),
        .memwrite(memwrite),
        .SrcData2(SrcData2),
        .aluout(aluout),
        .mem_out(mem));

    // ==== WB module ====

    wire [15:0] alutomem;
    assign alutomem = aluout;

    mod_WB mod_wb(
        .pcread(pcread),
        .memtoreg(memtoreg),
        .pc_in(pc_in),
        .alutowb(aluout),
        .mem(mem),
        .DstData(DstData));

    // set hlt bit
    assign hlt = branch == 2'b11;
    assign pc = pc_in;
    
endmodule