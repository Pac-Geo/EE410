`timescale 1ns / 1ps
module freq_meter (
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire clk_test,
    output wire clk_out,
    output wire [6:0] ssd_seg,  // {G,F,E,D,C,B,A}, active high
    output wire ssd_sel          // digit selection
);

    wire [33:0] freq;

    clk_test_gen clk_gen_test_inst (
        .clk_in1(sys_clk),
        .reset(~sys_rst_n),
        .clk_out1(clk_out)
    );

    freq_meter_calc freq_meter_calc_inst (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .clk_test(clk_test),
        .freq(freq)
    );

    pmod_ssd display_inst (
        .clk(sys_clk),
        .rst_n(sys_rst_n),
        .frequency_hz(freq),
        .segments(ssd_seg),
        .digit_select(ssd_sel)
    );
endmodule
