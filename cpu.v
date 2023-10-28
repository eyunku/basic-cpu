// cpu.v
// this module is the main all encompassing module, this module will:
// invoke the fetch instruction
// pass the instruction to the decoder and register file
// pass the information into the control unit and the results will be wired into ALU, Mem, and writeback mux, 
// deals with the flag bits and sets the registers we will wire this to the branch when necessary
// 

module cpu (clk, rst_n, hlt, pc);
  input clk, rst_n;
  output [15:0] pc;
  output hlt;

  // wires for FLAG REGISTER
  wire n_in, v_in, z_in;
  wire n_out, v_out, z_out;

  // wires for REGISTER
  wire [3:0] SrcReg1, SrcReg2, DstReg;
  wire [15:0] DstData, SrcData1, SrcData2;

  // wire for PC
  wire [15:0] pc_in, pc_out;

  // wire for PC CONTROL
  wire [9:0] I;
  wire [2:0] C, F;

  // wire for FETCH
  wire [15:0] instruction;

  // wire for CONTROL UNIT
  wire [3:0] opcode;
  wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
  wire [1:0] branch;
  wire [3:0] aluop;

  // wire for DECODE
  wire [15:0] aluin1, aluin2;

  // wire for imm handling in DECODE
  wire [15:0] imm_4bit;
  wire [15:0] imm_8bit;
  wire [15:0] imm_16bit;

  // wire for EXECUTION
  wire [15:0] aluout, alutomem, alutowb;
  wire err;

  // wire for Flags in EXECUTION
  reg [2:0] flag;
  reg [2:0] flag_out;
  
  // wire for MEMORY
  wire [15:0] mem;

  // wire for PCS
  wire [15:0] pcs;
  
  // FLAG REGISTER
  // TODO figure out write conditions, set it to clk?
  flag_reg FLAG (.clk(clk), .rst(rst_n), .write(3'b111),  .in(flag),  .flag_out(flag_out));

  // REGISTER
  assign DstReg = instruction[11:8];
  // Handling for LLB and LHB
  assign SrcReg1 = rdsrc ? DstReg : instruction[7:4];
  assign SrcReg2 = instruction[3:0];

  RegisterFile registerfile (.clk(clk), .rst(rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(regwrite), .DstData(DstData), .SrcData1(SrcData1), .SrcData2(SrcData2));
  // END OF REGISTER

  // PC REG + PC CONTROL
  // TODO figure out pc_write state

  assign I = instruction[8:0] << 1; // get offset
  assign C = instruction[11:9]; // get condition code from instruction
  assign F = {n_out, v_out, z_out};

  pc_reg pc_reg (.clk(clk), .rst(rst_n), .pc_write(1), .pc_read(pcread), .pc_in(pc_in), .pc_out(pc_out));
  pc_control pc_control (.bsig(branch), .C(C), .I(I), .F(F), .regsrc(SrcReg1), .PC_in(pc_out), .PC_out(pc_in));
  // END OF PC REG + PC CONTROL

  // FETCH
  instruction_memory instruction_mem (.data_out(instruction), .data_in(), .addr(pc_out), .enable(1), .wr(0), .clk(clk), .rst(rst_n));
  // END OF FETCH

  // CONTROL UNIT
  control control_unit (.opcode(opcode), .regwrite(regwrite), .alusrc(alusrc), .memenable(memenable), .memwrite(memwrite), .aluop(aluop), .memtoreg(memtoreg), .branch(branch), .alusext(alusext), .pcread(pcread), .rdsrc(rdsrc));
  // END OF CONTROL UNIT

  // DECODE STAGE
  // sext imm
  assign imm_4bit = instruction[3] ? {12'hFFF, instruction[3:0]} : {12'b0, instruction[3:0]};
  assign imm_8bit = {8'b0, instruction[7:0]};
  // determine imm value to pass in
  assign imm_16bit = alusext ? imm_8bit : imm_4bit;

  // ALUin1
  assign aluin1 = SrcReg1;
  // ALUin2
  assign aluin2 = alusrc ? imm_16bit : SrcReg2;
  // END OF DECODE STAGE

  // EXECUTION STAGE
  alu alu(.aluin1(aluin1), .aluin2(aluin2), .aluop(aluop), .aluout(aluout), .err(err));
  
  // Flags
  // TODO create a signal bit to indicate if ALUop caused a flag bit, avoid creating case statements like these 
  assign n_flag = aluout[15];
  assign z_flag = aluout == 16'h0000;
  assign v_flag = err;
  always @(*) begin
    case(aluop)
      3'h0: begin
        flag[0] = z_flag;
        flag[1] = v_flag;
        flag[2] = n_flag;
      end
      3'h1: begin
        flag[0] = z_flag;
        flag[1] = v_flag;
        flag[2] = n_flag;
      end
      3'h2: flag[0] = z_flag;
      3'h4: flag[0] = z_flag;
      3'h5: flag[0] = z_flag;
      3'h6: flag[0] = z_flag;
      default: flag = 3'b00;
    endcase
  end
  assign n_in = flag[2];
  assign v_in = flag[1];
  assign z_in = flag[0];

  // Seperate ALU and effective address
  assign alutomem = aluout;
  assign alutowb = aluout;
  // END OF EXECUTION STAGE

  // MEMORY STAGE
  main_memory cpu_memory (.data_out(mem), .data_in(SrcData1), .addr(alutomem), .enable(memenable), .wr(memwrite), .clk(clk), .rst(rst_n));
  // END OF MEMORY STAGE

  // WRITEBACK STAGE
  full_adder a0 (.a(pc_out), .b(16'h0002), .cin(0), .s(pcs));
  assign DstData = pcread ? pcs : (memtoreg ? mem : alutowb);
  // END OF WRITEBACK STAGE

  // stagewise status output
  assign hlt = branch == 2'b11;
endmodule
