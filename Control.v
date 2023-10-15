// TODO is there a signal we want when aluop isn't in use?

module control(opcode, regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch, regused);
    input [3:0] opcode;
    output regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch;
    output [3:0] aluop

    // RegWrite, determines if D is written to reg
    // 1 = write to reg, 0 = do no write to reg
    assign regwrite = opcode[3] | (opcode == 4'b1000) | (opcode[3:1] == 3'b101) | (opcode == 4'b1110);

    // compute: 0aaa
    // lw: 1000
    // LLB/LHB: 101a
    // PCS: 1110

    // ALUSrc, determines if reg or imm is sent as input to ALU
    // 1 = use imm as 2nd operand, 0 = use reg as 2nd operand
    assign alusrc = (opcode == 4'b0100) | (opcode == 4'b0101) | (opcode == 4'b0110) | 
                    (opcode == 4'b1000) | (opcode == 4'b1001) |
                    (opcode == 4'b1010) | (opcode == 4'b1011);
 
    // SLL, SRA, ROR (0100, 0101, 0110)
    // LW, SW (1000, 1001)
    // LLB, LHB (1010, 1011)

    // MemRead, effective address is used to read content from meme
    // 1 = use effective address to read from mem, 0 = do not read from mem
    assign memread = opcode == 4'b1000;

    // LW (1000)

    // MemWrite, store register content into the effective register
    // 1 = write to meme, 0 = do not write to mem
    assign memwrite = opcode == 4'b1001;

    // SW (1001)

    // AlUop, determines what operation to pass out the ALU
    // 0 = add, 1 = sub, 2 = xor, 3 = red, 4 = sll, 5 = sra, 6 = ror, 7 = paddsb
    // 8 = llb, 9 = lhb, x = if opcode is neither
    assign aluop = (opcode == 4'b0000) ? 4'b0000 :
                   (opcode == 4'b0001) ? 4'b0001 :
                   (opcode == 4'b0010) ? 4'b0010 :
                   (opcode == 4'b0011) ? 4'b0011 :
                   (opcode == 4'b0100) ? 4'b0100 :
                   (opcode == 4'b0101) ? 4'b0101 :
                   (opcode == 4'b0110) ? 4'b0110 :
                   (opcode == 4'b0111) ? 4'b0111 :
                   (opcode == 4'b1010) ? 4'b1000 :
                   (opcode == 4'b1011) ? 4'b1001 : 4'bxxxx;

    // MemtoReg, determines if output from mem or alu is sent to reg
    // 1 = mem is sent to reg, 0 = alu output is sent to reg
    assign memtoreg = opcode == 4'b1001;

    // SW (1001)

    // Branch, determines what to put into PC 
    // 0 = PC + 2, 1 = (PC + 2) + imm, 2 = rs, 3 = x (halt)
    assign branch = (opcode == 4'b1100) ? 2'b0 :
                    (opcode == 4'b1101) ? 2'b01 :
                    (opcode == 4'b1110) ? 2'b10 :
                    (opcode == 4'b1111) ? 2'b11 : 2'bxx;
endmodule
