module PC_control(input [2:0] C, input [8:0] I, input [2:0] F, input [15:0] PC_in, output [15:0] PC_out);

// wires for all your diff branches
wire truth;

// ternary for deciding which branch instruction
// 000 not equal (Z = 0)
// 001 equal (z = 1)
// 010 greater than (Z = N = 0)
// 011 Less Than (N = 1) 
// 100 Greater Than or Equal (Z = 1 or Z = N = 0)
// 101 Less Than or Equal (N = 1 or Z = 1)
// 110 Overflow (V = 1)
// 111 Unconditional

assign truth = C[0] ? (C[1] ? (C[2] ? 1 : (F[1] ? 1 : 0)) : (C[2] ? (F[2] | F[0]) : (~F[0] | (F[0] & F[2])? 0 : 1) )) : (C[1] ? (C[2] ? (F[2] ? 1 : 0) : (F[0] & F[2] ? 0 : 1)) : (C[2] ? (F[0] ? 1 : 0) : (F[0] ? 0 : 1)));

wire [15:0] signext;
assign signext = I[8] ? {7'b1111111, I[8:0]} : {7'b0000000, I[8:0]};

wire [15:0] sum2;
wire [15:0] out;
wire ovfl2;
wire ovfl_add;

addsub_16bit add_two(.Sum(sum2), .Ovfl(ovfl2), .A(PC_in), .B(16'h0002), .sub(0));
addsub_16bit add_opt(.Sum(out), .Ovfl(ovfl_add), .A(sum2), .B(signext), .sub(0));

assign PC_out = truth ? out: sum2;
endmodule

module addsub_16bit (Sum, Ovfl, A, B, sub);
input [15:0] A, B;
input sub;
output [15:0] Sum;
output Ovfl;

wire w1;
wire w2;
wire w3;
wire w4;
wire w5;
wire w6;
wire w7;
wire w8;
wire w9;
wire wa;
wire wb;
wire wc;
wire wd;
wire we;
wire wf;
wire wg;

full_adder_1bit FA1 (.S(Sum[0]), .Cout(w1), .A(A[0]), .B(B[0] ^ sub), .Cin(sub));
full_adder_1bit FA2 (.S(Sum[1]), .Cout(w2), .A(A[1]), .B(B[1] ^ sub), .Cin(w1));
full_adder_1bit FA3 (.S(Sum[2]), .Cout(w3), .A(A[2]), .B(B[2] ^ sub), .Cin(w2));
full_adder_1bit FA4 (.S(Sum[3]), .Cout(w4), .A(A[3]), .B(B[3] ^ sub), .Cin(w3));
full_adder_1bit FA5 (.S(Sum[4]), .Cout(w5), .A(A[4]), .B(B[4] ^ sub), .Cin(w4));
full_adder_1bit FA6 (.S(Sum[5]), .Cout(w6), .A(A[5]), .B(B[5] ^ sub), .Cin(w5));
full_adder_1bit FA7 (.S(Sum[6]), .Cout(w7), .A(A[6]), .B(B[6] ^ sub), .Cin(w6));
full_adder_1bit FA8 (.S(Sum[7]), .Cout(w8), .A(A[7]), .B(B[7] ^ sub), .Cin(w7));
full_adder_1bit FA9 (.S(Sum[8]), .Cout(w9), .A(A[8]), .B(B[8] ^ sub), .Cin(w8));
full_adder_1bit FAa (.S(Sum[9]), .Cout(wa), .A(A[9]), .B(B[9] ^ sub), .Cin(w9));
full_adder_1bit FAb (.S(Sum[10]), .Cout(wb), .A(A[10]), .B(B[10] ^ sub), .Cin(wa));
full_adder_1bit FAc (.S(Sum[11]), .Cout(wc), .A(A[11]), .B(B[11] ^ sub), .Cin(wb));
full_adder_1bit FAd (.S(Sum[12]), .Cout(wd), .A(A[12]), .B(B[12] ^ sub), .Cin(wc));
full_adder_1bit FAe (.S(Sum[13]), .Cout(we), .A(A[13]), .B(B[13] ^ sub), .Cin(wd));
full_adder_1bit FAf (.S(Sum[14]), .Cout(wf), .A(A[14]), .B(B[14] ^ sub), .Cin(we));
full_adder_1bit FAg (.S(Sum[15]), .Cout(wg), .A(A[15]), .B(B[15] ^ sub), .Cin(wf));

assign Ovfl = wf ^ wg;
endmodule

module full_adder_1bit (S, Cout, A, B, Cin);
input A, B, Cin;
output S, Cout;

assign S = A ^ B ^ Cin;
assign Cout = A & B | A & Cin | B & Cin;
endmodule


module test_bench_write_branch ();
reg [2:0] c, f;
reg signed [8:0] i;
reg [15:0] in;
wire [15:0] OUT;
wire [15:0] d;

PC_control dut (.C(c), .I(i), .F(f), .PC_in(in), .PC_out(OUT));

initial begin
c = 3'b000; f = 3'b000; i = 9'b000000001; in = 16'h0000; #10;
$display("Testing not equals branch output is %b", OUT);
c = 3'b000; f = 3'b001; i = 9'b000000001; in = 16'h0000; #10;
$display("Testing not equals no branch output is %b", OUT);

$stop;
end
endmodule

