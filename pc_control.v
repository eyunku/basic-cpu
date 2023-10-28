// pc_control.v

// pc contorl for all branch conditions
module pc_control (input [1:0] bsig, input [2:0] C, input [9:0] I, input [2:0] F, input [15:0] regsrc, input [15:0] PC_in, output [15:0] PC_out);

  // wires for all your diff branches
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


  wire [15:0] signext_imm;
  assign signext_imm = I[9] ? {6'b111111, I[9:0]} : {6'b000000, I[9:0]};

  wire [15:0] sum2;
  wire [15:0] b_out;
  wire ovfl2;
  wire ovfl_add;
  reg [15:0] out;

  carry_lookahead add_two(.sum(sum2), .overflow(ovfl2), .a(PC_in), .b(16'h0002), .mode(0));
  carry_lookahead add_opt(.sum(b_out), .overflow(ovfl_add), .a(sum2), .b(signext_imm), .mode(0));

  // case statement for branch signal
  // 00: no branch, 01: b, 10: br, 11: hlt
  // must evaluate whether branching is true or not, if it isnt we just run the sum2
  always @(*) begin
    case (bsig)
      2'b00: out = sum2;
      2'b01: out = truth ? b_out: sum2;
      2'b10: out = truth ? regsrc: sum2;
      2'b11: out = PC_in;
    endcase
  end
  
  assign PC_out = out;
endmodule