module t_alu();
    reg[3:0] aluop;
    reg[15:0] aluin1, aluin2;
    wire[15:0] aluout;
    wire err;

    alu dut(
        .aluin1(aluin1),
        .aluin2(aluin2),
        .aluop(aluop),
        .aluout(aluout),
        .err(err)
    );

    initial begin
        // test CLA
        aluop = 4'h0; aluin1 = 16'hde15; aluin2 = 16'h3f3d; // 1d52, with overflow
        #10
        $display("Test ADD\nExpected value: 1d52 w/ err 1. Calculated value: %h w/ err %b\n", aluout, err);
        aluop = 4'h1; // subtraction of same values: 9ed8, no overflow
        #10
        $display("Test SUB\nExpected value: 9e38 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test XOR
        aluop = 4'h2;
        #10
        $display("Test XOR\nExpected value: %h w/ err 0. Calculated value: %h w/ err %b\n", 16'hde15 ^ 16'h3f3d, aluout, err);
        // test RED
        aluop = 4'h3; aluin1 = 16'h1122; aluin2 = 16'h9977; // 11 + 99 = aa, 22 + 77 = 99; 99 + aa = 0143
        #10
        $display("Test RED\nExpected value: 0143 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test SLL
        aluop = 4'h4; aluin1 = 16'h0001; aluin2 = 16'h0001; // shift left multiplies by 2
        #10
        $display("Test SLL\nExpected value: 0002 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test SRA
        aluop = 4'h5; aluin1 = 16'h0004; aluin2 = 16'h0001; // shift right divides by 2
        #10
        $display("Test SRA\nExpected value: 0002 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test ROR
        aluop = 4'h6; aluin1 = 16'h2222; aluin2 = 16'h0005;
        #10
        $display("Test ROR\nExpected value: 1111 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test PADDSB
        aluop = 4'h7; aluin1 = 16'h1234; aluin2 = 16'h1234;
        #10
        $display("Test PADDSB\nExpected value: 2468 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test LLB
        aluop = 4'h8; aluin1 = 16'h1111; aluin2 = 16'h8888;
        #10
        $display("Test LLB\nExpected value: 1188 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
        // test LHB
        aluop = 4'h9;
        #10
        $display("Test LHB\nExpected value: 8811 w/ err 0. Calculated value: %h w/ err %b\n", aluout, err);
    end
endmodule