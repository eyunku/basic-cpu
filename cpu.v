module cpu (clk, rst_n, hlt, pc);
    input clk, rst_n;
    output [15:0] pc;
    output hlt;

    // wires for FETCH
    // pc reg wires
    wire [15:0] pc_in, pc_out;
    // instruction memory wires
    wire [15:0] instruction;

    // wires for CONTROL UNIT
    wire [3:0] opcode;
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [1:0] branch;
    wire [3:0] aluop;

    // wires for DECODE
    // reg wires
    wire [3:0] SrcReg1, SrcReg2, DstReg;
    wire [15:0] DstData, SrcData1, SrcData2;

    // sext wires
    wire [15:0] imm_4bit;
    wire [15:0] imm_8bit;
    wire [15:0] imm_16bit;

    // pc control wires
    wire [9:0] I;
    wire [2:0] C, F;

    // wires for EXECUTION
    // wires for alu
    wire [15:0] aluin1, aluin2;
    wire [15:0] aluout, alutomem, alutowb;
    wire err;

    // wires for flag reg
    wire [2:0] flag_in;
    wire [2:0] flag_out;

    // wires for MEMORY
    wire [15:0] mem;

    // wire for WB
    wire [15:0] pcs;

    // FETCH
    pc_reg pc_reg (
        .clk(clk), 
        .rst(rst_n), 
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    instruction_memory instruction_mem (
        .data_out(instruction), 
        .data_in(), 
        .addr(pc_out), 
        .enable(1), 
        .wr(0), 
        .clk(clk), 
        .rst(rst_n)
    );
    // END OF FETCH

    // CONTROL UNIT
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

    // set hlt bit
    assign hlt = branch == 2'b11;
    // END OF CONTROL UNIT

    // DECODE
    // dst and src reg assignment
    assign DstReg = instruction[11:8];
    assign SrcReg1 = rdsrc ? DstReg : instruction[7:4]; // LLB + LHB case
    assign SrcReg2 = instruction[3:0];

    // Sext unit here
    assign imm_4bit = instruction[3] ? {12'hFFF, instruction[3:0]} : {12'b0, instruction[3:0]};
    assign imm_8bit = {8'b0, instruction[7:0]};
    assign imm_16bit = alusext ? imm_8bit : imm_4bit;

    RegisterFile registerfile (
        .clk(clk), 
        .rst(rst_n), 
        .SrcReg1(SrcReg1), 
        .SrcReg2(SrcReg2), 
        .DstReg(DstReg), 
        .WriteReg(regwrite), 
        .DstData(DstData), 
        .SrcData1(SrcData1), 
        .SrcData2(SrcData2)
    );

    // PC control
    assign C = instruction[11:9];
    assign I = instruction[8:0] << 1;
    assign F = {n_out, v_out, z_out};

    pc_control pc_control (
        .bsig(branch), 
        .C(C), 
        .I(I), 
        .F(F), 
        .regsrc(SrcReg1), 
        .PC_in(pc_out), 
        .PC_out(pc_in)
    );
    // END OF DECODE

    // TODO will need to determine placement of flag register in stages
    // EXECUTION
    assign aluin1 = SrcReg1;
    assign aluin2 = alusrc ? imm_16bit : SrcReg2;

    alu alu(
        .aluin1(aluin1), 
        .aluin2(aluin2), 
        .aluop(aluop), 
        .aluout(aluout), 
        .err(err)
    );

    flag_reg FLAG (
        .clk(clk), 
        .rst(rst_n), 
        .write(3'b111), 
        .in(flag_in), 
        .flag_out(flag_out)
    );

    // Update flags
    // TODO make this a signal
    assign flag_in[2] n_in = (aluop == 3'h1 | aluop == 3'h0) ? aluout[15] : n_out;
    assign flag_in[1] v_in = (aluop == 3'h1 | aluop == 3'h0) ? err : v_out;
    assign flag_in[0] z_in = (aluop == 3'h1 | aluop == 3'h0 | aluop == 3'h2 | aluop == 3'h3 | aluop == 3'h4 | aluop == 3'h5 | aluop == 3'h6) ? (aluout == 16'h0000) : z_out;
    // END OF EXECUTION

    // MEMORY
    assign alutomem = aluout;
    assign alutowb = aluout;

    main_memory cpu_memory (
        .data_out(mem), 
        .data_in(SrcData1), 
        .addr(alutomem), 
        .enable(memenable), 
        .wr(memwrite), 
        .clk(clk), 
        .rst(rst_n)
    );
    // END OF MEMORY
    
    // WRITEBACK
    full_adder a0 (.a(pc_out), .b(16'h0002), .cin(0), .s(pcs));
    assign DstData = pcread ? pcs : (memtoreg ? mem : alutowb);
    // END OF WRITEBACK
endmodule