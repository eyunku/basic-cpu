// stall: freeze PC and pipeline registers of IF/ID while ID/EX registers are set to nop
// branch flush: just set IF/ID registers to nop

/*
* 
* stores:
* data -> PC+4, instruction
*
*/
module IF_ID_pipe(
        input clk, rst, freeze, flush,
        input [15:0]  inst_i, pc_i,
        output flag_en_ID,
        output [15:0] inst_o, pc_o);

    pipe_1b_reg flag_sig(.src(1'b1), .dst(flag_en_ID), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg if_id_pc(.src(pc_i), .dst(pc_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg if_id_inst(.src(inst_i), .dst(inst_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
endmodule

/*
* stores:
* control signals -> EX, MEM, WB
* data -> rs, rt, sext value, PC+4
* reg -> rd, rs, rt
*/
module ID_EX_pipe(
        input clk, rst, flush,
        input  alusrc_i, regwrite_i, memenable_i, memwrite_i, memtoreg_i, pcread_i, halt_i, flag_en_ID,
        output alusrc_o, regwrite_o, memenable_o, memwrite_o, memtoreg_o, pcread_o, halt_o, flag_en_EX,
        input  [1:0] branch_i,
        output [1:0] branch_o,
        input  [3:0] aluop_i, SrcReg1_i, SrcReg2_i, DstReg_i,
        output [3:0] aluop_o, SrcReg1_o, SrcReg2_o, DstReg_o,
        input  [15:0] SrcData1_i, SrcData2_i, imm_16bit_i, pc_i,
        output [15:0] SrcData1_o, SrcData2_o, imm_16bit_o, pc_o);

    parameter freeze = 1'b0;
    pipe_1b_reg flag_sig(.src(flag_en_ID), .dst(flag_en_EX), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_1b_reg id_ex_alusrc(.src(alusrc_i), .dst(alusrc_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg id_ex_regwrite(.src(regwrite_i), .dst(regwrite_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg id_ex_memenable(.src(memenable_i), .dst(memenable_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg id_ex_memwrite(.src(memwrite_i), .dst(memwrite_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg id_ex_memtoreg(.src(memtoreg_i), .dst(memtoreg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    // May not need to pass this wire through
    pipe_1b_reg id_ex_pcread(.src(pcread_i), .dst(pcread_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg id_ex_halt(.src(halt_i), .dst(halt_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_2b_reg id_ex_branch(.src(branch_i), .dst(branch_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_4b_reg id_ex_aluop(.src(aluop_i), .dst(aluop_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_4b_reg id_ex_SrcReg1(.src(SrcReg1_i), .dst(SrcReg1_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_4b_reg id_ex_SrcReg2(.src(SrcReg2_i), .dst(SrcReg2_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_4b_reg id_ex_DstReg(.src(DstReg_i), .dst(DstReg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_16b_reg id_ex_SrcData1(.src(SrcData1_i), .dst(SrcData1_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg id_ex_SrcData2(.src(SrcData2_i), .dst(SrcData2_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg id_ex_imm_16bit(.src(imm_16bit_i), .dst(imm_16bit_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg id_ex_pc(.src(pc_i), .dst(pc_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
endmodule

/*
*
* control signals: MEM, WB
* data: alu output, rd-data
* register: rd or rt reg
*/
module EX_MEM_pipe(
        input clk, rst,
        input  regwrite_i, memenable_i, memwrite_i, memtoreg_i, halt_i,
        output regwrite_o, memenable_o, memwrite_o, memtoreg_o, halt_o,
        input  [3:0] SrcReg1_i, SrcReg2_i, DstReg_i,
        output [3:0] SrcReg1_o, SrcReg2_o, DstReg_o,
        input  [15:0] SrcData2_i, aluout_i, pc_i,
        output [15:0] SrcData2_o, aluout_o, pc_o);

    parameter flush = 1'b0;
    parameter freeze = 1'b0;

    pipe_1b_reg ex_mem_regwrite(.src(regwrite_i), .dst(regwrite_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg ex_mem_memenable(.src(memenable_i), .dst(memenable_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg ex_mem_memwrite(.src(memwrite_i), .dst(memwrite_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg ex_mem_memtoreg(.src(memtoreg_i), .dst(memtoreg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg ex_mem_halt(.src(halt_i), .dst(halt_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_4b_reg ex_mem_SrcReg1(.src(SrcReg1_i), .dst(SrcReg1_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_4b_reg ex_mem_SrcReg2(.src(SrcReg2_i), .dst(SrcReg2_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_4b_reg ex_mem_DstReg(.src(DstReg_i), .dst(DstReg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_16b_reg ex_mem_SrcData2(.src(SrcData2_i), .dst(SrcData2_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg ex_mem_aluout(.src(aluout_i), .dst(aluout_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg ex_mem_pc(.src(pc_i), .dst(pc_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
endmodule

module MEM_WB_pipe(
        input clk, rst,
        input  regwrite_i, memtoreg_i, halt_i,
        output regwrite_o, memtoreg_o, halt_o,
        input  [3:0] DstReg_i,
        output [3:0] DstReg_o,
        input  [15:0] aluout_i, mem_i, pc_i,
        output [15:0] aluout_o, mem_o, pc_o);

    parameter flush = 1'b0;
    parameter freeze = 1'b0;

    pipe_1b_reg mem_wb_regwrite(.src(regwrite_i), .dst(regwrite_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg mem_wb_memtoreg(.src(memtoreg_i), .dst(memtoreg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_1b_reg mem_wb_halt(.src(halt_i), .dst(halt_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_4b_reg mem_wb_DstReg(.src(DstReg_i), .dst(DstReg_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));

    pipe_16b_reg mem_wb_aluout(.src(aluout_i), .dst(aluout_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg mem_wb_mem(.src(mem_i), .dst(mem_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
    pipe_16b_reg mem_wb_pc(.src(pc_i), .dst(pc_o), .clk(clk), .rst(rst), .freeze(freeze), .flush(flush));
endmodule
