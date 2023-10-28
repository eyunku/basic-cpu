module t_pc_reg ();
  reg clk, rst, pc_write, pc_read;
  reg [15:0] pc_in;
  wire [15:0] pc_out;

  pc_reg dut (
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_read(pc_read),
    .pc_in(pc_in),
    .pc_out(pc_out)
  );

  initial begin
    clk = 0; rst = 0; pc_write = 0; pc_read = 1; pc_in = 16'b0; #10
    $display("pc_out should be 16'bx: %b", pc_out);
    clk = 1; rst = 0; pc_write = 1; pc_read = 0; pc_in = 16'h1111; #10
    $display("pc_out should be 16'bz: %b", pc_out);
    clk = 0; rst = 0; pc_write = 0; pc_read = 1; pc_in = 16'h2222; #10
    $display("pc_out 16'h1111: %b", pc_out);
  end
endmodule

module test_bench_flag ();
reg nw, vw, zw, nn, vn, zn, clk, rst;
wire n_flag, v_flag, z_flag;

flag_reg dut (.clk(clk), .rst(rst), .n_write(nw), .v_write(vw), .z_write(zw), .n_in(nn), .v_in(vn), .z_in(zn), .n_out(n), .v_out(v), .z_out(z_flag));

initial begin
clk = 0;
#5;
rst = 1;
nw = 1; vw = 1; zw = 1; nn = 1; vn = 1; zn = 1; #20;
rst = 0;
nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z_flag);
rst = 0;
nw = 0; vw = 1; zw = 0; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z_flag);
rst = 0; 
nw = 0; vw = 0; zw = 1; nn = 1; vn = 1; zn = 0; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z_flag);
rst = 0; 
nw = 1; vw = 0; zw = 0; nn = 1; vn = 1; zn = 1; #20;
$display("after setting zero bit, flag is %b %b %b", n, v, z_flag);
$stop;
end

always begin
#10;
clk = ~clk;
end

endmodule


module test_bench_RF ();
reg clk, rst, wr;
reg [3:0] sr1, sr2, dr;
reg [15:0] dd;
wire [15:0] sd1, sd2;

RegisterFile dut (.clk(clk), .rst(rst), .SrcReg1(sr1), .SrcReg2(sr2), .DstReg(dr), .WriteReg(wr), .DstData(dd), .SrcData1(sd1), .SrcData2(sd2));

initial begin
clk = 0;
#5;
rst = 1; sr1 = 4'hA; sr2 = 4'hA; #20;
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'hFACE; #20;
$display("first write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'h1111; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 1; dr = 4'hA; dd = 16'hFACE; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'hA; sr2 = 4'hA; wr = 0; dr = 4'hA; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'h0; sr2 = 4'hA; wr = 1; dr = 4'h0; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
rst = 0; sr1 = 4'h0; sr2 = 4'h0; wr = 0; dr = 4'h0; dd = 16'h2222; #20;
$display("second write and read output is %b and %b", sd1, sd2);
$stop;
end

always begin
#10;
clk = ~clk;
end

endmodule