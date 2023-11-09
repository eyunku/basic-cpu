// Fetches next instruction from PC
module mod_F (
        input clk, rst, freeze,
        input [15:0] pc_in,
        output [15:0] pc_out, instruction);

    pc_16bit_reg pc_reg (
        .clk(clk), 
        .rst(rst),
        .freeze(freeze), // prevents pc from incrementing
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    instruction_memory instruction_mem (
        .data_out(instruction), 
        .data_in(), 
        .addr(pc_out), 
        .enable(1'b1), 
        .wr(1'b0), 
        .clk(clk), 
        .rst(rst)
    );

endmodule