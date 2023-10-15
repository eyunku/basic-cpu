// alu.v

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


module sll (input [3:0] shift_amount, input [15:0] value, output [15:0] out);
// base 3 wires
wire [4:0] shift;

// output wires
wire [15:0] stage1;
wire [15:0] stage2;

base_2_to_3 converter (.base_2(shift_amount), .base_3(shift));

// 00 01 10
// shift left by 1:0
assign stage1 = shift[0] ? {value[14:0], 1'b0} : (shift[1] ? {value[13:0], 2'b00} : value);

// shift left by 3:2
assign stage2 = shift[2] ? {stage1[12:0], 3'b000} : (shift[3] ? {stage1[9:0], 6'b000000} : stage1);

// shift left by 5:4
assign out = shift[4] ? {stage2[6:0], 9'b000000000} : stage2;
endmodule


module sra (input [3:0] shift_amount, input [15:0] value, output [15:0] out);
// base 3 wires
wire [4:0] shift;
wire s;
assign s = value[15];

// output wires
wire [15:0] stage1;
wire [15:0] stage2;

base_2_to_3 converter (.base_2(shift_amount), .base_3(shift));

// 00 01 10
// shift left by 1:0
assign stage1 = shift[0] ? {s, value[15:1]} : (shift[1] ? {s, s, value[15:2]} : value);

// shift left by 3:2
assign stage2 = shift[2] ? {s, s, s, stage1[15:3]} : (shift[3] ? {s, s, s, s, s, s, stage1[15:6]} : stage1);

// shift left by 5:4
assign out = shift[4] ? {s, s, s, s, s, s, s, s, s, stage2[15:9]} : stage2;
endmodule


module ror(input [3:0] shift_amount, input [15:0] value, output [15:0] out);
// base 3 wires
wire [4:0] shift;
wire s;
assign s = value[15];

// output wires
wire [15:0] stage1;
wire [15:0] stage2;

base_2_to_3 converter (.base_2(shift_amount), .base_3(shift));

// 00 01 10
// shift left by 1:0
assign stage1 = shift[0] ? {value[0], value[15:1]} : (shift[1] ? {value[1:0], value[15:2]} : value);

// shift left by 3:2
assign stage2 = shift[2] ? {stage1[2:0], stage1[15:3]} : (shift[3] ? {stage1[5:0], stage1[15:6]} : stage1);

// shift left by 5:4
assign out = shift[4] ? {stage2[8:0], stage2[15:9]} : stage2;
endmodule

module base_2_to_3 (input [3:0] base_2, output [4:0] base_3);
// convert base 2 to 3
reg [4:0] out;

always @(*) begin
case (base_2)
4'b0000: out = 5'b00000;
4'b0001: out = 5'b00001;
4'b0010: out = 5'b00010;
4'b0011: out = 5'b00100;
4'b0100: out = 5'b00101;
4'b0101: out = 5'b00110;
4'b0110: out = 5'b01000;
4'b0111: out = 5'b01001;
4'b1000: out = 5'b01010;
4'b1001: out = 5'b10000;
4'b1010: out = 5'b10001;
4'b1011: out = 5'b10010;
4'b1100: out = 5'b10100;
4'b1101: out = 5'b10101;
4'b1110: out = 5'b10110;
4'b1111: out = 5'b11000;
endcase
end

assign base_3 = out;
endmodule

/**
* Applies xor onto two inputs.
**/
module xor(a, b, out);
    input [15:0] a, b;
    output [15:0] out;

    // performs the xor operation onto the operands a and b
    assign out = a^b;
endmodule

/**
* Does four half-byte additions in parallel
**/
module paddsb(a, b, out):
    input [15:0] a, b;
    output [15:0] out;

    // Contains output of 4-bit add
    wire [3:0] C1, C2, C3, C4;
    // Contains arithmetic overflow bit after 4-bit add
    wire E1, E2, E3, E4;
    // Contains result of the 4-bit add + saturating arithmetic
    wire [3:0] S1, S2, S3, S4;

    // Performs 4-bit parallel addition
    add_4bit_cla p0 (.a(a[3:0]), .b(b[3:0]), .s(C1), .cin(0), .overflow(E1));
    add_4bit_cla p1 (.a(a[7:4]), .b(b[7:4]), .s(C2), .cin(0), .overflow(E2));
    add_4bit_cla p2 (.a(a[11:8]), .b(b[11:8]), .s(C3), .cin(0), .overflow(E3));
    add_4bit_cla p3 (.a(a[15:12]), .b(b[15:12]), .s(C4), .cin(0), .overflow(E4));

    // Arithmetic saturation
    assign S1 = E1 ? (C1[3] ? 4'b0111 : 4'b1001) : C1;
    assign S2 = E2 ? (C2[3] ? 4'b0111 : 4'b1001) : C2;
    assign S3 = E3 ? (C3[3] ? 4'b0111 : 4'b1001) : C3;
    assign S4 = E4 ? (C4[3] ? 4'b0111 : 4'b1001) : C4;

    assign out = {S4, S3, S2, S1};
endmodule

module red(a, b, out):
    input [7:0] a, b;
    output []
endmodule
