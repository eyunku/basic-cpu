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