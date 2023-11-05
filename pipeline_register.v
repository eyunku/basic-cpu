module IFID(instruction, write, rs, rt, rd, imm, clk, rst, nop);
    input[15:0] instruction;
    input write, clk, rst, nop;
    output[3:0] rs, rt, rd, imm;

    dff rs0(.q(rs[0]), .d(nop ? 1'b0 : instruction[12]), .wen(write), .clk(clk), .rst(rst));
    dff rs1(.q(rs[1]), .d(nop ? 1'b0 : instruction[13]), .wen(write), .clk(clk), .rst(rst));
    dff rs2(.q(rs[2]), .d(nop ? 1'b0 : instruction[14]), .wen(write), .clk(clk), .rst(rst));
    dff rs3(.q(rs[3]), .d(nop ? 1'b0 : instruction[15]), .wen(write), .clk(clk), .rst(rst));

    dff rt0(.q(rt[0]), .d(nop ? 1'b0 : instruction[8]), .wen(write), .clk(clk), .rst(rst));
    dff rt1(.q(rt[1]), .d(nop ? 1'b0 : instruction[9]), .wen(write), .clk(clk), .rst(rst));
    dff rt2(.q(rt[2]), .d(nop ? 1'b0 : instruction[10]), .wen(write), .clk(clk), .rst(rst));
    dff rt3(.q(rt[3]), .d(nop ? 1'b0 : instruction[11]), .wen(write), .clk(clk), .rst(rst));

    dff rd0(.q(rd[0]), .d(nop ? 1'b0 : instruction[4]), .wen(write), .clk(clk), .rst(rst));
    dff rd1(.q(rd[1]), .d(nop ? 1'b0 : instruction[5]), .wen(write), .clk(clk), .rst(rst));
    dff rd2(.q(rd[2]), .d(nop ? 1'b0 : instruction[6]), .wen(write), .clk(clk), .rst(rst));
    dff rd3(.q(rd[3]), .d(nop ? 1'b0 : instruction[7]), .wen(write), .clk(clk), .rst(rst));

    dff imm0(.q(imm[0]), .d(nop ? 1'b0 : instruction[0]), .wen(write), .clk(clk), .rst(rst));
    dff imm1(.q(imm[1]), .d(nop ? 1'b0 : instruction[1]), .wen(write), .clk(clk), .rst(rst));
    dff imm2(.q(imm[2]), .d(nop ? 1'b0 : instruction[2]), .wen(write), .clk(clk), .rst(rst));
    dff imm3(.q(imm[3]), .d(nop ? 1'b0 : instruction[3]), .wen(write), .clk(clk), .rst(rst));
endmodule

module IDEX(write, src1, src2, rs, rt, rd, RegDst, ALUSrc, ALUOp, MemWrite, MemRead, MemToReg, RegWrite, nop);
    input write;
    inout [3:0] src1, src2, rs, rt, rd;
    // ID/EX
    inout RegDst, ALUSrc, ALUOp;
    // EX/MEM, to be passed to next pipeline
    inout MemWrite, MemRead;
    // MEM/WB, to be passed to next two pipelines
    inout MemToReg, RegWrite;

    dff src1_0(.q(src1[0]), .d(nop ? 1'b0 : src1[0]), .wen(write), .clk(clk), .rst(rst));
    dff src1_1(.q(src1[1]), .d(nop ? 1'b0 : src1[1]), .wen(write), .clk(clk), .rst(rst));
    dff src1_2(.q(src1[2]), .d(nop ? 1'b0 : src1[2]), .wen(write), .clk(clk), .rst(rst));
    dff src1_3(.q(src1[3]), .d(nop ? 1'b0 : src1[3]), .wen(write), .clk(clk), .rst(rst));

    dff src2_0(.q(src2[0]), .d(nop ? 1'b0 : src2[0]), .wen(write), .clk(clk), .rst(rst));
    dff src2_1(.q(src2[1]), .d(nop ? 1'b0 : src2[1]), .wen(write), .clk(clk), .rst(rst));
    dff src2_2(.q(src2[2]), .d(nop ? 1'b0 : src2[2]), .wen(write), .clk(clk), .rst(rst));
    dff src2_3(.q(src2[3]), .d(nop ? 1'b0 : src2[3]), .wen(write), .clk(clk), .rst(rst));

    dff rs0(.q(rs[0]), .d(nop ? 1'b0 : rs[0]), .wen(write), .clk(clk), .rst(rst));
    dff rs1(.q(rs[1]), .d(nop ? 1'b0 : rs[1]), .wen(write), .clk(clk), .rst(rst));
    dff rs2(.q(rs[2]), .d(nop ? 1'b0 : rs[2]), .wen(write), .clk(clk), .rst(rst));
    dff rs3(.q(rs[3]), .d(nop ? 1'b0 : rs[3]), .wen(write), .clk(clk), .rst(rst));

    dff rt0(.q(rt[0]), .d(nop ? 1'b0 : rt[0]), .wen(write), .clk(clk), .rst(rst));
    dff rt1(.q(rt[1]), .d(nop ? 1'b0 : rt[1]), .wen(write), .clk(clk), .rst(rst));
    dff rt2(.q(rt[2]), .d(nop ? 1'b0 : rt[2]), .wen(write), .clk(clk), .rst(rst));
    dff rt3(.q(rt[3]), .d(nop ? 1'b0 : rt[3]), .wen(write), .clk(clk), .rst(rst));

    dff rd0(.q(rd[0]), .d(nop ? 1'b0 : rd[0]), .wen(write), .clk(clk), .rst(rst));
    dff rd1(.q(rd[1]), .d(nop ? 1'b0 : rd[1]), .wen(write), .clk(clk), .rst(rst));
    dff rd2(.q(rd[2]), .d(nop ? 1'b0 : rd[2]), .wen(write), .clk(clk), .rst(rst));
    dff rd3(.q(rd[3]), .d(nop ? 1'b0 : rd[3]), .wen(write), .clk(clk), .rst(rst));

    dff regdst(.q(RegDst), .d(RegDst), .wen(write), .clk(clk), .rst(rst));
    dff alusrc(.q(ALUSrc), .d(ALUSrc), .wen(write), .clk(clk), .rst(rst));
    dff aluop(.q(ALUOp), .d(nop ? 1'b0 : ALUOp), .wen(write), .clk(clk), .rst(rst));

    dff memwrite(.q(MemWrite), .d(MemWrite), .wen(write), .clk(clk), .rst(rst));
    dff memread(.q(MemRead), .d(MemRead), .wen(write), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg), .d(MemToReg), .wen(write), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite), .d(RegWrite), .wen(write), .clk(clk), .rst(rst));
endmodule

module EXMEM(aluout, memsrc, forwardsrc, MemWrite, MemRead, Branch, zero, MemToReg, RegWrite, nop);
    inout[3:0] memsrc, forwardsrc;
    inout[15:0] aluout;
    // EX/MEM
    inout MemWrite, MemRead, Branch;
    output zero;
    // MEM/WB, to be passed to next pipeline
    inout MemToReg, RegWrite;
    
    dff aluout0(.q(aluout[0]), .d(nop ? 1'b0 : aluout[0]), .wen(write), .clk(clk), .rst(rst));
    dff aluout1(.q(aluout[1]), .d(nop ? 1'b0 : aluout[1]), .wen(write), .clk(clk), .rst(rst));
    dff aluout2(.q(aluout[2]), .d(nop ? 1'b0 : aluout[2]), .wen(write), .clk(clk), .rst(rst));
    dff aluout3(.q(aluout[3]), .d(nop ? 1'b0 : aluout[3]), .wen(write), .clk(clk), .rst(rst));
    dff aluout4(.q(aluout[4]), .d(nop ? 1'b0 : aluout[4]), .wen(write), .clk(clk), .rst(rst));
    dff aluout5(.q(aluout[5]), .d(nop ? 1'b0 : aluout[5]), .wen(write), .clk(clk), .rst(rst));
    dff aluout6(.q(aluout[6]), .d(nop ? 1'b0 : aluout[6]), .wen(write), .clk(clk), .rst(rst));
    dff aluout7(.q(aluout[7]), .d(nop ? 1'b0 : aluout[7]), .wen(write), .clk(clk), .rst(rst));
    dff aluout8(.q(aluout[8]), .d(nop ? 1'b0 : aluout[8]), .wen(write), .clk(clk), .rst(rst));
    dff aluout9(.q(aluout[9]), .d(nop ? 1'b0 : aluout[9]), .wen(write), .clk(clk), .rst(rst));
    dff aluout10(.q(aluout[10]), .d(nop ? 1'b0 : aluout[10]), .wen(write), .clk(clk), .rst(rst));
    dff aluout11(.q(aluout[11]), .d(nop ? 1'b0 : aluout[11]), .wen(write), .clk(clk), .rst(rst));
    dff aluout12(.q(aluout[12]), .d(nop ? 1'b0 : aluout[12]), .wen(write), .clk(clk), .rst(rst));
    dff aluout13(.q(aluout[13]), .d(nop ? 1'b0 : aluout[13]), .wen(write), .clk(clk), .rst(rst));
    dff aluout14(.q(aluout[14]), .d(nop ? 1'b0 : aluout[14]), .wen(write), .clk(clk), .rst(rst));
    dff aluout15(.q(aluout[15]), .d(nop ? 1'b0 : aluout[15]), .wen(write), .clk(clk), .rst(rst));

    dff memsrc0(.q(memsrc[0]), .d(nop ? 1'b0 : memsrc[0]), .wen(write), .clk(clk), .rst(rst));
    dff memsrc1(.q(memsrc[1]), .d(nop ? 1'b0 : memsrc[1]), .wen(write), .clk(clk), .rst(rst));
    dff memsrc2(.q(memsrc[2]), .d(nop ? 1'b0 : memsrc[2]), .wen(write), .clk(clk), .rst(rst));
    dff memsrc3(.q(memsrc[3]), .d(nop ? 1'b0 : memsrc[3]), .wen(write), .clk(clk), .rst(rst));

    dff forwardsrc0(.q(forwardsrc[0]), .d(nop ? 1'b0 : forwardsrc[0]), .wen(write), .clk(clk), .rst(rst));
    dff forwardsrc1(.q(forwardsrc[1]), .d(nop ? 1'b0 : forwardsrc[1]), .wen(write), .clk(clk), .rst(rst));
    dff forwardsrc2(.q(forwardsrc[2]), .d(nop ? 1'b0 : forwardsrc[2]), .wen(write), .clk(clk), .rst(rst));
    dff forwardsrc3(.q(forwardsrc[3]), .d(nop ? 1'b0 : forwardsrc[3]), .wen(write), .clk(clk), .rst(rst));

    wire w_zero;
    dff memwrite(.q(MemWrite), .d(MemWrite), .wen(write), .clk(clk), .rst(rst));
    dff memread(.q(MemRead), .d(MemRead), .wen(write), .clk(clk), .rst(rst));
    dff branch(.q(Branch), .d(Branch), .wen(write), .clk(clk), .rst(rst));
    assign w_zero = (aluout[0] & aluout[1] & aluout[2] & aluout[3] & aluout[4] & aluout[5] & aluout[6] & aluout[7]
                     & aluout[8] & aluout[9] & aluout[10] & aluout[11] & aluout[12] & aluout[13] & aluout[14] & aluout[15])
                     ? 1'b0 : 1'b1;
    dff reg_zero(.q(w_zero), .d(zero), .wen(write), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg), .d(MemToReg), .wen(write), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite), .d(RegWrite), .wen(write), .clk(clk), .rst(rst));
endmodule

module MEMWB(aluout, forwardsrc, memout, MemToReg, RegWrite);
    inout[15:0] aluout, memout;
    inout[3:0] forwardsrc;
    // MEM/WB
    inout MemToReg, RegWrite;

    dff aluout0(.q(aluout[0]), .d(aluout[0]), .wen(write), .clk(clk), .rst(rst));
    dff aluout1(.q(aluout[1]), .d(aluout[1]), .wen(write), .clk(clk), .rst(rst));
    dff aluout2(.q(aluout[2]), .d(aluout[2]), .wen(write), .clk(clk), .rst(rst));
    dff aluout3(.q(aluout[3]), .d(aluout[3]), .wen(write), .clk(clk), .rst(rst));
    dff aluout4(.q(aluout[4]), .d(aluout[4]), .wen(write), .clk(clk), .rst(rst));
    dff aluout5(.q(aluout[5]), .d(aluout[5]), .wen(write), .clk(clk), .rst(rst));
    dff aluout6(.q(aluout[6]), .d(aluout[6]), .wen(write), .clk(clk), .rst(rst));
    dff aluout7(.q(aluout[7]), .d(aluout[7]), .wen(write), .clk(clk), .rst(rst));
    dff aluout8(.q(aluout[8]), .d(aluout[8]), .wen(write), .clk(clk), .rst(rst));
    dff aluout9(.q(aluout[9]), .d(aluout[9]), .wen(write), .clk(clk), .rst(rst));
    dff aluout10(.q(aluout[10]), .d(aluout[10]), .wen(write), .clk(clk), .rst(rst));
    dff aluout11(.q(aluout[11]), .d(aluout[11]), .wen(write), .clk(clk), .rst(rst));
    dff aluout12(.q(aluout[12]), .d(aluout[12]), .wen(write), .clk(clk), .rst(rst));
    dff aluout13(.q(aluout[13]), .d(aluout[13]), .wen(write), .clk(clk), .rst(rst));
    dff aluout14(.q(aluout[14]), .d(aluout[14]), .wen(write), .clk(clk), .rst(rst));
    dff aluout15(.q(aluout[15]), .d(aluout[15]), .wen(write), .clk(clk), .rst(rst));

    dff memout0(.q(memout[0]), .d(memout[0]), .wen(write), .clk(clk), .rst(rst));
    dff memout1(.q(memout[1]), .d(memout[1]), .wen(write), .clk(clk), .rst(rst));
    dff memout2(.q(memout[2]), .d(memout[2]), .wen(write), .clk(clk), .rst(rst));
    dff memout3(.q(memout[3]), .d(memout[3]), .wen(write), .clk(clk), .rst(rst));
    dff memout4(.q(memout[4]), .d(memout[4]), .wen(write), .clk(clk), .rst(rst));
    dff memout5(.q(memout[5]), .d(memout[5]), .wen(write), .clk(clk), .rst(rst));
    dff memout6(.q(memout[6]), .d(memout[6]), .wen(write), .clk(clk), .rst(rst));
    dff memout7(.q(memout[7]), .d(memout[7]), .wen(write), .clk(clk), .rst(rst));
    dff memout8(.q(memout[8]), .d(memout[8]), .wen(write), .clk(clk), .rst(rst));
    dff memout9(.q(memout[9]), .d(memout[9]), .wen(write), .clk(clk), .rst(rst));
    dff memout10(.q(memout[10]), .d(memout[10]), .wen(write), .clk(clk), .rst(rst));
    dff memout11(.q(memout[11]), .d(memout[11]), .wen(write), .clk(clk), .rst(rst));
    dff memout12(.q(memout[12]), .d(memout[12]), .wen(write), .clk(clk), .rst(rst));
    dff memout13(.q(memout[13]), .d(memout[13]), .wen(write), .clk(clk), .rst(rst));
    dff memout14(.q(memout[14]), .d(memout[14]), .wen(write), .clk(clk), .rst(rst));
    dff memout15(.q(memout[15]), .d(memout[15]), .wen(write), .clk(clk), .rst(rst));

    dff memtoreg(.q(MemToReg), .d(MemToReg), .wen(write), .clk(clk), .rst(rst));
    dff regwrite(.q(RegWrite), .d(RegWrite), .wen(write), .clk(clk), .rst(rst));
endmodule
