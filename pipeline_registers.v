// stall: freeze PC and pipeline registers of IF/ID while ID/EX registers are set to nop
// branch flush: just set IF/ID registers to nop

/*
* 
* stores:
* data -> PC+4, instruction
*
*/
module IFID_plreg(clk, rst, freeze, flush, instruction_in, pc_in, instruction_out, pc_out);
    input clk, rst, freeze, flush;
    input [15:0] instruction_in, pc_in;
    output [15:0] instruction_out, pc_out;

    //PC pipeline register
    
    dff pc_0(.q(pc_out[0]), .d(flush ? 1'b0 : pc_in[0]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_1(.q(pc_out[1]), .d(flush ? 1'b0 : pc_in[1]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_2(.q(pc_out[2]), .d(flush ? 1'b0 : pc_in[2]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_3(.q(pc_out[3]), .d(flush ? 1'b0 : pc_in[3]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_4(.q(pc_out[4]), .d(flush ? 1'b0 : pc_in[4]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_5(.q(pc_out[5]), .d(flush ? 1'b0 : pc_in[5]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_6(.q(pc_out[6]), .d(flush ? 1'b0 : pc_in[6]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_7(.q(pc_out[7]), .d(flush ? 1'b0 : pc_in[7]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_8(.q(pc_out[8]), .d(flush ? 1'b0 : pc_in[8]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_9(.q(pc_out[9]), .d(flush ? 1'b0 : pc_in[9]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_a(.q(pc_out[10]), .d(flush ? 1'b0 : pc_in[10]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_b(.q(pc_out[11]), .d(flush ? 1'b0 : pc_in[11]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_c(.q(pc_out[12]), .d(flush ? 1'b0 : pc_in[12]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_d(.q(pc_out[13]), .d(flush ? 1'b0 : pc_in[13]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_e(.q(pc_out[14]), .d(flush ? 1'b0 : pc_in[14]), .wen(~freeze), .clk(clk), .rst(rst));
    dff pc_f(.q(pc_out[15]), .d(flush ? 1'b0 : pc_in[15]), .wen(~freeze), .clk(clk), .rst(rst));

    // instruction pipline register
    // the nop is subject to change
    dff instruction_0(.q(instruction_out[0]), .d(flush ? 1'b0 : instruction_in[0]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_1(.q(instruction_out[1]), .d(flush ? 1'b0 : instruction_in[1]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_2(.q(instruction_out[2]), .d(flush ? 1'b0 : instruction_in[2]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_3(.q(instruction_out[3]), .d(flush ? 1'b0 : instruction_in[3]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_4(.q(instruction_out[4]), .d(flush ? 1'b0 : instruction_in[4]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_5(.q(instruction_out[5]), .d(flush ? 1'b0 : instruction_in[5]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_6(.q(instruction_out[6]), .d(flush ? 1'b0 : instruction_in[6]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_7(.q(instruction_out[7]), .d(flush ? 1'b0 : instruction_in[7]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_8(.q(instruction_out[8]), .d(flush ? 1'b0 : instruction_in[8]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_9(.q(instruction_out[9]), .d(flush ? 1'b0 : instruction_in[9]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_a(.q(instruction_out[10]), .d(flush ? 1'b0 : instruction_in[10]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_b(.q(instruction_out[11]), .d(flush ? 1'b0 : instruction_in[11]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_c(.q(instruction_out[12]), .d(flush ? 1'b0 : instruction_in[12]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_d(.q(instruction_out[13]), .d(flush ? 1'b0 : instruction_in[13]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_e(.q(instruction_out[14]), .d(flush ? 1'b0 : instruction_in[14]), .wen(~freeze), .clk(clk), .rst(rst));
    dff instruction_f(.q(instruction_out[15]), .d(flush ? 1'b0 : instruction_in[15]), .wen(~freeze), .clk(clk), .rst(rst));
endmodule


/*
* nop on flush signal
*
* stores:
* control signals -> EX, MEM, WB
* data -> rs, rt, sext value, PC+4
* reg -> rd, rs, rt     WHY ARE THERE TWO RT REGISTERS
*/
module IDEX_plreg(clk, rst, flush,
            srcdata1_D, srcdata2_D, sext_D, rs_D, rt_D, rd_D, RegDst_D, ALUSrc_D, ALUOp_D, MemWrite_D, MemRead_D, MemToReg_D, RegWrite_D,
            srcdata1_X, srcdata2_X, sext_X, rs_X, rt_X, rd_X, RegDst_X, ALUSrc_X, ALUOp_X, MemWrite_X, MemRead_X, MemToReg_X, RegWrite_X);
    input clk, rst, flush;
    // inputs from decode stage to store in pipeline
    input [3:0] rs_D, rt_D, rd_D;
    input RegDst_D, ALUSrc_D, ALUOp_D, MemWrite_D, MemRead_D, MemToReg_D, RegWrite_D;
    input [15:0] srcdata1_D, srcdata2_D, sext_D;

    // data outputs
    output [15:0] srcdata1_X, srcdata2_X, sext_X;
    // register outputs
    output [3:0] rs_X, rt_X, rd_X;
    // ID/EX
    output RegDst_X, ALUSrc_X, ALUOp_X;
    // EX/MEM, to be passed to next pipeline
    output MemWrite_X, MemRead_X;
    // MEM/WB, to be passed to next two pipelines
    output MemToReg_X, RegWrite_X;

    dff sd1_0(.q(srcdata1_X[0]), .d(flush ? 1'b0 : srcdata1_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_1(.q(srcdata1_X[1]), .d(flush ? 1'b0 : srcdata1_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_2(.q(srcdata1_X[2]), .d(flush ? 1'b0 : srcdata1_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_3(.q(srcdata1_X[3]), .d(flush ? 1'b0 : srcdata1_D[3]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_4(.q(srcdata1_X[4]), .d(flush ? 1'b0 : srcdata1_D[4]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_5(.q(srcdata1_X[5]), .d(flush ? 1'b0 : srcdata1_D[5]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_6(.q(srcdata1_X[6]), .d(flush ? 1'b0 : srcdata1_D[6]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_7(.q(srcdata1_X[7]), .d(flush ? 1'b0 : srcdata1_D[7]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_8(.q(srcdata1_X[8]), .d(flush ? 1'b0 : srcdata1_D[8]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_9(.q(srcdata1_X[9]), .d(flush ? 1'b0 : srcdata1_D[9]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_a(.q(srcdata1_X[10]), .d(flush ? 1'b0 : srcdata1_D[10]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_b(.q(srcdata1_X[11]), .d(flush ? 1'b0 : srcdata1_D[11]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_c(.q(srcdata1_X[12]), .d(flush ? 1'b0 : srcdata1_D[12]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_d(.q(srcdata1_X[13]), .d(flush ? 1'b0 : srcdata1_D[13]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_e(.q(srcdata1_X[14]), .d(flush ? 1'b0 : srcdata1_D[14]), .wen(1), .clk(clk), .rst(rst));
    dff sd1_f(.q(srcdata1_X[15]), .d(flush ? 1'b0 : srcdata1_D[15]), .wen(1), .clk(clk), .rst(rst));

    dff sd2_0(.q(srcdata2_X[0]), .d(flush ? 1'b0 : srcdata2_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_1(.q(srcdata2_X[1]), .d(flush ? 1'b0 : srcdata2_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_2(.q(srcdata2_X[2]), .d(flush ? 1'b0 : srcdata2_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_3(.q(srcdata2_X[3]), .d(flush ? 1'b0 : srcdata2_D[3]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_4(.q(srcdata2_X[4]), .d(flush ? 1'b0 : srcdata2_D[4]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_5(.q(srcdata2_X[5]), .d(flush ? 1'b0 : srcdata2_D[5]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_6(.q(srcdata2_X[6]), .d(flush ? 1'b0 : srcdata2_D[6]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_7(.q(srcdata2_X[7]), .d(flush ? 1'b0 : srcdata2_D[7]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_8(.q(srcdata2_X[8]), .d(flush ? 1'b0 : srcdata2_D[8]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_9(.q(srcdata2_X[9]), .d(flush ? 1'b0 : srcdata2_D[9]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_a(.q(srcdata2_X[10]), .d(flush ? 1'b0 : srcdata2_D[10]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_b(.q(srcdata2_X[11]), .d(flush ? 1'b0 : srcdata2_D[11]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_c(.q(srcdata2_X[12]), .d(flush ? 1'b0 : srcdata2_D[12]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_d(.q(srcdata2_X[13]), .d(flush ? 1'b0 : srcdata2_D[13]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_e(.q(srcdata2_X[14]), .d(flush ? 1'b0 : srcdata2_D[14]), .wen(1), .clk(clk), .rst(rst));
    dff sd2_f(.q(srcdata2_X[15]), .d(flush ? 1'b0 : srcdata2_D[15]), .wen(1), .clk(clk), .rst(rst));


    dff sext_0(.q(sext_X[0]), .d(flush ? 1'b0 : sext_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff sext_1(.q(sext_X[1]), .d(flush ? 1'b0 : sext_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff sext_2(.q(sext_X[2]), .d(flush ? 1'b0 : sext_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff sext_3(.q(sext_X[3]), .d(flush ? 1'b0 : sext_D[3]), .wen(1), .clk(clk), .rst(rst));
    dff sext_4(.q(sext_X[4]), .d(flush ? 1'b0 : sext_D[4]), .wen(1), .clk(clk), .rst(rst));
    dff sext_5(.q(sext_X[5]), .d(flush ? 1'b0 : sext_D[5]), .wen(1), .clk(clk), .rst(rst));
    dff sext_6(.q(sext_X[6]), .d(flush ? 1'b0 : sext_D[6]), .wen(1), .clk(clk), .rst(rst));
    dff sext_7(.q(sext_X[7]), .d(flush ? 1'b0 : sext_D[7]), .wen(1), .clk(clk), .rst(rst));
    dff sext_8(.q(sext_X[8]), .d(flush ? 1'b0 : sext_D[8]), .wen(1), .clk(clk), .rst(rst));
    dff sext_9(.q(sext_X[9]), .d(flush ? 1'b0 : sext_D[9]), .wen(1), .clk(clk), .rst(rst));
    dff sext_a(.q(sext_X[10]), .d(flush ? 1'b0 : sext_D[10]), .wen(1), .clk(clk), .rst(rst));
    dff sext_b(.q(sext_X[11]), .d(flush ? 1'b0 : sext_D[11]), .wen(1), .clk(clk), .rst(rst));
    dff sext_c(.q(sext_X[12]), .d(flush ? 1'b0 : sext_D[12]), .wen(1), .clk(clk), .rst(rst));
    dff sext_d(.q(sext_X[13]), .d(flush ? 1'b0 : sext_D[13]), .wen(1), .clk(clk), .rst(rst));
    dff sext_e(.q(sext_X[14]), .d(flush ? 1'b0 : sext_D[14]), .wen(1), .clk(clk), .rst(rst));
    dff sext_f(.q(sext_X[15]), .d(flush ? 1'b0 : sext_D[15]), .wen(1), .clk(clk), .rst(rst));

    dff rs0(.q(rs_X[0]), .d(flush ? 1'b0 : rs_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff rs1(.q(rs_X[1]), .d(flush ? 1'b0 : rs_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff rs2(.q(rs_X[2]), .d(flush ? 1'b0 : rs_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff rs3(.q(rs_X[3]), .d(flush ? 1'b0 : rs_D[3]), .wen(1), .clk(clk), .rst(rst));

    dff rt0(.q(rt_X[0]), .d(flush ? 1'b0 : rt_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff rt1(.q(rt_X[1]), .d(flush ? 1'b0 : rt_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff rt2(.q(rt_X[2]), .d(flush ? 1'b0 : rt_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff rt3(.q(rt_X[3]), .d(flush ? 1'b0 : rt_D[3]), .wen(1), .clk(clk), .rst(rst));

    dff rd0(.q(rd_X[0]), .d(flush ? 1'b0 : rd_D[0]), .wen(1), .clk(clk), .rst(rst));
    dff rd1(.q(rd_X[1]), .d(flush ? 1'b0 : rd_D[1]), .wen(1), .clk(clk), .rst(rst));
    dff rd2(.q(rd_X[2]), .d(flush ? 1'b0 : rd_D[2]), .wen(1), .clk(clk), .rst(rst));
    dff rd3(.q(rd_X[3]), .d(flush ? 1'b0 : rd_D[3]), .wen(1), .clk(clk), .rst(rst));

    dff regdst(.q(RegDst_X), .d(flush ? 1'b0 : RegDst_D), .wen(1), .clk(clk), .rst(rst));
    dff alusrc(.q(ALUSrc_X), .d(flush ? 1'b0 : ALUSrc_D), .wen(1), .clk(clk), .rst(rst));
    dff aluop(.q(ALUOp_X), .d(flush ? 1'b0 : ALUOp_D), .wen(1), .clk(clk), .rst(rst));

    dff memwrite(.q(MemWrite_X), .d(flush ? 1'b0 : MemWrite_D), .wen(1), .clk(clk), .rst(rst));
    dff memread(.q(MemRead_X), .d(flush ? 1'b0 : MemRead_D), .wen(1), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg_X), .d(flush ? 1'b0 : MemToReg_D), .wen(1), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite_X), .d(flush ? 1'b0 : RegWrite_D), .wen(1), .clk(clk), .rst(rst));
endmodule

/*
*
* control signals: MEM, WB
* data: alu output, rd-data
* register: rd or rt reg
*/
module EXMEM_plreg(clk, rst, aluout_X, memsrc_X, forwardsrc_X, MemWrite_X, MemRead_X, Branch_X, zero, MemToReg_X, RegWrite_X,
        aluout_M, memsrc_M, forwardsrc_M, MemWrite_M, MemRead_M, Branch_M, zero, MemToReg_M, RegWrite_M);
    input clk, rst;
    input[3:0] forwardsrc_X;
    input[15:0] aluout_X, memsrc_X;
    input MemWrite_X, MemRead_X, Branch_X;
    input MemToReg_X, RegWrite_X;

    output [3:0] forwardsrc_M;
    output [15:0] aluout_M, memsrc_M;
    // EX/MEM
    output MemWrite_M, MemRead_M, Branch_M;
    output zero;
    // MEM/WB, to be passed to next pipeline
    output MemToReg_M, RegWrite_M;
    
    dff aluout_0(.q(aluout_M[0]), .d(aluout_X[0]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_1(.q(aluout_M[1]), .d(aluout_X[1]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_2(.q(aluout_M[2]), .d(aluout_X[2]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_3(.q(aluout_M[3]), .d(aluout_X[3]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_4(.q(aluout_M[4]), .d(aluout_X[4]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_5(.q(aluout_M[5]), .d(aluout_X[5]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_6(.q(aluout_M[6]), .d(aluout_X[6]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_7(.q(aluout_M[7]), .d(aluout_X[7]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_8(.q(aluout_M[8]), .d(aluout_X[8]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_9(.q(aluout_M[9]), .d(aluout_X[9]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_a(.q(aluout_M[10]), .d(aluout_X[10]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_b(.q(aluout_M[11]), .d(aluout_X[11]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_c(.q(aluout_M[12]), .d(aluout_X[12]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_d(.q(aluout_M[13]), .d(aluout_X[13]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_e(.q(aluout_M[14]), .d(aluout_X[14]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_f(.q(aluout_M[15]), .d(aluout_X[15]), .wen(1), .clk(clk), .rst(rst));

    dff memsrc_0(.q(memsrc_M[0]), .d(memsrc_X[0]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_1(.q(memsrc_M[1]), .d(memsrc_X[1]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_2(.q(memsrc_M[2]), .d(memsrc_X[2]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_3(.q(memsrc_M[3]), .d(memsrc_X[3]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_4(.q(memsrc_M[4]), .d(memsrc_X[4]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_5(.q(memsrc_M[5]), .d(memsrc_X[5]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_6(.q(memsrc_M[6]), .d(memsrc_X[6]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_7(.q(memsrc_M[7]), .d(memsrc_X[7]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_8(.q(memsrc_M[8]), .d(memsrc_X[8]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_9(.q(memsrc_M[9]), .d(memsrc_X[9]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_a(.q(memsrc_M[10]), .d(memsrc_X[10]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_b(.q(memsrc_M[11]), .d(memsrc_X[11]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_c(.q(memsrc_M[12]), .d(memsrc_X[12]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_d(.q(memsrc_M[13]), .d(memsrc_X[13]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_e(.q(memsrc_M[14]), .d(memsrc_X[14]), .wen(1), .clk(clk), .rst(rst));
    dff memsrc_f(.q(memsrc_M[15]), .d(memsrc_X[15]), .wen(1), .clk(clk), .rst(rst));

    dff forwardsrc_0(.q(forwardsrc_M[0]), .d(forwardsrc_X[0]), .wen(1), .clk(clk), .rst(rst));
    dff forwardsrc_1(.q(forwardsrc_M[1]), .d(forwardsrc_X[1]), .wen(1), .clk(clk), .rst(rst));
    dff forwardsrc_2(.q(forwardsrc_M[2]), .d(forwardsrc_X[2]), .wen(1), .clk(clk), .rst(rst));
    dff forwardsrc_3(.q(forwardsrc_M[3]), .d(forwardsrc_X[3]), .wen(1), .clk(clk), .rst(rst));

    wire w_zero;
    dff memwrite(.q(MemWrite_M), .d(MemWrite_X), .wen(1), .clk(clk), .rst(rst));
    dff memread(.q(MemRead_M), .d(MemRead_X), .wen(1), .clk(clk), .rst(rst));
    dff branch(.q(Branch_M), .d(Branch_X), .wen(1), .clk(clk), .rst(rst));
    assign w_zero = (aluout_X[0] & aluout_X[1] & aluout_X[2] & aluout_X[3] & aluout_X[4] & aluout_X[5] & aluout_X[6] & aluout_X[7]
                     & aluout_X[8] & aluout_X[9] & aluout_X[10] & aluout_X[11] & aluout_X[12] & aluout_X[13] & aluout_X[14] & aluout_X[15])
                     ? 1'b0 : 1'b1;
    dff reg_zero(.q(w_zero_M), .d(zero), .wen(1), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg_M), .d(MemToReg_X), .wen(1), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite_M), .d(RegWrite_X), .wen(1), .clk(clk), .rst(rst));
endmodule

module MEMWB_plreg(clk, rst, aluout_M, forwardsrc_M, memout_M, MemToReg_M, RegWrite_M, aluout_W, forwardsrc_W, memout_W, MemToReg_W, RegWrite_W);
    input clk, rst;
    input[15:0] aluout_M, memout_M;
    input[3:0] forwardsrc_M;
    input MemToReg_M, RegWrite_M;

    output[15:0] aluout_W, memout_W;
    output[3:0] forwardsrc_W;
    // MEM/WB
    output MemToReg_W, RegWrite_W;

    dff aluout_0(.q(aluout_W[0]), .d(aluout_M[0]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_1(.q(aluout_W[1]), .d(aluout_M[1]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_2(.q(aluout_W[2]), .d(aluout_M[2]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_3(.q(aluout_W[3]), .d(aluout_M[3]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_4(.q(aluout_W[4]), .d(aluout_M[4]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_5(.q(aluout_W[5]), .d(aluout_M[5]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_6(.q(aluout_W[6]), .d(aluout_M[6]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_7(.q(aluout_W[7]), .d(aluout_M[7]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_8(.q(aluout_W[8]), .d(aluout_M[8]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_9(.q(aluout_W[9]), .d(aluout_M[9]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_a(.q(aluout_W[10]), .d(aluout_M[10]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_b(.q(aluout_W[11]), .d(aluout_M[11]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_c(.q(aluout_W[12]), .d(aluout_M[12]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_d(.q(aluout_W[13]), .d(aluout_M[13]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_e(.q(aluout_W[14]), .d(aluout_M[14]), .wen(1), .clk(clk), .rst(rst));
    dff aluout_f(.q(aluout_W[15]), .d(aluout_M[15]), .wen(1), .clk(clk), .rst(rst));

    dff memout_0(.q(memout_W[0]), .d(memout_M[0]), .wen(1), .clk(clk), .rst(rst));
    dff memout_1(.q(memout_W[1]), .d(memout_M[1]), .wen(1), .clk(clk), .rst(rst));
    dff memout_2(.q(memout_W[2]), .d(memout_M[2]), .wen(1), .clk(clk), .rst(rst));
    dff memout_3(.q(memout_W[3]), .d(memout_M[3]), .wen(1), .clk(clk), .rst(rst));
    dff memout_4(.q(memout_W[4]), .d(memout_M[4]), .wen(1), .clk(clk), .rst(rst));
    dff memout_5(.q(memout_W[5]), .d(memout_M[5]), .wen(1), .clk(clk), .rst(rst));
    dff memout_6(.q(memout_W[6]), .d(memout_M[6]), .wen(1), .clk(clk), .rst(rst));
    dff memout_7(.q(memout_W[7]), .d(memout_M[7]), .wen(1), .clk(clk), .rst(rst));
    dff memout_8(.q(memout_W[8]), .d(memout_M[8]), .wen(1), .clk(clk), .rst(rst));
    dff memout_9(.q(memout_W[9]), .d(memout_M[9]), .wen(1), .clk(clk), .rst(rst));
    dff memout_a(.q(memout_W[10]), .d(memout_M[10]), .wen(1), .clk(clk), .rst(rst));
    dff memout_b(.q(memout_W[11]), .d(memout_M[11]), .wen(1), .clk(clk), .rst(rst));
    dff memout_c(.q(memout_W[12]), .d(memout_M[12]), .wen(1), .clk(clk), .rst(rst));
    dff memout_d(.q(memout_W[13]), .d(memout_M[13]), .wen(1), .clk(clk), .rst(rst));
    dff memout_e(.q(memout_W[14]), .d(memout_M[14]), .wen(1), .clk(clk), .rst(rst));
    dff memout_f(.q(memout_W[15]), .d(memout_M[15]), .wen(1), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg_W), .d(MemToReg_M), .wen(1), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite_W), .d(RegWrite_M), .wen(1), .clk(clk), .rst(rst));
endmodule
