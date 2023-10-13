/**
* Adds two input bits, putting the result into a sum bit.
* Takes in a carry bit and outputs a carry bit for overflow.
**/
module full_adder(a, b, cin, cout, s);
    input a, b, cin;
    output cout, s;

    // sum bit determined by a XOR b XOR cin
    assign s = a ^ b ^ cin;

    // cout is 1 if 2 or more inputs are 1
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

/**
* 4 bit ripple-carry adder. Uses 4 full adders.
* Mode of 1 means subtraction, mode of 0 means addition.
**/
module ripple_carry_adder(a, b, sum, overflow, mode);
    input[3:0] a, b; // 4-bit inputs to add
    input mode;
    output[3:0] sum;
    output overflow;

    // wire cx_y connects full adder x to full adder y
    wire c0_1;
    wire c1_2;
    wire c2_3;
    wire c3_4;

    // carry-in of first full adder set to 0
    full_adder f0(.a(a[0]), .b(b[0]), .cin(0), .cout(c0_1), .s(sum[0]));
    full_adder f1(.a(a[1]), .b(b[0]), .cin(c0_1), .cout(c1_2), .s(sum[1]));
    full_adder f2(.a(a[2]), .b(b[0]), .cin(c1_2), .cout(c2_3), .s(sum[2]));
    full_adder f3(.a(a[3]), .b(b[0]), .cin(c2_3), .cout(c3_4), .s(sum[3]));

    // carry out of ripple carry adder is cn XOR cn-1 (XOR of last two carry bits)
    assign overflow = c2_3 ^ c3_4;
endmodule

/**
*
**/
module (opcode, rs, rt, rd);

endmodule