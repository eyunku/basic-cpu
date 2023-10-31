// new modulized cpu

module cpu_(clk, rst_n, hlt, pc);
    // module inputs
    input clk, rst_n;

    // module outputs
    output [15:0] pc;
    output hlt;


    // IF/ID wires
    wire [15:0] pc_curr;
    wire [15:0] instruction;

    // ID/EX wires
    wire [3:0] SrcReg1, SrcReg2, DstReg;
    wire [15:0] DstData, SrcData1, SrcData2;
    // control unit
    wire [3:0] opcode;
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [1:0] branch;
    wire [3:0] aluop;
    // sext
    wire [15:0] imm_4bit;
    wire [15:0] imm_8bit;
    wire [15:0] imm_16bit;

    // EX/MEM wires
    wire [15:0] aluout, alutomem, alutowb;
    wire err;
    wire [2:0] flag_bits;

    // MEM/WB wire
    wire [15:0] mem;

    // WB wire
    wire [15:0] pcs;


    // FETCH STAGE
    IF fetch(
        //inputs
        .clk(clk),
        .rst(rst_n),
        .C(C),
        .I(I),
        .F(F),
        .br_sig(branch),
        .SrcData1(SrcData1),
        //outputs
        .pc_out(pc_curr),
        .instruction(instruction),
        .opcode(opcode)
    );

    // DECODE STAGE
    ID decode(
        //inputs
        .pc_curr(pc_curr),
        .instruction(instruction),
        //outputs
        .SrcReg1(SrcReg1),
        .SrcReg2(SrcReg2),
        .DstReg(DstReg),
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .DstData(DstData),
        //control signal outputs
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
        .rdsrc(rdsrc),
        // sext
        .imm4bit(imm_4bit),
        .imm8bit(imm_8bit),
        .imm16bit(imm_16bit),
    );

    // EXECUTION
    EX execute(
        //inputs
        .SrcReg1(),
        .SrcRed2(),
        .aluop(aluop),
        .
        //outputs
        .aluout(alout),
        .alutomem(alutomem),
        .alutowb(alutowb),
        .err(err),
        .flag_out(flag_bits),
    );

    // MEMORY
    MEM mem(
        //inputs

        //outputs
    );

    // WRITEBACK
    WB writeback(
        //inputs

        //outputs
    );

endmodule