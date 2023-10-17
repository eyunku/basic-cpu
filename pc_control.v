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

  addsub_16bit add_two(.Sum(sum2), .Ovfl(ovfl2), .A(PC_in), .B(16'h0002), .sub(0));
  addsub_16bit add_opt(.Sum(b_out), .Ovfl(ovfl_add), .A(sum2), .B(signext_imm), .sub(0));

  // case statement for branch signal
  // 00: no branch, 01: b, 10: br, 11: hlt
  // must evaluate whether branching is true or not, if it isnt we just run the sum2
  always @(*) begin
    case (bsig)
      2'b00: out = sum2;
      2'b01: out = truth ? b_out: sum2;
      2'b10: out = truth ? regsrc: sum2;
      2'b11: out = PC_in;
      default: out = 16'bz;
    endcase
  end
  
  assign PC_out = out;
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
reg [1:0] signal;
reg [15:0] data;
reg [15:0] in;
wire [15:0] OUT;

pc_control dut (.bsig(signal), .C(c), .I(i), .F(f), .regsrc(data), .PC_in(in), .PC_out(OUT));

initial begin
signal = 2'b00; data = 16'hFFFF; c = 3'b101; f = 3'b100; i = 9'b000000010; in = 16'h0010; #10;
$display("no branch output is %b", OUT);
signal = 2'b01; data = 16'hFFFF; c = 3'b100; f = 3'b011; i = 9'b000000010; in = 16'h0010; #10;
$display("branch output is %b", OUT);
signal = 2'b10; data = 16'hFFFF; c = 3'b100; f = 3'b000; i = 9'b000000010; in = 16'h0010; #10;
$display("branch with register output is %b", OUT);
signal = 2'b11; data = 16'hFFFF; c = 3'b111; f = 3'b101; i = 9'b000000010; in = 16'h0010; #10;
$display("halt signal, output is %b", OUT);
$stop;
end
endmodule
