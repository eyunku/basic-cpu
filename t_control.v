module t_control();
    reg [3:0] opcode;
    wire regwrite, alusrc, memread, memwrite, memtoreg, branch, pcread;
    wire [2:0] alusext;
    wire [3:0] aluop;

    control dut (
        .opcode(opcode), 
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .memread(memread), 
        .memwrite(memwrite), 
        .aluop(aluop), 
        .memtoreg(memtoreg), 
        .branch(branch), 
        .alusext(alusext), 
        .pcread(pcread)
    );

    initial 
    begin
        opcode = 4'b1000;  #10
        if (~((regwrite == 1'b1) & (alusrc == 1'b1) & (memread == 1'b1) & (aluop == 4'b0))) begin
            $display(opcode);
            $display(
                "regwrite: %b alusrc: %b memread: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %d", 
                regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch, alusext, pcread
            );
        end
        opcode = 4'b0000;  #10
        if (~((regwrite == 1'b1) & (alusrc == 1'b0) & (memread == 1'b0) & (aluop == 4'b0))) begin
            $display(opcode);
            $display(
                "regwrite: %b alusrc: %b memread: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %d", 
                regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch, alusext, pcread
            );
        end
        opcode = 4'b0100;  #10
        if (~((regwrite == 1'b1) & (alusrc == 1'b1) & (memread == 1'b0) & (aluop == 4'b0100))) begin
            $display(opcode);
            $display(
                "regwrite: %b alusrc: %b memread: %b memwrite: %b aluop: %b memtoreg: %b branch: %b alusext: %b pcread: %d", 
                regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch, alusext, pcread
            );
        end
    end
endmodule