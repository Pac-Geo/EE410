module temperature_monitor (
    input  wire       sysclk,
    output wire [6:0] seg,
    output wire       cat
);

    wire clk_25m;
    wire locked;
    wire rst_n;

    wire [6:0]  xadc_addr;
    wire        xadc_den;
    wire [15:0] xadc_data;
    wire        xadc_drdy;

    wire        sample_valid;
    wire [15:0] sample_data;
    wire [15:0] average_code;
    wire [15:0] temperature_bcd;

    wire [4:0] xadc_channel;
    wire       xadc_eoc;
    wire       xadc_eos;
    wire       xadc_alarm;
    wire       xadc_vccddro_alarm;
    wire       xadc_vccpaux_alarm;
    wire       xadc_vccpint_alarm;
    wire       xadc_vccaux_alarm;
    wire       xadc_vccint_alarm;
    wire       xadc_user_temp_alarm;
    wire       xadc_busy;
    wire       xadc_ot;

    assign rst_n = locked;

    clk_wiz_0 clock_generator (
        .clk_in1 (sysclk),
        .reset   (1'b0),
        .clk_out1(clk_25m),
        .locked  (locked)
    );

    xadc_wiz_0 xadc (
        .daddr_in           (xadc_addr),
        .dclk_in            (clk_25m),
        .den_in             (xadc_den),
        .di_in              (16'h0000),
        .dwe_in             (1'b0),
        .reset_in           (~rst_n),
        .vp_in              (1'b0),
        .vn_in              (1'b0),
        .do_out             (xadc_data),
        .drdy_out           (xadc_drdy),
        .channel_out        (xadc_channel),
        .eoc_out            (xadc_eoc),
        .eos_out            (xadc_eos),
        .alarm_out          (xadc_alarm),
        .busy_out           (xadc_busy),
        .ot_out             (xadc_ot),
        .vccddro_alarm_out  (xadc_vccddro_alarm),
        .vccpaux_alarm_out  (xadc_vccpaux_alarm),
        .vccpint_alarm_out  (xadc_vccpint_alarm),
        .vccaux_alarm_out   (xadc_vccaux_alarm),
        .vccint_alarm_out   (xadc_vccint_alarm),
        .user_temp_alarm_out(xadc_user_temp_alarm)
    );

    xadc_capture capture_temperature (
        .clk          (clk_25m),
        .rst_n        (rst_n),
        .drdy         (xadc_drdy),
        .data_in      (xadc_data),
        .daddr        (xadc_addr),
        .den          (xadc_den),
        .sample_valid (sample_valid),
        .sample_data  (sample_data)
    );

    average_256 average_samples (
        .clk          (clk_25m),
        .rst_n        (rst_n),
        .sample_valid (sample_valid),
        .sample_data  (sample_data),
        .average_data (average_code)
    );

    blk_mem_gen_0 temperature_lookup (
        .clka (clk_25m),
        .ena  (1'b1),
        .wea  (1'b0),
        .addra(average_code),
        .dina (16'h0000),
        .douta(temperature_bcd)
    );

    pmodssd_display display_temperature (
        .clk         (clk_25m),
        .rst_n       (rst_n),
        .integer_bcd (temperature_bcd[15:8]),
        .seg         (seg),
        .cat         (cat)
    );

endmodule


module xadc_capture (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        drdy,
    input  wire [15:0] data_in,
    output reg  [6:0]  daddr,
    output reg         den,
    output reg         sample_valid,
    output reg  [15:0] sample_data
);

    reg [11:0] sample_timer;
    reg waiting_for_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_timer     <= 12'd0;
            waiting_for_data <= 1'b0;
            daddr            <= 7'h00;
            den              <= 1'b0;
            sample_valid     <= 1'b0;
            sample_data      <= 16'd0;
        end else begin
            den          <= 1'b0;
            sample_valid <= 1'b0;

            if (sample_timer == 12'd2499)
                sample_timer <= 12'd0;
            else
                sample_timer <= sample_timer + 1'b1;

            if (!waiting_for_data && sample_timer == 12'd2499) begin
                daddr            <= 7'h00;
                den              <= 1'b1;
                waiting_for_data <= 1'b1;
            end else if (waiting_for_data && drdy) begin
                sample_data      <= data_in;
                sample_valid     <= 1'b1;
                waiting_for_data <= 1'b0;
            end
        end
    end

endmodule

module average_256 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sample_valid,
    input  wire [15:0] sample_data,
    output reg  [15:0] average_data
);

    reg [23:0] sum;
    reg [7:0]  count;
    wire [23:0] next_sum;

    assign next_sum = sum + {8'b0, sample_data};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum          <= 24'd0;
            count        <= 8'd0;
            average_data <= 16'd0;
        end else if (sample_valid) begin
            if (count == 8'd255) begin
                average_data <= next_sum[23:8];
                sum          <= 24'd0;
                count        <= 8'd0;
            end else begin
                sum   <= next_sum;
                count <= count + 1'b1;
            end
        end
    end

endmodule

module pmodssd_display (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] integer_bcd,
    output reg  [6:0] seg,
    output reg        cat
);

    reg [14:0] refresh_count;
    reg [3:0]  digit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_count <= 15'd0;
            cat           <= 1'b0;
        end else if (refresh_count == 15'd24999) begin
            refresh_count <= 15'd0;
            cat           <= ~cat;
        end else begin
            refresh_count <= refresh_count + 1'b1;
        end
    end

    always @* begin
        if (cat)
            digit = integer_bcd[7:4];
        else
            digit = integer_bcd[3:0];

        case (digit)
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end

endmodule