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