// Fetches next instruction from PC
module mod_F (
        input clk, rst, freeze, taken,
        input [1:0] branch,
        input [15:0] pc_in,
        output [15:0] pc_curr, // for t_cpu to display
        output [15:0] pc_curr2, // pc_curr + 2. for IF_ID pipeline reg
        output [15:0] instruction);

    wire [15:0] pc_next;

    pc_16bit_reg pc_reg (
        .clk(clk), 
        .rst(rst),
        .freeze(freeze), // prevents pc from incrementing
        .pc_in(pc_next), 
        .pc_out(pc_curr));

    instruction_memory instruction_mem (
        .data_out(instruction), 
        .data_in(), 
        .addr(pc_curr), 
        .enable(~freeze), 
        .wr(1'b0), 
        .clk(clk), 
        .rst(rst));

    // adder
    carry_lookahead next(.a(pc_curr), .b(16'h2), .sum(pc_curr2), .overflow(), .mode(1'b0));
    // mux
    assign pc_next = (instruction[15:12] == 4'hF & ~taken) ? pc_curr : 
                     ((branch[0] | branch[1]) & taken) ? pc_in : pc_curr2;
endmodule
