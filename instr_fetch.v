// instruction fetch stage

module IF (clk, rst, br_sig, SrcData1, flag_bits, pc_out, instruction);
    //inputs
    input clk, rst;
    input [1:0] br_sig;
    input [15:0] SrcData1;
    input [2:0] flag_bits;
    //outputs
    output [15:0] pc_out, instruction;

// wire
    wire [15:0] pc_next;

// pc control wires
    wire [2:0] C = instruction[11:9];
    wire [2:0] F = flag_bits;
    wire [9:0] I = {instruction[7:0], 1'b0}; // i dont think we can use this
    

// PC register
    pc_16bit_reg pc_reg (
        // inputs
        .clk(clk), 
        .rst(rst), 
        .pc_in(pc_next), 
        // outputs
        .pc_out(pc_out)
    );

// instruction memory fetch
    instruction_memory instruction_mem (
        .data_out(instruction), 
        .data_in(), 
        .addr(pc_out), 
        .enable(1), 
        .wr(0), 
        .clk(clk), 
        .rst(rst)
    );

// PC control
    pc_control pc_control (
        .bsig(br_sig), 
        .C(C), 
        .I(I), 
        .F(F), 
        .regsrc(SrcData1), 
        .PC_in(pc_out), 
        .PC_out(pc_next)
    );
    
endmodule