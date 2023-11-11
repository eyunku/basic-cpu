// forwarding logic
    // input signals from pipeline registers
    // check for raw dependencies
    // output yes no signal to muxes 

// USAGE
// inputs:
//      signals for regwrite from EX/MEM and MEM/WB stage
//      register Rs and Rt from 
//      register Rd
// outputs:
//      3bit forwarding wires a and b for rs and rt respectively
module forwarding_unit(xm_regwrite, xm_memread, mw_regwrite, xm_rd, xm_rt, mw_rd, dx_rs, dx_rt, forwarda, forwardb, forwardmm);
    // inputs
    input xm_regwrite, mw_regwrite, xm_memread;
    input [3:0] xm_rd, xm_rt, mw_rd, dx_rs, dx_rt;

    // outputs
    output [1:0] forwarda; // 2 bit output for xx and mx signals respectively for Rs
    output [1:0] forwardb; // 2 bit output for xx, and mx signals respectively for Rt
    output forwardmm; // 1 bit output for mm signals for Rt




    // MEM to MEM
    // if (MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0) and (MEM/WB.RegisterRd = EX/MEM.RegisterRt)), then ForwardB100
    // signal only valid for Rs
    // EX to EX
    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)), then ForwardA = 010
    // if (EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt)), then ForwardB = 010
    // MEM to EX
    // if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0)
    //    and ~(EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) <----- basically prevent overiding
    //    and (MEM/WB.RegisterRd = ID/EX.RegisterRs)), then ForwardA = 001
    // if (MEM/WB.RegWrite and (MEM/WB.RegisterRd != 0)
    //    and ~(EX/MEM.RegWrite and (EX/MEM.RegisterRd != 0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt))
    //    and (MEM/WB.RegisterRd = ID/EX.RegisterRt)), then ForwardB = 001



    assign forwarda = 
        (xm_regwrite & (xm_rd != 0) & (xm_rd == dx_rs)) ? 2'b10 :
        (mw_regwrite & (mw_rd != 0) & (xm_rd == dx_rs)) ? 2'b01 :
        2'b00;
    assign forwardb = 
        (xm_regwrite & (xm_rd != 0) & (xm_rd == dx_rt)) ? 2'b10 :
        (mw_regwrite & (mw_rd != 0) & (xm_rd == dx_rt)) ? 2'b01 :
        2'b00;

    assign forwardmm = (mw_regwrite & (mw_rd != 0) & (mw_rd == xm_rt)) ? 1 : 0;



endmodule