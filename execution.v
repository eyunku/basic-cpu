// execution stage

module EX (clk, rst, SrcData1, SrcData2, sextimm, alusrc, aluop, aluout, flag_out);
    // input 
    input clk, rst;
    input [15:0] SrcData1, SrcData2, sextimm;
    input [3:0] aluop;
    input alusrc;
    //output
    output [15:0] aluout;
    output [2:0] flag_out; // NVZ


    // wires
    wire [15:0] aluin1 = SrcData1;
    wire [15:0] aluin2 = alusrc ? sextimm : SrcData2;
    wire err;

    // Update flags (flag = NVZ)
    wire [2:0] flag_in;
    assign flag_in[2] = (aluop == 4'h1 | aluop == 4'h0) ? aluout[15] : flag_out[2];
    assign flag_in[1] = (aluop == 4'h1 | aluop == 4'h0) ? err : flag_out[1];
    assign flag_in[0] = (aluop == 4'h1 | aluop == 4'h0 | aluop == 3'h2 | aluop == 3'h3 | aluop == 3'h4 | aluop == 3'h5 | aluop == 3'h6) ? (aluout == 16'h0000) : flag_out[0];


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