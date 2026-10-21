
`timescale 1ns / 1ps

module tb_pll_top;

    reg clk_in = 0;
    reg reset = 1;

    wire clk_out;
    wire locked;

    // Instantiate our PLL design
    pll_top uut (
        .clk_in  (clk_in),
        .reset   (reset),
        .clk_out (clk_out),
        .locked  (locked)
    );

    // Generate 125 MHz input clock (8 ns period)
    always #4 clk_in = ~clk_in;

    initial begin
        // Hold PLL in reset initially
        #100;
        reset = 0;

        // Allow time for PLL to achieve lock
        #100000;

        $finish;
    end

endmodule
