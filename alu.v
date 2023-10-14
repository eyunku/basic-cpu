// alu.v
'include "shifter.v"

module alu (input [3:0] aluin1, input [3:0] aluin2, input [1:0] opcode, output [3:0] aluout, output err);
// output wire for alu
  wire add_out;
  wire sub_out;
  wire xor_out;
  wire red_out;
  wire sll_out;
  wire sra_out;
  wire ror_out;
  wire paddsb_out;
  wire lw_out;
  wire sw_out;
  wire llb_out;
  wire lhb_out;
  wire b_out;
  wire br_out;
  wire pcs_out;
  wire hlt_out;

  // error wires?
  
  // compute components
  add add (.a(aluin2), .b(aluin2), .out(add_out));
  sub sub (.a(aluin2), .b(aluin2), .out(sub_out));
  assign xor_out = aluin1 ^ aluin2;
  red red (.a(aluin2), .b(aluin2), .out(red_out));
  
  sll sll (.value(aluin2), .shift_amount(aluin2), .out(sll_out));
  sra sra (.value(aluin2), .shift_amount(aluin2), .out(sra_out));
  sll sll (.value(aluin2), .shift_amount(aluin2), .out(ror_out));
  
  paddsb paddsb (.a(aluin2), .b(aluin2), .out(paddsb_out));
  lw lw (.a(aluin2), .b(aluin2), .out(lw_out));
  sw sw (.a(aluin2), .b(aluin2), .out(sw_out));
  llb llb (.a(aluin2), .b(aluin2), .out(llb_out));
  lhb lhb (.a(aluin2), .b(aluin2), .out(lhb_out));
  b b (.a(aluin2), .b(aluin2), .out(b_out));
  br br (.a(aluin2), .b(aluin2), .out(br_out));
  pcs pcs (.a(aluin2), .b(aluin2), .out(pcs_out));
  hlt hlt (.a(aluin2), .b(aluin2), .out(hlt_out));

  // alu mux result decision
  reg out
  always @(*) begin
    case (opcode)
      4'h0: out = add_out; // ADD
      4'h1: out = sub_out; // SUB
      4'h2: out = xor_out; // XOR
      4'h3: out = red_out; // RED
      4'h4: out = sll_out; // SLL
      4'h5: out = sra_out; // SRA
      4'h6: out = ror_out; // ROR
      4'h7: out = paddsub_out; // PADDSB
      4'h8: out = lw_out; // LW
      4'h9: out = sw_out; // SW
      4'hA: out = llb_out; // LLB
      4'hB: out = lhb_out; // LHB
      4'hC: out = b_out; // B
      4'hD: out = br_out; // BR
      4'hE: out = pcs_out; // PCS
      4'hF: out = hlt_out; // HLT
    endcase
  end
  assign err =;
  assign aluout = out;
endmodule
