module t_hazard ();
  reg clk, rst;
  reg dx_memread, fd_memread;
  reg [3:0] dx_rt, fd_rs, fd_rt;
  wire stall_sig, rs_dep;

  hazard_unit dut (
        //inputs
        .dx_memread(dx_memread), 
        .fd_memread(fd_memread), 
        .dx_rt(dx_rt), 
        .fd_rs(fd_rs), 
        .fd_rt(fd_rt),
        .stall_sig(stall_sig),
        .rs_dep(rs_dep)
        );

  initial begin
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1;
    clk = 0;
    #5;
    rst = 1;
    #20;
    rst = 0;
    dx_memread = 1; fd_memread = 0;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    rst = 0;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    rst = 0; 
    dx_memread = 0; fd_memread = 0;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    rst = 0; 
    dx_memread = 1; fd_memread = 0;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    dx_memread = 0; fd_memread = 1;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    dx_memread = 1; fd_memread = 1;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1; #20;
    $display("stall signal recieved is %b and %b", stall_sig, rs_dep);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule