// In progress
// Added new arguments
// Input: DstReg_in
// Output: SrcReg1_out, SrcReg2_out, DstReg_out

module mod_ID (
        input clk, rst,
        input [2:0] flag,
        input [3:0] DstReg_in,
        input [15:0] instruction, pc, DstData,
        output regwrite, alusrc, memenable, memwrite, memtoreg, pcread, rdsrc, halt, taken,
        output [1:0] branch,
        output [3:0] aluop, SrcReg1, SrcReg2, DstReg_out,
        output [15:0] SrcData1, SrcData2, new_pc, imm_16bit);

    // control wire
    wire [3:0] opcode;

    // imm sext wires
    wire [15:0] imm_4bit;
    wire [15:0] imm_8bit;

    // pc control wires
    wire [9:0] I;
    wire [2:0] C, F;

    // register output wires
    wire [15:0] out1, out2;

    // CONTROL UNIT
    assign opcode = instruction[15:12];
    control control_unit (
        .opcode(opcode), 
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .memenable(memenable), 
        .memwrite(memwrite), 
        .aluop(aluop), 
        .memtoreg(memtoreg), 
        .branch(branch), 
        .alusext(alusext), 
        .pcread(pcread), 
        .rdsrc(rdsrc)
    );

    // dst and src reg assignment
    assign DstReg_out = instruction[11:8];
    assign SrcReg1 = pcread ? 4'h0 : 
                     rdsrc ? DstReg_out : instruction[7:4]; // LLB + LHB case
    // SW case, use SrcReg2 for reading register "rt"
    assign SrcReg2 = pcread ? 4'h0 : 
                     memenable & memwrite ? DstReg_out : instruction[3:0];

    // Sext unit here
    assign imm_4bit = instruction[3] ? {12'hFFF, instruction[3:0]} : {12'b0, instruction[3:0]};
    assign imm_8bit = {8'b0, instruction[7:0]};
    assign imm_16bit = alusext ? imm_8bit : imm_4bit;

    RegisterFile registerfile (
        .clk(clk), 
        .rst(rst), 
        .SrcReg1(SrcReg1), 
        .SrcReg2(SrcReg2), 
        .DstReg(DstReg_out), 
        .WriteReg(regwrite), 
        .DstData(DstData), 
        .SrcData1(out1), 
        .SrcData2(out2)
    );

    assign SrcData1 = pcread ? pc : out1;

    // PC control
    assign C = instruction[11:9];
    assign I = {instruction[8:0], 1'b0};
    assign F = flag;

    pc_control pc_control (
        .bsig(branch), 
        .C(C), 
        .I(I), 
        .F(F), 
        .regsrc(SrcData1), 
        .PC_in(pc), 
        .PC_out(new_pc),
        .taken(taken)
    );

    assign halt = branch == 2'b11;
endmodule