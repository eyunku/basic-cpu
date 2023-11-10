module t_forward ();
  reg clk, rst, xm_regwrite, mw_regwrite, xm_memread;
  reg [3:0] xm_rd, xm_rt, mw_rd, dx_rs, dx_rt;
  wire [1:0] forwarda;
  wire [1:0] forwardb;
  wire forwardmm;

  forwarding_unit dut (
    .xm_regwrite(xm_regwrite),
    .mw_regwrite(mw_regwrite),
    .xm_memread(xm_memread),
    .xm_rd(xm_rd),
    .xm_rt(xm_rt),
    .mw_rd(mw_rd),
    .dx_rs(dx_rs),
    .dx_rt(dx_rt),
    .forwarda(forwarda),
    .forwardb(forwardb),
    .forwardmm(forwardmm)
    );

  initial begin
    xm_rd = 4'b0001; xm_rt = 4'b0001; mw_rd = 4'b0001; dx_rs = 4'b0001; dx_rt = 4'b0001;
    clk = 0;
    #5;
    rst = 1;
    #20;
    xm_regwrite = 1; mw_regwrite = 0; xm_memread = 0; #20;
    rst = 0;
    xm_regwrite = 0; mw_regwrite = 1; xm_memread = 0; #20;
    $display("instruction got is %b and pc %b and %b", forwarda, forwardb, forwardmm);
    rst = 0;
    xm_regwrite = 0; mw_regwrite = 0; xm_memread = 1; #20;
    $display("instruction got is %b and pc %b and %b", forwarda, forwardb, forwardmm);
    rst = 0; 

    xm_rd = 4'b0001; xm_rt = 4'b0001; mw_rd = 4'b0001; dx_rs = 4'b0001; dx_rt = 4'b0001;
    xm_regwrite = 1; mw_regwrite = 0; xm_memread = 0; #20;
    $display("instruction got is %b and pc %b and %b", forwarda, forwardb, forwardmm);
    xm_regwrite = 0; mw_regwrite = 1; xm_memread = 0; #20;
    $display("instruction got is %b and pc %b and %b", forwarda, forwardb, forwardmm);
    xm_regwrite = 0; mw_regwrite = 0; xm_memread = 1; #20;
    $display("instruction got is %b and pc %b and %b", forwarda, forwardb, forwardmm);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule