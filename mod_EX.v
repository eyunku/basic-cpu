// execution stage
module mod_EX (
        input clk, rst, freeze,
        input alusrc, memenable, pcread,
        input [1:0] branch,
        input [3:0] aluop,
        input [15:0] SrcData1, SrcData2, imm_16bit,
        output [15:0] aluout,
        output [2:0] flag_out
    );

    // For LW or SW, effective address = ([rs] & 0xFFE) + (imm << 1)
    wire [15:0] aluin1 = memenable ? (SrcData1 & 16'hFFFE) : SrcData1;
    wire [15:0] aluin2 = alusrc ? (memenable ? (imm_16bit << 1) : imm_16bit) : SrcData2;

    wire err;
    wire [2:0] flag_in;

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

    wire keep_flag = branch[0] | branch[1] | pcread;

    // Update flags (flag = NVZ)
    assign flag_in[2] = keep_flag ? flag_out[2] :
                        ((aluop == 4'h1 | aluop == 4'h0) ? aluout[15] : flag_out[2]);
    assign flag_in[1] = keep_flag ? flag_out[1] :
                        ((aluop == 4'h1 | aluop == 4'h0) ? err : flag_out[1]);
    assign flag_in[0] = keep_flag ? flag_out[0] :
                        ((aluop == 4'h1 | aluop == 4'h0 | aluop == 4'h2 | aluop == 4'h3 | aluop == 3'h4 | aluop == 3'h5 | aluop == 3'h6)
                            ? (aluout == 16'h0000) : flag_out[0]);

endmodule