// pc_control.v

// pc contorl for all branch conditions
module pc_control (bsig, C, I, F, regsrc, PC_in, PC_out, taken);
  //inputs
  input [1:0] bsig; // 00 = PC + 2, 01 = PC + 2 + I, 10 = regsrc, 11 = HLT
  input [2:0] C, F; // C ccc, F flag reg
  input [9:0] I; // I immediate
  input [15:0] regsrc, PC_in; // regsrc rs reg, PC_in curr PC

  //output
  output [15:0] PC_out; // PC_out updated PC
  output taken;


  // Can branch? (ccc is fufilled)
  reg truth;

  // ternary for deciding which branch instruction
  // 000 not equal (Z = 0)
  // 001 equal (z = 1)
  // 010 greater than (Z = N = 0)
  // 011 Less Than (N = 1) 
  // 100 Greater Than or Equal (Z = 1 or Z = N = 0)
  // 101 Less Than or Equal (N = 1 or Z = 1)
  // 110 Overflow (V = 1)
  // 111 Unconditional
  // F = NVZ

  always @(*) begin
    case (C)
      3'b000: truth = ~F[0];
      3'b001: truth = F[0];
      3'b010: truth = ~F[0] & ~F[2];
      3'b011: truth = F[2];
      3'b100: truth = F[0] & (~F[0] & ~F[2]);
      3'b101: truth = F[0] | F[2];
      3'b110: truth = F[1];
      3'b111: truth = 1;
    endcase
  end
  assign taken = truth & (bsig == 2'b01 | bsig == 2'b10);

  assign br_truth = truth;

  wire [15:0] signext_imm;
  assign signext_imm = I[9] ? {6'b111111, I[9:0]} : {6'b000000, I[9:0]};

  wire [15:0] sub2;
  wire [15:0] b_out;
  wire ovfl2;
  wire ovfl_add;
  reg [15:0] out;

  carry_lookahead add_two(.sum(sub2), .overflow(ovfl2), .a(PC_in), .b(16'h0002), .mode(1'b1));
  carry_lookahead add_opt(.sum(b_out), .overflow(ovfl_add), .a(PC_in), .b(signext_imm), .mode(1'b0));

  // case statement for branch signal
  // 00: no branch, 01: b, 10: br, 11: hlt
  // must evaluate whether branching is true or not, if it isnt we just run the sum2
  always @(*) begin
    case (bsig)
      2'b00: out = PC_in;
      2'b01: out = truth ? b_out: PC_in;
      2'b10: out = truth ? regsrc: PC_in;
      2'b11: out = sub2;
    endcase
  end
  
  assign PC_out = out;
endmodule