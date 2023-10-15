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
  
  // wire for instruction halfword
  wire [15:0] curr_instr;
  // FETCH INSTRUCTION
  memory1c instr_mem (.data_out(curr_instr), .data_in(), .addr(pc_curr), .enable, .wr(), .clk(clk), .rst(rstn));
  
  // control wires
  wire regwrite;
  wire alusrc;
  wire memread;
  wire memwrite;
  wire [3:0] aluop;
  wire memtoreg;
  wire [1:0] branch;
  wire regused;
  
  // CONTROL UNIT
  control control_unit (.opcode(curr_instr[15:12]), .regwrite(regwrite), .alusrc(alusrc), .memread(memread), .memwrite(memwrite),
                        .aluop(aluop), .memtoreg(memtoreg), .branch(branch), .regused(regused));

  // REGISTER FILE
  // we need to handle invalid read registers
  // also which registers do we know to use? does it work out?
  // we need the 0 register
  RegisterFile register_file (.clk(clk), .rst(rstn), .SrcReg1(), .SrcReg2(), .DstReg(), .WriteReg(), .DstData(), .SrcData1(), .SrcData2());

  // branch
  //is done here, wire in control unit, flag bits and make sure to sll imediate by 1
  pc_control pc_branch (.bsig(branch), .C(), .I(), .F(), .regsrc(), .PC_in(), .PC_out());

  wire v;
  wire alu_in1;
  wire alu_in2;
  wire alu_out;
  // control ALU mux for rs or imm value
  // ALU
  alu alu (.aluin1(), .aluin2(), .opcode(aluop), .aluout(alu_out), .err(v))

  // FLAG

  // is there no mux after alu into mem?
  
  wire mem_out;
  // ALU wires to memory and memory takes in 2 control unit signals, read or write
  // MEM
  memory1c mem (.data_out(mem_out), .data_in(x), .addr(pc_curr), .enable(memread), .wr(memwrite), .clk(clk), .rst(rstn));
  
  // memory and ALU wires to mux and is controlled by cu signal, and wires to register file
  // WRITEBACK MUX
  
endmodule
