'include "memory.v"

// cpu.v
// this module is the main all encompassing module, this module will:
// invoke the fetch instruction
// pass the instruction to the decoder and register file
// pass the information into the control unit and the results will be wired into ALU, Mem, and writeback mux, 
// deals with the flag bits and sets the registers we will wire this to the branch when necessary
// 

module cpu (input clk, input rst_n, output hlt, output [15:0] pc);
  // initialize instruction memory
  wire curr_instr;
  memory1c instr (.data_out(curr_instr), .data_in(x), .addr(pc_curr), .enable, .wr(), .clk(clk), .rst(rstn));
  // wire for instruction halfword
  // invoke fetch

  // wire for register 1 and 2 output, and opcode
  // wire instruction to decode
  // invoking decode, which will wire to the register file

  // wire opcode to control unit
  // wire control unit outputs to many locations, like ALU, Mem, and writeback mux

  // branching is done here, wire in control unit, flag bits, 
  
  // control ALU mux for rs or imm value
  // wire registers to ALU 

  // change flag bits

  // ALU wires to memory and memory takes in 2 control unit signals, read or write

  // memory and ALU wires to mux and is controlled by cu signal, and wires to register file
endmodule
