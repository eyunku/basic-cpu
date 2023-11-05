/**
* ALU module that takes in 2 inputs and has one output and
* one err that marks overflow. aluin1 is always from a register, and
* aluin2 is connected to a MUX that controls if it's a SEXT
* or register value. If an incorrect aluop is passed in, err is
* set to 1, and aluout is set to 0.
**/
module alu (aluin1, aluin2, aluop, aluout, err);
    // aluin1 is always from a register
    // aluin2 can be from register or immediate
    // aluout is our 16-bit output
    // err is set to true if overflow happens
    /** aluop are as follows:
    0: ADD
    1: SUB
    2: XOR
    3: RED
    4: SLL
    5: SRA
    6: ROR
    7: PADDSB
    8: LLB
    9: LHB
    **/

    input[15:0] aluin1, aluin2;
    input[3:0] aluop;
    output[15:0] aluout;
    output err;

    // output wires
    wire[15:0] ADD, SUB, XOR, RED, SLL, SRA, ROR, PADDSB, LLB, LHB;
    wire ADDErr, SUBErr, XORErr, REDErr, SLLErr, SRAErr, RORErr, PADDSBErr, LLBErr, LHBErr;

    // ALU operations
    carry_lookahead add(.a(aluin1), .b(aluin2), .sum(ADD), .overflow(ADDErr), .mode(1'b0));
    carry_lookahead sub(.a(aluin1), .b(aluin2), .sum(SUB), .overflow(SUBErr), .mode(1'b1));
    xorModule xorModule(.a(aluin1), .b(aluin2), .out(XOR));
    red red(.in1(aluin1), .in2(aluin2), .out(RED));
    sll sll(.shift_amount(aluin2[3:0]), .value(aluin1), .out(SLL));
    sra sra(.shift_amount(aluin2[3:0]), .value(aluin1), .out(SRA));
    ror ror(.shift_amount(aluin2[3:0]), .value(aluin1), .out(ROR));
    paddsb paddsb(.a(aluin1), .b(aluin2), .out(PADDSB));
    llb llb(.in(aluin1), .imm(aluin2), .out(LLB));
    lhb lhb(.in(aluin1), .imm(aluin2), .out(LHB));

    reg[15:0] out;
    always @* begin
        case(aluop)
            4'h0: out = ADD;
            4'h1: out = SUB;
            4'h2: out = XOR;
            4'h3: out = RED;
            4'h4: out = SLL;
            4'h5: out = SRA;
            4'h6: out = ROR;
            4'h7: out = PADDSB;
            4'h8: out = LLB;
            4'h9: out = LHB;
            default: out = 16'h0000;
        endcase
    end

    assign aluout = out;
    assign err = (aluop == 4'h0) ? ADDErr :
                 (aluop == 4'h1) ? SUBErr : 1'b0;
endmodule

module llb(in, imm, out);
  input[15:0] imm; // 0xYY
  input[15:0] in; // rd
  output[15:0] out;

  assign out[15:8] = in[15:8];
  assign out[7:0] = imm[7:0];
endmodule

module lhb(in, imm, out);
  input[15:0] in, imm;
  output[15:0] out;
  
  assign out[15:8] = imm[7:0];
  assign out[7:0] = in[7:0];
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
module xorModule(a, b, out);
    input [15:0] a, b;
    output [15:0] out;

    // performs the xor operation onto the operands a and b
    assign out = a^b;
endmodule

/**
* Does four half-byte additions in parallel
**/
module paddsb(a, b, out);
    input [15:0] a, b;
    output [15:0] out;

    // Contains output of 4-bit add
    wire [3:0] C1, C2, C3, C4;
    // Contains arithmetic overflow bit after 4-bit add
    wire E1, E2, E3, E4;
    // Contains result of the 4-bit add + saturating arithmetic
    wire [3:0] S1, S2, S3, S4;

    // Performs 4-bit parallel addition
    carry_lookahead_4bit p0 (.a(a[3:0]), .b(b[3:0]), .sum(C1), .cin(1'b0), .cout(E1), .mode(1'b0));
    carry_lookahead_4bit p1 (.a(a[7:4]), .b(b[7:4]), .sum(C2), .cin(1'b0), .cout(E2), .mode(1'b0));
    carry_lookahead_4bit p2 (.a(a[11:8]), .b(b[11:8]), .sum(C3), .cin(1'b0), .cout(E3), .mode(1'b0));
    carry_lookahead_4bit p3 (.a(a[15:12]), .b(b[15:12]), .sum(C4), .cin(1'b0), .cout(E4), .mode(1'b0));

    // Arithmetic saturation
    assign S1 = (a[3]  & b[3]  & ~C1[3]) ? 4'b1000 : ((~a[3]  & ~b[3]  & C1[3]) ? 4'b0111 : C1);
    assign S2 = (a[7]  & b[7]  & ~C2[3]) ? 4'b1000 : ((~a[7]  & ~b[7]  & C2[3]) ? 4'b0111 : C2);
    assign S3 = (a[11] & b[11] & ~C3[3]) ? 4'b1000 : ((~a[11] & ~b[11] & C3[3]) ? 4'b0111 : C3);
    assign S4 = (a[15] & b[15] & ~C4[3]) ? 4'b1000 : ((~a[15] & ~b[15] & C4[3]) ? 4'b0111 : C4);

    assign out = {S4, S3, S2, S1};
endmodule

module red(in1, in2, out);
    input[15:0] in1, in2;
    output[15:0] out;

    // wires to hold the portions of the inputs
    wire[3:0] a1, a2, b1, b2, c1, c2, d1, d2;
    assign a2[3:0] = in1[15:12];
    assign a1[3:0] = in1[11:8];
    assign b2[3:0] = in1[7:4];
    assign b1[3:0] = in1[3:0];
    assign c2[3:0] = in2[15:12];
    assign c1[3:0] = in2[11:8];
    assign d2[3:0] = in2[7:4];
    assign d1[3:0] = in2[3:0];
    
    // add A + C and B + D
    wire[8:0] AC, BD;
    wire cAC, cBD, ACOverflow, BDOverflow;
    carry_lookahead_4bit ACAdderLow(.a(a1), .b(c1), .cin(1'b0), .sum(AC[3:0]), .cout(cAC), .mode(1'b0));
    carry_lookahead_4bit ACAdderHigh(.a(a2), .b(c2), .cin(cAC), .sum(AC[7:4]), .cout(ACOverflow), .mode(1'b0));
    carry_lookahead_4bit BDAdderLow(.a(b1), .b(d1), .cin(1'b0), .sum(BD[3:0]), .cout(cBD), .mode(1'b0));
    carry_lookahead_4bit BDAdderHigh(.a(b2), .b(d2), .cin(cBD), .sum(BD[7:4]), .cout(BDOverflow), .mode(1'b0));
    assign AC[8] = ACOverflow;
    assign BD[8] = BDOverflow;
    // zero extend to be able to use 16-bit CLA
    wire[15:0] ZEXTAC, ZEXTBD, tempOut;
    wire REDOverflow;
    assign ZEXTAC = {7'b0000000, AC}; assign ZEXTBD = {7'b0000000, BD};
    carry_lookahead RED(.a(ZEXTAC), .b(ZEXTBD), .sum(tempOut), .overflow(REDOverflow), .mode(1'b0));
    assign tempOut[9] = REDOverflow;
    assign out = REDOverflow ? {6'b111111, tempOut} : {6'b000000, tempOut};
endmodule

/**
* Adds two input bits, putting the result into a sum bit.
* Takes in a carry bit.
**/
module full_adder(a, b, cin, s);
    input a, b, cin;
    output s;

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

    assign g = a & b;
    assign p = a | b;

    // use generate and propagate bits to generate carry-out
    assign cout = g | (p & cin);
endmodule

/**
* 4 bit carry adder. Uses 4 full adders.
* Mode of 1 means subtraction, mode of 0 means addition.
**/
module carry_lookahead_4bit(a, b, cin, sum, cout, mode);
    input[3:0] a, b; // 4-bit inputs to add
    input mode, cin;
    output[3:0] sum;
    output cout;

    // create subtract mode
    wire[3:0] negb;
    assign negb = ~b;

    // wires to store generate and propagate bits
    wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;

    // wire cx_y connects the carry out for bit x to the carry in for bit y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    full_adder  f0(.a(a[0]), .b(mode ? negb[0] : b[0]), .cin(cin), .s(sum[0]));
    carry_block c0(.a(a[0]), .b(mode ? negb[0] : b[0]), .cin(cin), .p(p0), .g(g0), .cout(c0_1));

    full_adder  f1(.a(a[1]), .b(mode ? negb[1] : b[1]), .cin(c0_1), .s(sum[1]));
    carry_block c1(.a(a[1]), .b(mode ? negb[1] : b[1]), .cin(c0_1), .p(p1), .g(g1), .cout(c1_2));

    full_adder  f2(.a(a[2]), .b(mode ? negb[2] : b[2]), .cin(c1_2), .s(sum[2]));
    carry_block c2(.a(a[2]), .b(mode ? negb[2] : b[2]), .cin(c1_2), .p(p2), .g(g2), .cout(c2_3));

    full_adder  f3(.a(a[3]), .b(mode ? negb[3] : b[3]), .cin(c2_3), .s(sum[3]));
    carry_block c3(.a(a[3]), .b(mode ? negb[3] : b[3]), .cin(c2_3), .p(p3), .g(g3), .cout(c3_4));
    
    // generate carry-out of whole module
    assign cout = g3 | (p3 & c3_4);
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

    wire[15:0] b_in;
    wire[15:0] CLASum;

    // wire cx_y connects the carry out of module x to the carry in of module y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    // largest negative and positive values
    wire[15:0] neg, pos;
    assign neg = 16'h8000;
    assign pos = 16'h7fff;

    // TODO: we should just delete "mode" input to carry_lookahead_4bit
    assign b_in = mode ? ~b : b;
    carry_lookahead_4bit cla0(.a(a[3:0]), .b(b_in[3:0]), .cin(mode), .sum(CLASum[3:0]), .cout(c0_1), .mode(1'b0));
    carry_lookahead_4bit cla1(.a(a[7:4]), .b(b_in[7:4]), .cin(c0_1), .sum(CLASum[7:4]), .cout(c1_2), .mode(1'b0));
    carry_lookahead_4bit cla2(.a(a[11:8]), .b(b_in[11:8]), .cin(c1_2), .sum(CLASum[11:8]), .cout(c2_3), .mode(1'b0));
    carry_lookahead_4bit cla3(.a(a[15:12]), .b(b_in[15:12]), .cin(c2_3), .sum(CLASum[15:12]), .cout(c3_4), .mode(1'b0));

    // check if arithmetic operation is saturated
    assign sum = (a[15] & b_in[15] & ~CLASum[15]) ? neg : 
                 ((~a[15] & ~b_in[15] & CLASum[15]) ? pos : CLASum);
    assign overflow = (a[15] & b_in[15] & ~CLASum[15]) | (~a[15] & ~b_in[15] & CLASum[15]);
endmodule