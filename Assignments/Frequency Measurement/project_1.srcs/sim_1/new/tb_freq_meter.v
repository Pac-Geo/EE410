
`timescale 1ns / 1ps

module freq_meter_calc #(
    // 125 MHz system clock:
    // 1.5 s total gate period, 0.25 s on each side
    parameter CNT_GATE_S_MAX = 28'd187_499_999,
    parameter CNT_RISE_MAX   = 28'd31_250_000
)(
    input  wire        sys_clk,
    input  wire        sys_rst_n,
    input  wire        clk_test,
    output reg  [33:0] freq
);

    // Generate the required 100 MHz reference clock
    wire clk_stand;
    wire clk_locked;

    clk_gen clk_gen_inst (
        .clk_in1  (sys_clk),
        .reset    (~sys_rst_n),
        .clk_out1 (clk_stand),
        .locked   (clk_locked)
    );

    // Gate registers
    reg [27:0] cnt_gate_s = 0;
    wire gate_s;
    reg gate_a = 0;

    // Measurement counters
    reg [31:0] cnt_clk_test = 0;
    reg [31:0] cnt_clk_stand = 0;

    // Saved counts
    reg [31:0] cnt_clk_test_reg = 0;
    reg [31:0] cnt_clk_stand_reg = 0;

    // Gate edge detection
    reg gate_a_test = 0;
    reg gate_a_stand = 0;
    reg gate_a_stand_d = 0;

    wire gate_a_fall_test;
    wire gate_a_fall_stand;

    // Calculation registers
    reg calc_flag = 0;
    reg calc_flag_reg = 0;
    reg [33:0] freq_reg = 0;

    // =========================================
    // Part 1: Software gate
    // =========================================

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_gate_s <= 0;
        else if (cnt_gate_s == CNT_GATE_S_MAX)
            cnt_gate_s <= 0;
        else
            cnt_gate_s <= cnt_gate_s + 1'b1;
    end

    assign gate_s =
        (cnt_gate_s > CNT_RISE_MAX) &&
        (cnt_gate_s <= CNT_GATE_S_MAX - CNT_RISE_MAX);

    // =========================================
    // Part 2: Actual gate
    // =========================================

    always @(posedge clk_test or negedge sys_rst_n) begin
        if (!sys_rst_n)
            gate_a <= 0;
        else
            gate_a <= gate_s;
    end

    // =========================================
    // Part 3: Count and capture clock cycles
    // =========================================

    // Detect falling edge in test-clock domain
    always @(posedge clk_test or negedge sys_rst_n) begin
        if (!sys_rst_n)
            gate_a_test <= 0;
        else
            gate_a_test <= gate_a;
    end

    assign gate_a_fall_test = gate_a_test && !gate_a;

    // Count while open; hold through capture;
    // reset after the count has been saved.
    always @(posedge clk_test or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_clk_test <= 0;
            cnt_clk_test_reg <= 0;
        end else begin
            if (gate_a)
                cnt_clk_test <= cnt_clk_test + 1'b1;
            else if (!gate_a_test)
                cnt_clk_test <= 0;

            if (gate_a_fall_test)
                cnt_clk_test_reg <= cnt_clk_test;
        end
    end

    // Synchronize gate into reference-clock domain
    always @(posedge clk_stand or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            gate_a_stand   <= 0;
            gate_a_stand_d <= 0;
        end else if (!clk_locked) begin
            gate_a_stand   <= 0;
            gate_a_stand_d <= 0;
        end else begin
            gate_a_stand   <= gate_a;
            gate_a_stand_d <= gate_a_stand;
        end
    end

    assign gate_a_fall_stand =
        gate_a_stand_d && !gate_a_stand;

    // Count reference clock and capture result
    always @(posedge clk_stand or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_clk_stand <= 0;
            cnt_clk_stand_reg <= 0;
        end else if (!clk_locked) begin
            cnt_clk_stand <= 0;
            cnt_clk_stand_reg <= 0;
        end else begin
            if (gate_a_stand)
                cnt_clk_stand <= cnt_clk_stand + 1'b1;
            else if (!gate_a_stand_d)
                cnt_clk_stand <= 0;

            if (gate_a_fall_stand)
                cnt_clk_stand_reg <= cnt_clk_stand;
        end
    end

    // =========================================
    // Part 4: Frequency calculation
    // fx = (X * 100,000,000) / Y
    // =========================================

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            calc_flag <= 0;
        else
            calc_flag <= (cnt_gate_s == CNT_GATE_S_MAX);
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            freq_reg      <= 0;
            calc_flag_reg <= 0;
            freq          <= 0;
        end else begin
            calc_flag_reg <= calc_flag;

            if (calc_flag && cnt_clk_stand_reg != 0)
                freq_reg <=
                    ({32'd0, cnt_clk_test_reg} *
                     64'd100_000_000) /
                    {32'd0, cnt_clk_stand_reg};

            if (calc_flag_reg)
                freq <= freq_reg;
        end
    end

endmodule
