module t_control();
    reg [3:0] opcode;
    wire regwrite, alusrc, memread, memwrite, memtoreg, branch;
    wire [3:0] aluop;

    control dut (
        .opcode(opcode), 
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .memread(memread), 
        .memwrite(memwrite), 
        .aluop(aluop), 
        .memtoreg(memtoreg), 
        .branch(branch)
    );

    initial 
    begin
        opcode = 4'b1000;  
	#10
	$display(opcode);
        $display(
            "regwrite: %b alusrc: %b memread: %b memwrite: %b aluop: %b memtoreg: %b branch: %b", 
            regwrite, alusrc, memread, memwrite, aluop, memtoreg, branch
        );
    end
endmodule
