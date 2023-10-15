// TODO clarify with group about the arguments passed into CLA
// TODO add and reformat ripple carry for testing
// TODO figure formatting standard our group wants to go with

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

