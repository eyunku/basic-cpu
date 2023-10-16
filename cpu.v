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
  // initialize instruction memory how????

  reg [15:0] curr_pc;
  assign curr_pc = rst_n ? 16'b0 : curr_pc;
  // wire for instruction halfword
  wire [15:0] instrget;
  wire [15:0] curr_instr;
  // FETCH INSTRUCTION
  memory1c instr_mem (.data_out(instrget), .data_in(), .addr(pc_curr), .enable(0), .wr(0), .clk(clk), .rst(rstn));
  assign curr_instr = rst_n ? 16'b0 : instrget;
  // END OF FETCH INSTRUCTION
  
  // CONTROL UNIT
  control control_unit (.opcode(curr_instr[15:12]), .regwrite(regwrite), .alusrc(alusrc), .memread(memread), .memwrite(memwrite),
                        .aluop(aluop), .memtoreg(memtoreg), .branch(branch), .alusext(alusext));
  // control wires
  wire regwrite;
  wire alusrc;
  wire memread;
  wire memwrite;
  wire [3:0] aluop;
  wire memtoreg;
  wire [1:0] branch;
  wire alusext;
  // END OF CONTROL UNIT

  // REGISTER FILE
  // handle invalid read registers set to z
  // pls implement the 0 register
  RegisterFile register_file (.clk(clk), .rst(rstn), .SrcReg1(src1_register), .SrcReg2(src2_register), .DstReg(curr_instr[15:12]),
                              .WriteReg(writereg), .DstData(dstdata), .SrcData1(srcdata1), .SrcData2(srcdata2));
  // logic for mem-write signal (store word will have different registers)
  wire [3:0] src2_register;
  wire [3:0] src1_register;
  assign src1_register = sext ? curr_instr[11:8] : curr_instr[7:4];          // LLB and LHB case requires src1 to be the read and write
  assign src2_register = memwrite ? curr_instr[11:8] : curr_instr[3:0];      // only store word case
  wire writereg;                                      // for any kind of write command
  assign writereg = regwrite | memwrite | memtoreg;
  wire [15:0] dstdata;                                // destination data will be wired later
  wire [15:0] srcdata1, srcdata2;                     // outputs of the read instruction
  // END OF REGISTER FILE
  
  // PC CONTROL
  // is done here, wire in control unit, flag bits and make sure to shift imediate by 1
  pc_control pc_controller (.bsig(branch), .C(curr_instr[11:9]), .I({curr_instr[7:0], 1'b0}), .F(flag_bits), .regsrc(curr_instr[7:4]),
                        .PC_in(curr_pc), .PC_out(curr_pc));
  // END OF PC CONTROL

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
