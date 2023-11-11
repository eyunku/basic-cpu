// Fetches next instruction from PC
module mod_F (
        input clk, rst, freeze,
        input [1:0] branch,
        input [15:0] pc_in,
        output [15:0] pc_out, instruction);

    wire [15:0] pc_curr;
    wire [15:0] pc_next;
    pc_16bit_reg pc_reg (
        .clk(clk), 
        .rst(rst),
        .freeze(freeze), // prevents pc from incrementing
        .pc_in(pc_next), 
        .pc_out(pc_curr)
    );

    instruction_memory instruction_mem (
        .data_out(instruction), 
        .data_in(), 
        .addr(pc_curr), 
        .enable(1'b1), 
        .wr(1'b0), 
        .clk(clk), 
        .rst(rst)
    );

    carry_lookahead next(.a(pc_curr), .b(16'h2), .sum(pc_out), .overflow(), .mode(1'b0));
    assign pc_next = branch ? pc_in : pc_out;
endmodule