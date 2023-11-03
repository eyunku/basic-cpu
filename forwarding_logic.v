// forwarding logic
    // input signals from pipeline registers
    // check for raw dependencies
    // output yes no signal to muxes 

// larger forwarding unit logic
module forwarding_unit(xm_regwrite, xm_rd, mw_regwrite, mw_rd, dx_rs, dx_rt, forwarda, forwardb);
    // inputs
    input xm_regwrite, mw_regwrite;
    input [3:0] xm_rd, mw_rd, dx_rs, dx_rt;

    // outputs
    output forwarda, forwardb;




    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)), then ForwardA = 10
    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt)), then ForwardB = 10
    // if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0)
    //    and ~(EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs))
    //    and (MEM/WB.RegisterRd = ID/EX.RegisterRs)), then ForwardA = 01
    // if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0)
    //    and ~(EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt))
    //    and (MEM/WB.RegisterRd = ID/EX.RegisterRt)), then ForwardB = 01

    wire forwarda = (xm_regwrite & (xm_rd != 0) & (xm_rd == dx_rs)) ? 2'b10 : (mw_regwrite and (mw_rd != 0) and (xm_rd == dx_rs)) ? 01 : 00;
    wire forwardb = (xm_regwrite & (xm_rd != 0) & (xm_rd == dx_rt)) ? 2'b10 : (mw_regwrite and (mw_rd != 0) and (xm_rd == dx_rt)) ? 01 : 00;


//TODO: MEM to MEM 

endmodule