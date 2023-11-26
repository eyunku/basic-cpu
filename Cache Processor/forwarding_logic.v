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
//      2bit forwarding wires a and b for rs and rt respectively
module forwarding_unit(
    input xm_regwrite, xm_memwrite, mw_regwrite,
    input [3:0] xm_rd, xm_rt, mw_rd, dx_rs, dx_rt,
    output forwardmm,
    output [1:0] forwarda, forwardb);

    // outputs
    // 2 bit output for xx and mx signals respectively for Rs
    // 2 bit output for xx, and mx signals respectively for Rt
    // 1 bit output for mm signals for Rt

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
        (xm_regwrite & (xm_rd != 4'h0) & (xm_rd == dx_rs)) ? 2'b01 : // logic for xx forwarding
        (mw_regwrite & (mw_rd != 4'h0) & (mw_rd == dx_rs)) ? 2'b10 : // logic for mx forwarding
        2'b00;
    assign forwardb = 
        (xm_regwrite & (xm_rd != 4'h0) & (xm_rd == dx_rt)) ? 2'b01 :
        (mw_regwrite & (mw_rd != 4'h0) & (mw_rd == dx_rt)) ? 2'b10 :
        2'b00;

    assign forwardmm = (xm_memwrite & mw_regwrite & (mw_rd != 4'h0) & (mw_rd == xm_rt)) ? 1 : 0;

endmodule