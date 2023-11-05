// new modulized cpu

module cpu_(clk, rst_n, hlt, pc);
    // module inputs
    input clk, rst_n;

    // module outputs
    output [15:0] pc;
    output hlt;

    // flip reset register
    wire rst = ~rst_n;

    // IF/ID wires
    wire [15:0] pc_curr;
    wire [15:0] instruction;

    // ID/EX wires
    wire [3:0] SrcReg1, SrcReg2;
    wire [15:0] DstData, SrcData1, SrcData2;
    // control signals
    wire regwrite, alusrc, memenable, memwrite, memtoreg, pcread, alusext, rdsrc;
    wire [1:0] branch;
    wire [3:0] aluop;
    // sext
    wire [15:0] sextimm;

    // resolve cpu output signals
    assign pc = pc_curr;
    assign hlt = (branch == 2'b11);

    // EX/MEM wires
    wire [15:0] aluout;
    // wire err; do we need this????
    wire [2:0] flag_bits;

    // MEM/WB wire
    wire [15:0] mem_out;

    // WB wire
    wire [15:0] pcs;


    // FETCH STAGE
    IF fetch(
        //inputs
        .clk(clk),
        .rst(rst),
        .br_sig(branch),
        .SrcData1(SrcData1),
        .flag_bits(flag_bits),
        //outputs
        .pc_out(pc_curr),
        .instruction(instruction)
    );

    // DECODE STAGE
    ID decode(
        //inputs
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .DstData(DstData),
        //outputs
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .sextimm(sextimm),
        //control signal outputs
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .memenable(memenable), 
        .memwrite(memwrite), 
        .aluop(aluop), 
        .memtoreg(memtoreg), 
        .branch(branch), 
        .alusext(alusext), 
        .pcread(pcread), 
        .rdsrc(rdsrc)
    );

    // EXECUTION
    EX execute(
        //inputs
        .clk(clk),
        .rst(rst),
        .SrcData1(SrcData1),
        .SrcData2(SrcData2),
        .sextimm(sextimm),
        .memenable(memenable),
        .aluop(aluop),
        .alusrc(alusrc),
        //outputs
        .aluout(aluout),
        //.err(err),
        .flag_out(flag_bits)
    );
    // mem and writeback will be recieving aluout

    // MEMORY
    MEM mem_access(
        //inputs
        .clk(clk),
        .rst(rst),
        .SrcData2(SrcData2),
        .alutomem(aluout),
        .memenable(memenable),
        .memwrite(memwrite),
        //outputs
        .mem_out(mem_out)
    );

    // WRITEBACK
    WB writeback(
        //inputs
        .pcread(pcread),
        .memtoreg(memtoreg),
        .pc_curr(pc_curr),
        .mem_out(mem_out),
        .alutowb(aluout),
        //outputs
        .DstData(DstData)
    );

endmodule