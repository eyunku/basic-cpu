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
* Adds two input bits, putting the result into a sum bit.
* Takes in a carry bit.
**/
module full_adder(a, b, cin, s);
    input a, b, cin;
    output cout, s;

    // sum bit determined by a XOR b XOR cin
    assign s = a ^ b ^ cin;
endmodule

/**
* Generates the generate, propagate and carry out bits.
**/
module carry_block(a, b, cin, g, p, cout);
    input a, b, cin;
    output g, p, cout;

    // create wires for generate and propagate bits
    wire g, p;

    assign g = a * b;
    assign p = a + b;

    // use generate and propagate bits to generate carry-out
    assign cout = g + p * cin;
endmodule

/**
* 4 bit carry adder. Uses 4 full adders.
* Mode of 1 means subtraction, mode of 0 means addition.
**/
module carry_lookahead_4bit(a, b, cin, sum, cout, mode);
    input[3:0] a, b; // 4-bit inputs to add
    input mode;
    output[3:0] sum;
    output cout;
    output[2:0] code;

    // create subtract mode
    wire[3:0] negb;
    assign negb[0] = ~b[0];
    assign negb[1] = ~b[1];
    assign negb[2] = ~b[2];
    assign negb[3] = ~b[3];

    // wires to store generate and propagate bits
    wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;

    // wire cx_y connects the carry out for bit x to the carry in for bit y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    full_adder f0(.a(a[0]), .b(mode ? negb[0] : b[0]), .cin(cin), .s(sum[0]));
    carry_block c0(.a(a[0]), .b(mode? negb[0] : b[0]), .cin(cin), .p(p0), .g(g0), .cout(c0_1));

    full_adder f1(.a(a[1]), .b(mode ? negb[1] : b[1]), .cin(c0_1), .s(sum[1]));
    carry_block c1(.a(a[1]), .b(mode ? negb[1]: b[1]), .cin(c0_1), .p(p1), .g(g1), .cout(c1_2));

    full_adder f2(.a(a[2]), .b(mode ? negb[2] : b[2]), .cin(c1_2), .s(sum[2]));
    carry_block c2(.a(a[2]), .b(mode ? negb[2]: b[2]), .cin(c1_2), .p(p2), .g(g2), .cout(c2_3));

    full_adder f3(.a(a[3]), .b(mode ? negb[3] : b[3]), .cin(c2_3), .s(sum[3]));
    carry_block c3(.a(a[3]), .b(mode ? negb[3]: b[3]), .cin(c2_3), .p(p3), .g(g3), .cout(3_4));
    
    // generate carry-out of whole module
    wire P, G;
    
    assign P = p0 * p1 * p2 * p3;
    assign G = g3 + g2 * p3 + g1 * p3 * p2 + g0 * p3 * p2 * p1;

    assign cout = G + P * cin;
endmodule

/**
* 16-bit CLA, created from 4 4-bit CLAs. Mode of 1 means subtraction, mode of 0 means addition.
* Outputs the relevant flag bit data into a 3-bit register.
**/
module carry_lookahead(a, b, sum, overflow, mode);
    input[15:0] a, b;
    input mode;

    output[15:0] sum;
    output overflow;

    // wire cx_y connects the carry out of module x to the carry in of module y
    wire c0_1;
    wire c1_2;
    wire c2_3;

    carry_lookahead_4bit cla0(.a(a[3:0]), .b(b[3:0]), .cin(mode), .sum(sum[3:0]), .cout(c0_1), .mode(mode));
    carry_lookahead_4bit cla1(.a(a[7:4]), .b(b[7:4]), .cin(c0_1), .sum(sum[7:4]), .cout(c1_2), .mode(mode));
    carry_lookahead_4bit cla2(.a(a[11:8]), .b(b[11:8]), .cin(c1_2), .sum(sum[11:8]), .cout(c2_3), .mode(mode));
    carry_lookahead_4bit cla3(.a(a[15:12]), .b(b[15:12]), .cin(c2_3), .sum(sum[15:12]), .cout(overflow), .mode(mode));

    // make sure arithmetic operation is saturated
    wire[15:0] temp; // temporary sum storage
    wire[15:0] neg, pos; // largest negative and positive values
    assign neg = 16'h8000;
    assign pos = 16'h7fff;

    // if a is neg., b is neg., and output is pos.
    assign temp = (a[15] & b[15] & ~sum[15]) ? neg : sum;
    assign temp = (~a[15] & ~b[15] & sum[15]) ? pos : sum;

    assign sum = temp;
endmodule