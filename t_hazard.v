module t_hazard ();
  reg dx_memread, fd_memread;
  reg [3:0] dx_rt, fd_rs, fd_rt;
  wire stall_sig;

  IF dut (
        //inputs
        .dx_memread(dx_memread), 
        .fd_memread(fd_memread), 
        .dx_rt(dx_rt), 
        .fd_rs(fd_rs), 
        .fd_rt(fd_rt),
        .stall_sig(stall_sig)
        );

  initial begin
    dx_memread = 1; fd_memread = 0;
    dx_rt = 4'h1; fd_rs = 4'h1; fd_rt = 4'h1;
    clk = 0;
    #5;
    rst = 1;
    #20;
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("stall signal recieved is %b", stall_sig);
    rst = 0;
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("stall signal recieved is %b", stall_sig);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("stall signal recieved is %b", stall_sig);
    rst = 0; 
    bsig = 0; SrcData1 = 16'h1111; flag_bits = 3'b000; #20;
    $display("stall signal recieved is %b", stall_sig);
    $stop;
  end
  
  always begin
    #10;
    clk = ~clk;
  end

endmodule