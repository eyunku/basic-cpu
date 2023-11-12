`include "register.v"
`include "alu.v"
`include "control.v"
`include "flag.v"
`include "memory.v"
`include "pc_control.v"
`include "pc_register.v"

`include "mod_ID.v"

module t_mod_ID();
    // input
    reg clk, rst;
    reg [2:0] flag;
    reg [15:0] instruction, pc, DstData;
    // output
    wire regwrite, alusrc, memenable, memwrite, memtoreg, alusext, pcread, rdsrc;
    wire [1:0] branch;
    wire [3:0] aluop;
    wire [3:0] SrcReg1, SrcReg2;
    wire [15:0] SrcData1, SrcData2, new_pc, imm_16bit;

    mod_ID dut (
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction), 
        .pc(pc), 
        .flag(flag), 
        .DstData(DstData),
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
        .SrcData1(SrcData1), 
        .SrcData2(SrcData2),
        .SrcReg1(SrcReg1), 
        .SrcReg2(SrcReg2),
        .new_pc(new_pc), 
        .imm_16bit(imm_16bit)
    );

    initial begin
        clk = 1'b0; rst = 1'b0; flag = 3'b000; instruction = 16'h0000; pc = 16'h0; DstData = 16'h0; #40
        $display("instruction: %h pc: %d SrcReg1: %h SrcReg2: %h", instruction, pc, SrcReg1, SrcReg2);
        $display("SrcData1: %h SrcData2: %h new_pc: %h imm_16bit: %h", SrcData1, SrcData2, new_pc, imm_16bit);
        $display("regwrite: %b alusrc: %b memenable: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %b rdsrc: %b", 
                  regwrite, alusrc, memenable, memwrite, aluop, memtoreg, branch, alusext, pcread, rdsrc);
        instruction = 16'h4000; DstData = 16'h0; #20 // sll
        $display("instruction: %h pc: %d SrcReg1: %h SrcReg2: %h", instruction, pc, SrcReg1, SrcReg2);
        $display("SrcData1: %h SrcData2: %h new_pc: %h imm_16bit: %h", SrcData1, SrcData2, new_pc, imm_16bit);
        $display("regwrite: %b alusrc: %b memenable: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %b rdsrc: %b", 
                  regwrite, alusrc, memenable, memwrite, aluop, memtoreg, branch, alusext, pcread, rdsrc);
        instruction = 16'h8000; DstData = 16'h0; #20 // lw
        $display("instruction: %h pc: %d SrcReg1: %h SrcReg2: %h", instruction, pc, SrcReg1, SrcReg2);
        $display("SrcData1: %h SrcData2: %h new_pc: %h imm_16bit: %h", SrcData1, SrcData2, new_pc, imm_16bit);
        $display("regwrite: %b alusrc: %b memenable: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %b rdsrc: %b", 
                  regwrite, alusrc, memenable, memwrite, aluop, memtoreg, branch, alusext, pcread, rdsrc);
        instruction = 16'hC000; DstData = 16'h0; #20 // b
        $display("instruction: %h pc: %d SrcReg1: %h SrcReg2: %h", instruction, pc, SrcReg1, SrcReg2);
        $display("SrcData1: %h SrcData2: %h new_pc: %h imm_16bit: %h", SrcData1, SrcData2, new_pc, imm_16bit);
        $display("regwrite: %b alusrc: %b memenable: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %b rdsrc: %b", 
                  regwrite, alusrc, memenable, memwrite, aluop, memtoreg, branch, alusext, pcread, rdsrc);
        $stop;
        $finish;
    end

    always begin
        #10
        clk = ~clk;
    end

endmodule