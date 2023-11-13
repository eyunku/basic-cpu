// execution stage
module mod_EX (
        input clk, rst,
        input alusrc, memenable, pcread, flag_en,
        input [1:0] branch, forward_aluin1, forward_aluin2,
        input [3:0] aluop,
        input [15:0] forward_DstData_MEM, forward_DstData_WB,
        input [15:0] SrcData1, SrcData2, imm_16bit,
        output [15:0] aluout,
        output [2:0] flag_new
    );

    // For LW or SW, effective address = ([rs] & 0xFFE) + (imm << 1)

    wire [15:0] aluin1, aluin2, aluin1_SrcData, aluin2_SrcData;

    assign aluin1_SrcData = (forward_aluin1 == 2'b00) ? SrcData1 :
                            (forward_aluin1 == 2'b01) ? forward_DstData_MEM : forward_DstData_WB;
    assign aluin2_SrcData = (forward_aluin2 == 2'b00) ? SrcData2 :
                            (forward_aluin2 == 2'b01) ? forward_DstData_MEM : forward_DstData_WB;

    assign aluin1 = memenable ? (aluin1_SrcData & 16'hFFFE) : aluin1_SrcData;
    assign aluin2 = alusrc ? (memenable ? (imm_16bit << 1) : imm_16bit) : aluin2_SrcData;

    wire err;
    wire [2:0] flag_curr;
    wire [2:0] flag_update;

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
        .flag_en(flag_en),
        .in(flag_new),
        .flag_out(flag_curr)
    );

    wire keep_flag;
    assign keep_flag = branch[0] | branch[1] | pcread | memenable;

    // Update flags (flag = NVZ)
    assign flag_update[2] = keep_flag ? flag_curr[2] :
                        ((aluop == 4'h1 | aluop == 4'h0) ? aluout[15] : flag_curr[2]);
    assign flag_update[1] = keep_flag ? flag_curr[1] :
                        ((aluop == 4'h1 | aluop == 4'h0) ? err : flag_curr[1]);
    assign flag_update[0] = keep_flag ? flag_curr[0] :
                        ((aluop == 4'h1 | aluop == 4'h0 | aluop == 4'h2 | aluop == 4'h3 | aluop == 3'h4 | aluop == 3'h5 | aluop == 3'h6)
                            ? (aluout == 16'h0000) : flag_curr[0]);
    
    assign flag_new = flag_en ? flag_update : flag_curr;

endmodule