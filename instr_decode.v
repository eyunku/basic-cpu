// instruction decode stage

module ID (clk, rst, instruction, DstData, sextimm, SrcData1, SrcData2, regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc, aluop, branch);
    // inputs
    input clk, rst;
    input [15:0] instruction;
    input [15:0] DstData;

    // outputs
    output [15:0] sextimm, SrcData1, SrcData2;

    // cu signals (output)
    output regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    output [3:0] aluop;
    output [1:0] branch;


    // wires
    wire [3:0] opcode = instruction [15:12];
    wire [15:0] imm_4bit = instruction[3] ? {12'hFFF, instruction[3:0]} : {12'b0, instruction[3:0]};
    wire [15:0] imm_8bit = {8'b0, instruction[7:0]};
    assign sextimm = alusext ? imm_8bit : imm_4bit;

    // regfile wires
    wire [3:0] DstReg = instruction[11:8];
    wire [3:0] SrcReg1 = rdsrc ? DstReg : instruction[7:4]; // LLB + LHB case
    wire [3:0] SrcReg2 = instruction[3:0];


//control unit
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

// register file
    
    RegisterFile registerfile (
        .clk(clk), 
        .rst(rst), 
        .SrcReg1(SrcReg1), 
        .SrcReg2(SrcReg2), 
        .DstReg(DstReg), 
        .WriteReg(regwrite), 
        .DstData(DstData), 
        .SrcData1(SrcData1), 
        .SrcData2(SrcData2)
    );

endmodule