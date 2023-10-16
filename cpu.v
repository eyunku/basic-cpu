'include "memory.v"
'include "register.v"
'include "alu.v"
'include "pc_control.v"

// cpu.v
// this module is the main all encompassing module, this module will:
// invoke the fetch instruction
// pass the instruction to the decoder and register file
// pass the information into the control unit and the results will be wired into ALU, Mem, and writeback mux, 
// deals with the flag bits and sets the registers we will wire this to the branch when necessary
// 

module cpu (input clk, input rst_n, output hlt, output [15:0] pc);
  // FLAG REGISTER
  wire n_in, v_in, z_in;
  wire n_out, v_out, z_out;
  // TODO figure out write conditions, set it to clk?
  flag_reg FLAG (.clk(clk), .rst(rst_n), .n_write(1), .v_write(1), .z_write(1),  .n_in(n_in),  .v_in(v_in),  .z_in(z_in),  .n_out(n_out),  .v_out(v_out),  .z_out(z_out));

  // REGISTER
  wire [3:0] SrcReg1, SrcReg2, DstReg;
  wire [15:0] DstData, SrcData1, SrcData2;

  assign DstReg = instruction[11:8];
  // Handling for LLB and LHB
  assign SrcReg1 = (instruction[15:11] == 4'b1010 | instruction[15:11] == 4'b1011) ? DstReg : instruction[7:4];
  assign SrcReg2 = instruction[3:0];

  RegisterFile registerfile (.clk(clk), .rst(rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(regwrite), .DstData(DstData), .SrcData1(SrcData1), .SrcData2(SrcData2));
  // END OF REGISTER

  // PC REG + PC CONTROL
  // TODO figure out pc_write state
  // for PC
  wire [15:0] pc_in, pc_out;
  
  // for pc_control
  wire [9:0] I;
  wire [2:0] C, F;

  assign I = instruction[8:0] << 1; // get offset
  assign C = instruction[11:9]; // get condition code from instruction
  assign F = {n_out, v_out, z_out};

  // TODO add regsrc after completing decode
  // TODO figure out PCS
  pc_reg pc_reg (.clk(clk), .rst(rst_n), .pc_write(1), .pc_read(pcread), .pc_in(pc_in), .pc_out(pc_out));
  pc_control pc_control (.bsig(branch), .C(C), .I(I), .F(F), .regsrc(SrcReg1), .PC_in(pc_out), .PC_out(pc_in));
  // END OF PC REG + PC CONTROL

  // FETCH
  // TODO figure out rst_n interaction with memory
  wire [15:0] instruction;
  memory1c instr_mem (.data_out(instruction), .data_in(), .addr(pc_out), .enable(1), .wr(0), .clk(clk), .rst(rst_n));
  // END OF FETCH

  // CONTROL UNIT
  wire [3:0] opcode;
  wire regwrite, alusrc, memread, memwrite, memtoreg, pcread;
  wire [1:0] branch;
  wire [2:0] alusext;
  wire [3:0] aluop;
  control control_unit (.opcode(opcode), .regwrite(regwrite), .alusrc(alusrc), .memread(memread), .memwrite(memwrite), .aluop(aluop), .memtoreg(memtoreg), .branch(branch), .alusext(alusext), .pcread(pcread));
  // END OF CONTROL UNIT

  // DECODE STAGE
  wire [15:0] aluin1, aluin2;

  // imm value handling
  wire [15:0] imm_4bit;
  wire [15:0] imm_8bit;
  wire [15:0] imm_16bit;
  // sext imm
  assign imm_4bit = instruction[3] ? {12'hFFF, curr_instr[3:0]} : {12'b0, curr_instr[3:0]};
  assign imm_8bit = {8'b0, curr_instr[7:0]};
  // determine imm value to pass in
  assign imm_16bit = ALUSext ? imm_8bit : imm_4bit;

  // ALUin1
  assign aluin1 = SrcReg1;
  // ALUin2
  assign aluin2 = alusrc ? imm_16bit : SrcReg2;
  // END OF DECODE STAGE

  // EXECUTION STAGE
  wire [15:0] aluout, alutomem, alutowb;
  wire err;
  alu alu(.aluin1(aluin1), .aluin2(aluin2), .aluop(aluop), .aluout(aluout), .err(err));
  
  // Flags
  reg [2:0] flag;
  wire n, z, v;
  assign n = aluout[15];
  assign z = aluout == 16'h0000;
  assign v = err;

  always @(*) begin
    case(aluop):
      3'h0: begin
        flag[0] = z;
        flag[1] = v;
        flag[2] = n;
      end
      3'h1: begin
        flag[0] = z;
        flag[1] = v;
        flag[2] = n;
      end
      3'h2: flag[0] = z;
      3'h4: flag[0] = z;
      3'h5: flag[0] = z;
      3'h6: flag[0] = z;
      default: flag = 3'b00;
    endcase
  end

  // Seperate ALU and effective address
  assign alutomem = aluout;
  assign alutowb = aluout;
  // END OF EXECUTION STAGE

  // ALU
  // recieves src1 always
  // mux for src2 and signext imm
  alu alu (.aluin1(srcdata1), .aluin2(alu_in2), .opcode(aluop), .aluout(alu_out), .err(v))
  wire [15:0] alu_in2;
  wire [15:0] alu_out;
  wire s;
  assign s = curr_instr[3];
  // control ALU mux for rs or imm value
  assign alu_in2 = alusrc ? (alusext ? {s,s,s,s,s,s,s,s, curr_instr[7:0]} : {s,s,s,s,s,s,s,s,s,s,s,s, curr_instr[3:0]}) :
    srcdata2;
  // END OF ALU

  // FLAG CONTROL
  flag_reg flag_controller (.clk(clk), .rst(rst),
                            .n_write(1), .v_write(1), .z_write(1),
                            .n_in(n), .v_in(v), .z_in(z),
                            .n_out(n_out), .v_out(v_out), .z_out(z_out));
  wire [2:0] flag_bits; // flag_bits is the output 
  wire n;
  wire v;
  wire z;
  wire n_out;
  wire v_out;
  wire z_out;
  assign n = alu_out[15];
  assign z = alu_out == 16'b0;
  assign flag_bits = {n_out, v_out, z_out};
  // END OF FLAG CONTROL
  
  // MEM
  memory1c mem (.data_out(mem_out), .data_in(srcdata2), .addr(alu_out), .enable(memread), .wr(memwrite), .clk(clk), .rst(rstn));
  wire mem_out;
  // memory and ALU wires to mux and is controlled by cu signal, and wires to register file
  // END OF MEM
  
  // WRITEBACK MUX
  wire writebackdata;
  assign writebackdata = memtoreg ? mem_out: alu_out;
  // END OF WRITEBACK MUX

  // stagewise status output
  assign hlt = branch == 2'b11;
  assign pc = curr_pc;
endmodule
