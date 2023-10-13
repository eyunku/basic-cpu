// SLL, SRA, ROR


module sll (input [3:0] shift_amount, input [15:0] value, output [15:0]);
// base 3 wires
wire [5:0] shift;
wire [1:0] w1s;
wire [1:0] w3s;
wire [1:0] w9s;

// output wires
wire [15:0] stage1;
wire [15:0] stage2;

base_2_to_3 converter (.base_2(shift_amount), .base_3(shift))
assign w1s = shift [1:0];
assign w3s = shift [3:2];
assign w9s = shift [5:4] ;

// shift left by 1:0
assign stage1 = w1s[0] ?  : (w1s[1] ?  : );

// shift left by 3:2


// shift left by 5:4


module sra ()

module ror()

module base_2_to_3 (input [3:0] base_2, output [5:0] base_3)
// convert base 2 to 3
