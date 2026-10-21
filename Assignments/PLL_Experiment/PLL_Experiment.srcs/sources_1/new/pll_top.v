`timescale 1ns / 1ps
module pll_top (
    input  wire clk_in,
    input  wire reset,
    output wire clk_out,
    output wire locked
);

    clk_wiz_0 pll_inst (
        .clk_in1  (clk_in),
        .reset    (reset),
        .clk_out1 (clk_out),
        .locked   (locked)
    );

endmodule
