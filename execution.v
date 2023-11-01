// execution stage

module EX ();
    // input 
    input [15:0] SrcReg1, SrcReg2, sextimm;
    input [3:0] aluop;
    //output
    output [15:0] aluout;
    output [2:0] flag_out;


    // wires
    wire [15:0] aluin1, aluin2;
    wire err;

    assign aluin1 = SrcReg1;
    assign aluin2 = alusrc ? imm_16bit : SrcReg2;

    // Update flags (flag = NVZ)
    // TODO make this a signal
    wire [2:0] flag_in;
    assign flag_in[2] = (aluop == 3'h1 | aluop == 3'h0) ? aluout[15] : flag_out[2];
    assign flag_in[1] = (aluop == 3'h1 | aluop == 3'h0) ? err : flag_out[1];
    assign flag_in[0] = (aluop == 3'h1 | aluop == 3'h0 | aluop == 3'h2 | aluop == 3'h3 | aluop == 3'h4 | aluop == 3'h5 | aluop == 3'h6) ? (aluout == 16'h0000) : flag_out[0];


    alu alu(
        .aluin1(aluin1), 
        .aluin2(aluin2), 
        .aluop(aluop), 
        .aluout(aluout), 
        .err(err)
    );

    flag_reg FLAG (
        .clk(clk), 
        .rst(rst), 
        .write(3'b111), 
        .in(flag_in), 
        .flag_out(flag_out)
    );

endmodule