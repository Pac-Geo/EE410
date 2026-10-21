
`timescale 1ns / 1ps

module freq_meter_calc #(
    parameter CNT_GATE_S_MAX = 28'd187_499_999,
    parameter CNT_RISE_MAX   = 28'd31_250_000
)(
    input  wire        sys_clk,
    input  wire        sys_rst_n,
    input  wire        clk_test,
    output reg [33:0] freq = 0
);

    // ========================================
    // 100 MHz reference clock
    // ========================================

    wire clk_stand;
    wire clk_locked;

    clk_gen clk_gen_inst (
        .clk_in1(sys_clk),
        .reset(~sys_rst_n),
        .clk_out1(clk_stand),
        .locked(clk_locked)
    );

    // ========================================
    // Part 1: Software gate (125 MHz)
    // ========================================

    reg [27:0] cnt_gate_s = 0;
    reg gate_s = 0;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_gate_s <= 0;
            gate_s <= 0;
        end else begin
            if (cnt_gate_s == CNT_GATE_S_MAX)
                cnt_gate_s <= 0;
            else
                cnt_gate_s <= cnt_gate_s + 1'b1;

            // Register the gate before crossing clock domains.
            gate_s <=
                (cnt_gate_s > CNT_RISE_MAX) &&
                (cnt_gate_s <= CNT_GATE_S_MAX - CNT_RISE_MAX);
        end
    end

    // ========================================
    // Part 2: Actual gate (test clock)
    // ========================================

    (* ASYNC_REG = "TRUE" *) reg gate_s_meta = 0;
    (* ASYNC_REG = "TRUE" *) reg gate_a = 0;

    always @(posedge clk_test or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            gate_s_meta <= 0;
            gate_a <= 0;
        end else begin
            gate_s_meta <= gate_s;
            gate_a <= gate_s_meta;
        end
    end

    // ========================================
    // Part 3: Clock counters
    // ========================================

    reg [31:0] cnt_clk_test = 0;
    reg [31:0] cnt_clk_stand = 0;

    reg [31:0] cnt_clk_test_reg = 0;
    reg [31:0] cnt_clk_stand_reg = 0;

    reg gate_a_test = 0;

    wire gate_a_fall_test =
        gate_a_test && !gate_a;

    always @(posedge clk_test or negedge sys_rst_n) begin
        if (!sys_rst_n)
            gate_a_test <= 0;
        else
            gate_a_test <= gate_a;
    end

    // Test clock count and capture

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

    // ========================================
    // Reference-clock gate synchronizer
    // ========================================

    (* ASYNC_REG = "TRUE" *) reg gate_a_meta = 0;
    (* ASYNC_REG = "TRUE" *) reg gate_a_stand = 0;

    reg gate_a_stand_d = 0;

    wire gate_a_fall_stand =
        gate_a_stand_d && !gate_a_stand;

    always @(posedge clk_stand or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            gate_a_meta <= 0;
            gate_a_stand <= 0;
            gate_a_stand_d <= 0;
        end else if (!clk_locked) begin
            gate_a_meta <= 0;
            gate_a_stand <= 0;
            gate_a_stand_d <= 0;
        end else begin
            gate_a_meta <= gate_a;
            gate_a_stand <= gate_a_meta;
            gate_a_stand_d <= gate_a_stand;
        end
    end

    // Reference clock count and capture

    reg capture_toggle = 0;

    always @(posedge clk_stand or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_clk_stand <= 0;
            cnt_clk_stand_reg <= 0;
            capture_toggle <= 0;
        end else if (!clk_locked) begin
            cnt_clk_stand <= 0;
            cnt_clk_stand_reg <= 0;
            capture_toggle <= 0;
        end else begin
            if (gate_a_stand)
                cnt_clk_stand <= cnt_clk_stand + 1'b1;
            else if (!gate_a_stand_d)
                cnt_clk_stand <= 0;

            if (gate_a_fall_stand) begin
                cnt_clk_stand_reg <= cnt_clk_stand;
                capture_toggle <= ~capture_toggle;
            end
        end
    end

    // ========================================
    // Part 4: Transfer captured counts
    // into the 125 MHz clock domain
    // ========================================

    (* ASYNC_REG = "TRUE" *)
    reg [31:0] cnt_clk_test_meta = 0;

    (* ASYNC_REG = "TRUE" *)
    reg [31:0] cnt_clk_test_sync = 0;

    (* ASYNC_REG = "TRUE" *)
    reg [31:0] cnt_clk_stand_meta = 0;

    (* ASYNC_REG = "TRUE" *)
    reg [31:0] cnt_clk_stand_sync = 0;

    (* ASYNC_REG = "TRUE" *)
    reg capture_toggle_meta = 0;

    (* ASYNC_REG = "TRUE" *)
    reg capture_toggle_sync = 0;

    reg capture_toggle_d = 0;

    wire capture_event =
        capture_toggle_sync ^ capture_toggle_d;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt_clk_test_meta <= 0;
            cnt_clk_test_sync <= 0;

            cnt_clk_stand_meta <= 0;
            cnt_clk_stand_sync <= 0;

            capture_toggle_meta <= 0;
            capture_toggle_sync <= 0;
            capture_toggle_d <= 0;
        end else begin
            cnt_clk_test_meta <= cnt_clk_test_reg;
            cnt_clk_test_sync <= cnt_clk_test_meta;

            cnt_clk_stand_meta <= cnt_clk_stand_reg;
            cnt_clk_stand_sync <= cnt_clk_stand_meta;

            capture_toggle_meta <= capture_toggle;
            capture_toggle_sync <= capture_toggle_meta;
            capture_toggle_d <= capture_toggle_sync;
        end
    end

    // Allow captured values to settle before calculation.

    reg [5:0] capture_wait = 0;
    reg capture_pending = 0;

    // ========================================
    // Part 5: Sequential frequency calculation
    //
    // fx = (X * 100,000,000) / Y
    //
    // 59-cycle unsigned restoring division
    // ========================================

    reg [58:0] dividend_shift = 0;
    reg [42:0] product_lo = 0;
    reg [42:0] product_hi = 0;
    reg [58:0] product_sum = 0;
    reg [1:0] mult_stage = 0;
    reg [58:0] quotient_shift = 0;

    reg [32:0] remainder = 0;
    reg [31:0] divisor = 0;

    reg [5:0] div_count = 0;
    reg div_busy = 0;

    wire [32:0] shifted_remainder =
        {remainder[31:0], dividend_shift[58]};

    wire subtract_enable =
        shifted_remainder >= {1'b0, divisor};

    wire [32:0] next_remainder =
        subtract_enable ?
        shifted_remainder - {1'b0, divisor} :
        shifted_remainder;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            capture_wait <= 0;
            capture_pending <= 0;

            product_lo <= 0;
            product_hi <= 0;
            product_sum <= 0;
            mult_stage <= 0;

            dividend_shift <= 0;
            quotient_shift <= 0;
            remainder <= 0;
            divisor <= 0;
            div_count <= 0;
            div_busy <= 0;
            freq <= 0;

        end else begin
            if (capture_event) begin
                capture_pending <= 1'b1;
                capture_wait <= 6'd32;
            end else if (capture_pending && capture_wait != 0) begin
                capture_wait <= capture_wait - 1'b1;
            end

            if (div_busy) begin
                remainder <= next_remainder;
                dividend_shift <= {dividend_shift[57:0], 1'b0};
                quotient_shift <= {quotient_shift[57:0], subtract_enable};
                div_count <= div_count - 1'b1;

                if (div_count == 1) begin
                    div_busy <= 0;
                    freq <= {quotient_shift[32:0], subtract_enable};
                end

            end else if (capture_pending && capture_wait == 0) begin

                case (mult_stage)
                    2'd0: begin
                        if (cnt_clk_stand_sync != 0) begin
                            product_lo <=
                                cnt_clk_test_sync[15:0] * 27'd100_000_000;

                            product_hi <=
                                cnt_clk_test_sync[31:16] * 27'd100_000_000;

                            divisor <= cnt_clk_stand_sync;
                            mult_stage <= 2'd1;
                        end
                    end

                    2'd1: begin
                        product_sum <=
                            {16'b0, product_lo} +
                            {product_hi, 16'b0};

                        mult_stage <= 2'd2;
                    end

                    2'd2: begin
                        dividend_shift <= product_sum;
                        quotient_shift <= 0;
                        remainder <= 0;
                        div_count <= 6'd59;
                        div_busy <= 1'b1;
                        capture_pending <= 0;
                        mult_stage <= 0;
                    end

                    default: mult_stage <= 0;
                endcase
            end
        end
    end

endmodule
