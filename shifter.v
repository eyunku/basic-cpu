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
