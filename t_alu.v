module t_alu();
    reg [15:0] aluin1, aluin2, 
    reg [3:0] aluop;
    wire [15:0] aluout;
    wire err;

    alu dut (
        .aluin1(aluin1),
        .aluin2(aluin2),
        .aluop(aluop),
        .aluout(aluout),
        .err(err)
    );

    // 0000, Add
    // 0001, Sub
    // 0010, Xor
    // 0011, Red
    // 0100, Sll
    // 0101, Sra
    // 0110, Ror
    // 0111, Paddsb
    // 1000, LLB
    // 1001, LHB
    initial begin
        aluop = 4'h0; aluin1 = $random%65536; aluin2 = $random%65536;    #10
#10     if(aluin1 + aluin2 == aluout) $display("ADD: %d", aluout);
        aluop = 4'h1;
#10     if(aluin1 - aluin2 == aluout) $display("SUB: %d", aluout);
        aluop = 4'h2;
#10     if(aluin1^aluin2 == aluout) $display("XOR: %d", aluout);
        aluop = 4'h3; aluin1 = 16'b1010001011100111; aluin2 = 16'b1100011000011110;
        // 111111 10 0110 1101
#10     if(16'hFE6D == aluout) $display("RED: %d", aluout);
        aluop = 4'h4; aluin1 = 16'h1111; aluin2 = 16'h0004;
#10     if(16'h1110 == aluout) $display("SLL: %d", aluout);
        aluop = 4'h5;
#10     if(16'hF111 == aluout) $display("SRA: %d", aluout);
        aluop = 4'h6; aluin1 = 16'h1111; aluin2 = 16'h0001;
#10     if(16'h2222 == aluout)$display("ROR: %d", aluout);
        aluop = 4'h7; aluin1 = 16'h6866; aluin2 = 16'h7A18;
#10     if(16'h787E == aluout) $display("PADDSB: %d", aluout);
        aluop = 4'h8; aluin1 = 16'h1111; aluin2 = 16'hFFFF;
#10     if(16'h11FF == aluout) $display("LLB: %d", aluout);
        aluop = 4'h9;
#10     if(16'hFF11 == aluout) $display("LHB: %d", aluout);
    end

endmodule