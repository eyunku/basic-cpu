`include "../forwarding_logic.v"

module t_forward ();
  reg clk, rst, regwrite_MEM, regwrite_WB, memwrite_MEM;
  reg [3:0] rd_MEM, rt_MEM, rd_WB, rs_EX, rt_EX;
  wire [1:0] forwarda;
  wire [1:0] forwardb;
  wire forwardmm;

  forwarding_unit dut (
    .xm_regwrite(regwrite_MEM),
    .mw_regwrite(regwrite_WB),
    .xm_memwrite(memwrite_MEM),
    .xm_rd(rd_MEM),
    .xm_rt(rt_MEM),
    .mw_rd(rd_WB),
    .dx_rs(rs_EX),
    .dx_rt(rt_EX),
    .forwarda(forwarda),
    .forwardb(forwardb),
    .forwardmm(forwardmm)
    );

  initial begin
    // forwarda = 01, forwardb = 10, forwardmm = 0
    rs_EX = 4'h1; rt_EX = 4'h2; rd_MEM = 4'h1; rd_WB = 4'h2; 
    regwrite_MEM = 1'b1; regwrite_WB = 1'b1;
    rt_MEM = 4'h1; memwrite_MEM = 1'b1;
    #20
    $display("forwarda: %b forwardb: %b forwardmm: %b", forwarda, forwardb, forwardmm);
    
    // forwarda = 10, forwardb = 01, forwardmm = 1
    // Test for forwarding from different stages
    rd_MEM = 4'h2; rd_WB = 4'h1;
    #20
    $display("forwarda: %b forwardb: %b forwardmm: %b", forwarda, forwardb, forwardmm);

    // forwarda = 00, forwardb = 00, forwardmm = 1
    // test for no forwarding by changing rd or deasserting regwrite signal
    rs_EX = 4'h3; regwrite_MEM = 1'b0;
    #20
    $display("forwarda: %b forwardb: %b forwardmm: %b", forwarda, forwardb, forwardmm);

    // forwarda = 10, forwardb = 10, forwardmm = 0
    // test for forwarding on same stage
    rs_EX = 4'h2; rt_EX = 4'h2; rd_WB = 4'h2;
    #20
    $display("forwarda: %b forwardb: %b forwardmm: %b", forwarda, forwardb, forwardmm);

    // forwarda = 01, forwardb = 01, forwardmm = 0
    // test for conflicting forwarding, can forward xx or mx
    rs_EX = 4'h2; rt_EX = 4'h2; regwrite_MEM = 1'b1;
    #20
    $display("forwarda: %b forwardb: %b forwardmm: %b", forwarda, forwardb, forwardmm);
    $stop;
  end
  
  // always begin
  //   #10;
  //   clk = ~clk;
  // end
endmodule