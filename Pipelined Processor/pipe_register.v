// various registers to store states in-between pipeline modules

// TODO: when flush, just use rst?
module pipe_1b_reg(
        input clk, rst, freeze, flush, src,
        output dst);
    dff reg0(.q(dst), .d(flush ? 1'b0 : src), .wen(~freeze), .clk(clk), .rst(rst));
endmodule

module pipe_2b_reg(
        input clk, rst, freeze, flush,
        input [1:0] src,
        output [1:0] dst);
    pipe_1b_reg reg0(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[0]), .dst(dst[0]));
    pipe_1b_reg reg1(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[1]), .dst(dst[1]));
endmodule

module pipe_4b_reg(
        input clk, rst, freeze, flush,
        input [3:0] src,
        output [3:0] dst);
    pipe_2b_reg reg0(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[1:0]), .dst(dst[1:0]));
    pipe_2b_reg reg1(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[3:2]), .dst(dst[3:2]));
endmodule

module pipe_16b_reg(
        input clk, rst, freeze, flush,
        input [15:0] src,
        output [15:0] dst);
    pipe_4b_reg reg0(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[3:0]), .dst(dst[3:0]));
    pipe_4b_reg reg1(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[7:4]), .dst(dst[7:4]));
    pipe_4b_reg reg2(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[11:8]), .dst(dst[11:8]));
    pipe_4b_reg reg3(.clk(clk), .rst(rst), .freeze(freeze), .flush(flush), .src(src[15:12]), .dst(dst[15:12]));
endmodule
