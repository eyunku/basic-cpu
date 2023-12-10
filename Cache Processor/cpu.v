`include "dff.v"
`include "register.v" 
`include "alu.v"
`include "control.v"
`include "flag.v"
`include "memory.v"
`include "pc_control.v"
`include "pc_register.v"
`include "pipe_register.v"
`include "forwarding_logic.v"
`include "hazard_detection.v"

`include "if.v"
`include "id.v"
`include "ex.v"
`include "mem.v"
`include "wb.v"
`include "pipe.v"

`include "cache_arbitration.v"
`include "cache_controller.v"
`include "cache.v"
`include "array_helpers.v"
`include "metadata_array.v"
`include "data_array.v"
`include "multicycle_memory.v"

module mod_CPU (
        input clk, rst_n,
        output hlt,
        output [15:0] pc);

    // ==== FETCH stage wires ====

    wire freeze_ID;
    wire nop_ID;
    wire taken_ID;
    // pc reg wires
    wire rst = ~rst_n;
    wire [15:0] pc_in_ID, pc_out_IF;
    // instruction memory wires
    wire [15:0] instruction_IF;

    // pipeline wires
    wire flag_en_ID;
    wire [15:0] instruction_ID, pc_out_ID;

    // ==== DECODE stage wires ====

    // wires for CONTROL UNIT
    wire regwrite_ID, alusrc_ID, memenable_ID, memwrite_ID, memtoreg_ID, pcread_ID, alusext_ID, rdsrc_ID, halt_ID;
    wire [1:0] branch_ID;
    wire [3:0] aluop_ID;

    // wires for DECODE
    // reg wires
    wire [3:0] SrcReg1_ID, SrcReg2_ID, DstReg_out_ID;
    wire [15:0] SrcData1_ID, SrcData2_ID;
    wire [15:0] imm_16bit_ID;
    wire [15:0] DstData_WB;

    // Hazard Unit
    wire fd_memwrite;
    wire dx_memread;
    wire stall_sig;

    // pipeline wires
    wire alusrc_EX, regwrite_EX, memenable_EX, memwrite_EX, memtoreg_EX, pcread_EX, halt_EX;
    wire [1:0] branch_EX;
    wire [3:0] aluop_EX;

    // Wires for forwarding + data hazard unit
    wire flag_en_EX;
    wire [3:0] SrcReg1_EX, SrcReg2_EX;

    wire [3:0] DstReg_EX;
    wire [15:0] SrcData1_EX, SrcData2_EX, imm_16bit_EX, pc_EX;

    // ==== EXECUTION stage wires ====

    // wires for flag reg
    wire [2:0] flag_out;
    // wires for alu
    wire [15:0] aluout_EX;

    // fowarding wires
    wire forward_mm;
    wire [1:0] forward_aluin1, forward_aluin2;

    // pipeline registers
    wire regwrite_MEM, memenable_MEM, memwrite_MEM, memtoreg_MEM, halt_MEM;
    wire [3:0] SrcReg1_MEM, SrcReg2_MEM, DstReg_MEM;
    wire [15:0] SrcData2_MEM, aluout_MEM, pc_MEM;

    // ==== MEMORY stage wires ====
    wire [15:0] mem;

    // pipeline wires
    wire regwrite_WB, memtoreg_WB, halt_WB;
    wire [3:0] DstReg_WB;
    wire [15:0] aluout_WB, mem_WB, pc_WB;


    // ==== FETCH module START ====

    mod_F mod_f(
        .clk(clk),
        .rst(rst),
        .freeze(freeze_ID),
        .taken(taken_ID),
        .branch(branch_ID),
        .pc_in(pc_in_ID),
        .pc_curr(pc),  // current PC
        .pc_curr2(pc_out_IF), // current PC + 2
        .instruction(instruction_IF)
    );
    
    // ==== FETCH module END ====

    // ==== IF/ID Pipeline Register START ====

    IF_ID_pipe if_id_pipe(
        .clk(clk),
        .rst(rst),
        .flush(taken_ID), // TODO: for branch not taken
        .flag_en_ID(flag_en_ID),
        .freeze(freeze_ID), // for stalls
        .inst_i(instruction_IF), .inst_o(instruction_ID),
        .pc_i(pc_out_IF), .pc_o(pc_out_ID));

    // ==== IF/ID Pipeline Register END ====

    // ==== DECODE module START ====

    // module for decode stage
    mod_ID mod_id(
        .clk(clk),
        .rst(rst),
        .flag_en(flag_en_ID),
        .flag(flag_out),
        .DstReg_in(DstReg_WB), // hanging
        .instruction(instruction_ID),
        .pc(pc_out_ID),
        .DstData(DstData_WB),
        .regwrite_wb(regwrite_WB),
        .regwrite(regwrite_ID),
        .alusrc(alusrc_ID),
        .memenable(memenable_ID),
        .memwrite(memwrite_ID),
        .memtoreg(memtoreg_ID),
        .pcread(pcread_ID),
        .rdsrc(rdsrc_ID),
        .halt(halt_ID),
        .branch(branch_ID),
        .aluop(aluop_ID),
        .SrcReg1(SrcReg1_ID),
        .SrcReg2(SrcReg2_ID),
        .DstReg_out(DstReg_out_ID),
        .SrcData1(SrcData1_ID),
        .SrcData2(SrcData2_ID),
        .new_pc(pc_in_ID),
        .imm_16bit(imm_16bit_ID),
        .taken(taken_ID)
    );


    assign fd_memwrite = memenable_ID & memwrite_ID;
    assign dx_memread = (memenable_EX & ~memwrite_EX);

    hazard_unit hazard (
        .fd_memwrite(fd_memwrite), 
        .fd_regwrite(regwrite_ID), 
        .fd_alusrc(alusrc_ID), 
        .fd_branchtaken(taken_ID), 
        .dx_memread(dx_memread), 
        .dx_regwrite(regwrite_EX), 
        .xm_regwrite(regwrite_MEM), 
        .branch(branch_ID), 
        .fd_rs(SrcReg1_ID), 
        .fd_rt(SrcReg2_ID), 
        .dx_rd(DstReg_EX), 
        .xm_rd(DstReg_MEM), 
        .fd_opcode(instruction_ID[3:0]), 
        .stall_sig(stall_sig)
    );

    assign freeze_ID = stall_sig;
    assign nop_ID = stall_sig;

    // ==== DECODE module END ====

    // ==== ID/EX Pipeline Register START ====

    ID_EX_pipe id_ex_pipe(
        .clk(clk),
        .rst(rst),
        .flush(nop_ID), // for stalls
        .flag_en_ID(flag_en_ID),
        .flag_en_EX(flag_en_EX),
        .alusrc_i(alusrc_ID), .alusrc_o(alusrc_EX),
        .regwrite_i(regwrite_ID), .regwrite_o(regwrite_EX),
        .memenable_i(memenable_ID), .memenable_o(memenable_EX),
        .memwrite_i(memwrite_ID), .memwrite_o(memwrite_EX),
        .memtoreg_i(memtoreg_ID), .memtoreg_o(memtoreg_EX),
        .pcread_i(pcread_ID), .pcread_o(pcread_EX),
        .halt_i(halt_ID), .halt_o(halt_EX),
        .branch_i(branch_ID), .branch_o(branch_EX),
        .aluop_i(aluop_ID), .aluop_o(aluop_EX),
        .SrcReg1_i(SrcReg1_ID), .SrcReg1_o(SrcReg1_EX),
        .SrcReg2_i(SrcReg2_ID), .SrcReg2_o(SrcReg2_EX),
        .DstReg_i(DstReg_out_ID), .DstReg_o(DstReg_EX),
        .SrcData1_i(SrcData1_ID), .SrcData1_o(SrcData1_EX),
        .SrcData2_i(SrcData2_ID), .SrcData2_o(SrcData2_EX),
        .imm_16bit_i(imm_16bit_ID), .imm_16bit_o(imm_16bit_EX)
    );

    // ==== ID/EX Pipeline Register END ====

    // ==== EXECUTION module START ====

    mod_EX mod_ex(
        .clk(clk),
        .rst(rst),
        .alusrc(alusrc_EX),
        .memenable(memenable_EX),
        .pcread(pcread_EX),
        .branch(branch_EX),
        .flag_en(flag_en_EX),
        .forward_aluin1(forward_aluin1),
        .forward_aluin2(forward_aluin2),
        .aluop(aluop_EX),
        .forward_DstData_MEM(aluout_MEM),
        .forward_DstData_WB(DstData_WB),
        .SrcData1(SrcData1_EX),
        .SrcData2(SrcData2_EX),
        .imm_16bit(imm_16bit_EX),
        .aluout(aluout_EX),
        .flag_new(flag_out)
    );

    forwarding_unit forward(
        .xm_regwrite(regwrite_MEM),
        .xm_memwrite(memenable_MEM & memwrite_MEM),
        .mw_regwrite(regwrite_WB),
        .xm_rd(DstReg_MEM),
        .xm_rt(SrcReg2_MEM),
        .mw_rd(DstReg_WB),
        .dx_rs(SrcReg1_EX),
        .dx_rt(SrcReg2_EX),
        .forwardmm(forward_mm),
        .forwarda(forward_aluin1),
        .forwardb(forward_aluin2)
    );

    // ==== EXECUTION module END ====

    // ==== EX/MEM Pipeline Register START ====

    EX_MEM_pipe ex_mem_pipe(
        .clk(clk),
        .rst(rst),
        .regwrite_i(regwrite_EX), .regwrite_o(regwrite_MEM),
        .memenable_i(memenable_EX), .memenable_o(memenable_MEM),
        .memwrite_i(memwrite_EX), .memwrite_o(memwrite_MEM),
        .memtoreg_i(memtoreg_EX), .memtoreg_o(memtoreg_MEM),
        .halt_i(halt_EX), .halt_o(halt_MEM),
        .SrcReg1_i(SrcReg1_EX), .SrcReg1_o(SrcReg1_MEM),
        .SrcReg2_i(SrcReg2_EX), .SrcReg2_o(SrcReg2_MEM),
        .DstReg_i(DstReg_EX), .DstReg_o(DstReg_MEM),
        .SrcData2_i(SrcData2_EX), .SrcData2_o(SrcData2_MEM),
        .aluout_i(aluout_EX), .aluout_o(aluout_MEM));

    // ==== EX/MEM Pipeline Register END ====

    // ==== MEMORY module START ====

    mod_MEM mod_mem(
        .clk(clk),
        .rst(rst),
        .memenable(memenable_MEM),
        .memwrite(memwrite_MEM),
        .forward_mm(forward_mm),
        .memdata(SrcData2_MEM),
        .memdata_forward(DstData_WB),
        .addr(aluout_MEM),
        .mem_out(mem));
    
    // ==== MEMORY module END ====

    // ==== MEM/WB Pipeline Register START ====

    MEM_WB_pipe mem_wb_pipe(
        .clk(clk),
        .rst(rst),
        .regwrite_i(regwrite_MEM), .regwrite_o(regwrite_WB),
        .memtoreg_i(memtoreg_MEM), .memtoreg_o(memtoreg_WB),
        .halt_i(halt_MEM), .halt_o(halt_WB),
        .DstReg_i(DstReg_MEM), .DstReg_o(DstReg_WB),
        .aluout_i(aluout_MEM), .aluout_o(aluout_WB),
        .mem_i(mem), .mem_o(mem_WB));

    // ==== MEM/WB Pipeline Register END ====

    // ==== WB module START ====

    mod_WB mod_wb(
        .memtoreg(memtoreg_WB),
        .alutowb(aluout_WB),
        .mem(mem_WB),
        .DstData(DstData_WB));

    // set hlt bit
    assign hlt = halt_WB;

    // ==== WB module END ====
endmodule