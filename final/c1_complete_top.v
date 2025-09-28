`timescale 1ns / 1ps

module c1_complete_top (
    input               clk,
    input               reset_n,

    // Control signals
    input               i_start,
    output              o_done,

    // Pixel input interface
    input               pixel_in_valid,
    input signed [7:0]  pixel_in,
    output              pixel_ready,

    // Convolution control
    input               i_conv_ready,

    // Configuration
    input               relu_en,
    input               quan_en,

    // Final output interface - 6 channels of 14x14 (after maxpooling)
    output reg [7:0]    final_out_ch0,
    output reg [7:0]    final_out_ch1,
    output reg [7:0]    final_out_ch2,
    output reg [7:0]    final_out_ch3,
    output reg [7:0]    final_out_ch4,
    output reg [7:0]    final_out_ch5,
    output reg          final_out_valid,

    // Debug outputs
    output [4:0]        o_window_col,
    output [4:0]        o_output_row,
    output              o_conv_row_start,
    output              o_conv_row_end,
    output              conv_layer_done,
    output [1:0]        reg_controller_state
);

    // Internal signals between convolution layer and register controller
    wire [7:0] conv_out_ch0, conv_out_ch1, conv_out_ch2;
    wire [7:0] conv_out_ch3, conv_out_ch4, conv_out_ch5;
    wire conv_out_valid;

    // Internal signals between register controller and maxpooling
    wire pool_valid;
    wire [31:0] pool_ch0, pool_ch1, pool_ch2;
    wire [31:0] pool_ch3, pool_ch4, pool_ch5;

    // Internal signals from maxpooling
    wire mp_out_valid;
    wire [7:0] mp_out_ch0, mp_out_ch1, mp_out_ch2;
    wire [7:0] mp_out_ch3, mp_out_ch4, mp_out_ch5;

    // Convolution layer instance (existing c1_layer_top)
    c1_layer_top u_conv_layer (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .o_done(conv_layer_done),
        .pixel_in_valid(pixel_in_valid),
        .pixel_in(pixel_in),
        .pixel_ready(pixel_ready),
        .i_conv_ready(i_conv_ready),
        .relu_en(relu_en),
        .quan_en(quan_en),
        .out_ch0(conv_out_ch0),
        .out_ch1(conv_out_ch1),
        .out_ch2(conv_out_ch2),
        .out_ch3(conv_out_ch3),
        .out_ch4(conv_out_ch4),
        .out_ch5(conv_out_ch5),
        .out_valid(conv_out_valid),
        .o_window_col(o_window_col),
        .o_output_row(o_output_row),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end)
    );

    // Register controller instance
    c1_reg_controller u_reg_controller (
        .clk(clk),
        .reset_n(reset_n),
        .conv_ch0(conv_out_ch0),
        .conv_ch1(conv_out_ch1),
        .conv_ch2(conv_out_ch2),
        .conv_ch3(conv_out_ch3),
        .conv_ch4(conv_out_ch4),
        .conv_ch5(conv_out_ch5),
        .conv_valid(conv_out_valid),
        .pool_valid(pool_valid),
        .pool_ch0(pool_ch0),
        .pool_ch1(pool_ch1),
        .pool_ch2(pool_ch2),
        .pool_ch3(pool_ch3),
        .pool_ch4(pool_ch4),
        .pool_ch5(pool_ch5)
    );

    // Maxpooling unit instance
    c1_maxpooling_unit u_maxpooling (
        .clk(clk),
        .reset_n(reset_n),
        .pool_valid(pool_valid),
        .pool_ch0(pool_ch0),
        .pool_ch1(pool_ch1),
        .pool_ch2(pool_ch2),
        .pool_ch3(pool_ch3),
        .pool_ch4(pool_ch4),
        .pool_ch5(pool_ch5),
        .mp_out_valid(mp_out_valid),
        .mp_out_ch0(mp_out_ch0),
        .mp_out_ch1(mp_out_ch1),
        .mp_out_ch2(mp_out_ch2),
        .mp_out_ch3(mp_out_ch3),
        .mp_out_ch4(mp_out_ch4),
        .mp_out_ch5(mp_out_ch5)
    );

    // Output capture logic
    always @(posedge clk) begin
        if (!reset_n) begin
            final_out_ch0 <= 8'd0;
            final_out_ch1 <= 8'd0;
            final_out_ch2 <= 8'd0;
            final_out_ch3 <= 8'd0;
            final_out_ch4 <= 8'd0;
            final_out_ch5 <= 8'd0;
            final_out_valid <= 1'b0;
        end else begin
            if (mp_out_valid) begin
                final_out_ch0 <= mp_out_ch0;
                final_out_ch1 <= mp_out_ch1;
                final_out_ch2 <= mp_out_ch2;
                final_out_ch3 <= mp_out_ch3;
                final_out_ch4 <= mp_out_ch4;
                final_out_ch5 <= mp_out_ch5;
                final_out_valid <= 1'b1;

                // Debug: Show non-zero final outputs
                if (|mp_out_ch0 || |mp_out_ch1 || |mp_out_ch2 ||
                    |mp_out_ch3 || |mp_out_ch4 || |mp_out_ch5) begin
                    $display("FINAL OUTPUT: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t",
                            mp_out_ch0, mp_out_ch1, mp_out_ch2, mp_out_ch3, mp_out_ch4, mp_out_ch5, $time);
                end
            end else begin
                final_out_valid <= 1'b0;
            end
        end
    end

    // Overall done signal - when convolution is done and no more pooling outputs
    reg conv_done_reg;
    reg [15:0] no_output_cnt;

    always @(posedge clk) begin
        if (!reset_n) begin
            conv_done_reg <= 1'b0;
            no_output_cnt <= 16'd0;
        end else begin
            if (conv_layer_done) begin
                conv_done_reg <= 1'b1;
            end

            if (conv_done_reg) begin
                if (mp_out_valid) begin
                    no_output_cnt <= 16'd0;
                end else begin
                    no_output_cnt <= no_output_cnt + 1'b1;
                end
            end
        end
    end

    assign o_done = conv_done_reg && (no_output_cnt > 16'd100); // Done after no outputs for 100 cycles

    // Debug assignments
    assign reg_controller_state = u_reg_controller.c_state;

endmodule