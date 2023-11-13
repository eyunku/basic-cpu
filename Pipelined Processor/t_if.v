`include "if.v"

module t_mod_IF();
    // input
    reg clk, rst, freeze;
    reg [15:0] pc_in;
    // output
    wire [15:0] pc_out, instruction;

    IF dut (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .pc_in(pc_in),
        .pc_out(pc_out),
        .instruction(instruction)
    );

    initial begin
        clk = 0; rst = 1; freeze = 0; pc_in = 0;    #40
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        rst = 0; pc_in = 16'h2; #20
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        rst = 0; pc_in = 16'h4; #20
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        rst = 0; freeze = 1; pc_in = 16'h6; #20
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        rst = 0; freeze = 0; pc_in = 16'h6; #20
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        rst = 0; freeze = 0; pc_in = 16'h8; #20
        $display("pc_in: %d pc_out: %d instruction: %h freeze: %b", pc_in, pc_out, instruction, freeze);
        $stop;
        $finish;
    end

    always begin
        #10
        clk = ~clk;
    end

endmodule