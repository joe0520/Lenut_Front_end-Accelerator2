module c1_layer_top (
    input               clk,
    input               reset_n,
    
    // Control signals
    input               i_start,
    output              o_done,
    
    // Pixel input interface
    input               pixel_in_valid,
    input signed [7:0]  pixel_in,
    
    // Convolution control
    input               i_conv_ready,
    
    // Configuration
    input               relu_en,
    input               quan_en,
    
    // Output interface - 6 channels of 28x28
    output reg [7:0]    out_ch0,
    output reg [7:0]    out_ch1,
    output reg [7:0]    out_ch2,
    output reg [7:0]    out_ch3,
    output reg [7:0]    out_ch4,
    output reg [7:0]    out_ch5,
    output reg          out_valid,
    
    // Debug outputs
    output [4:0]        o_window_col,
    output [4:0]        o_output_row,
    output              o_conv_row_start,
    output              o_conv_row_end
);

    // Internal signals
    wire o_conv_valid;
    wire signed [7:0] window_0_0, window_0_1, window_0_2, window_0_3, window_0_4;
    wire signed [7:0] window_1_0, window_1_1, window_1_2, window_1_3, window_1_4;
    wire signed [7:0] window_2_0, window_2_1, window_2_2, window_2_3, window_2_4;
    wire signed [7:0] window_3_0, window_3_1, window_3_2, window_3_3, window_3_4;
    wire signed [7:0] window_4_0, window_4_1, window_4_2, window_4_3, window_4_4;
    
    // Weight signals for each channel
    reg signed [7:0] weight_ch0 [0:24];
    reg signed [7:0] weight_ch1 [0:24];
    reg signed [7:0] weight_ch2 [0:24];
    reg signed [7:0] weight_ch3 [0:24];
    reg signed [7:0] weight_ch4 [0:24];
    reg signed [7:0] weight_ch5 [0:24];
    
    // Weight memory interface
    reg weight_req;
    reg [2:0] kernel_idx;
    wire signed [7:0] weight_0, weight_1, weight_2, weight_3, weight_4;
    wire signed [7:0] weight_5, weight_6, weight_7, weight_8, weight_9;
    wire signed [7:0] weight_10, weight_11, weight_12, weight_13, weight_14;
    wire signed [7:0] weight_15, weight_16, weight_17, weight_18, weight_19;
    wire signed [7:0] weight_20, weight_21, weight_22, weight_23, weight_24;
    wire weight_valid;
    
    // PE outputs
    wire [7:0] pe_out_ch0, pe_out_ch1, pe_out_ch2;
    wire [7:0] pe_out_ch3, pe_out_ch4, pe_out_ch5;
    wire valid_out_ch0, valid_out_ch1, valid_out_ch2;
    wire valid_out_ch3, valid_out_ch4, valid_out_ch5;
    
    // State machine
    reg [2:0] state;
    localparam IDLE         = 3'd0;
    localparam SET_IDX      = 3'd1;
    localparam PULSE_REQ    = 3'd2;
    localparam WAIT_WEIGHT  = 3'd3;
    localparam NEXT_KERNEL  = 3'd4;
    localparam READY        = 3'd5;
    
    // Control signals
    reg weights_loaded;
    reg [3:0] wait_cnt;
    reg line_controller_start;
    wire line_controller_done;
    
    integer i;
    
    // Line buffer controller
    in_line_controller u_line_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(line_controller_start),
        .o_done(line_controller_done),
        .pixel_in_valid(pixel_in_valid),
        .pixel_in(pixel_in),
        .o_conv_valid(o_conv_valid),
        .i_conv_ready(i_conv_ready & weights_loaded),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end),
        .window_0_0(window_0_0), .window_0_1(window_0_1), .window_0_2(window_0_2), 
        .window_0_3(window_0_3), .window_0_4(window_0_4),
        .window_1_0(window_1_0), .window_1_1(window_1_1), .window_1_2(window_1_2), 
        .window_1_3(window_1_3), .window_1_4(window_1_4),
        .window_2_0(window_2_0), .window_2_1(window_2_1), .window_2_2(window_2_2), 
        .window_2_3(window_2_3), .window_2_4(window_2_4),
        .window_3_0(window_3_0), .window_3_1(window_3_1), .window_3_2(window_3_2), 
        .window_3_3(window_3_3), .window_3_4(window_3_4),
        .window_4_0(window_4_0), .window_4_1(window_4_1), .window_4_2(window_4_2), 
        .window_4_3(window_4_3), .window_4_4(window_4_4),
        .o_window_col(o_window_col),
        .o_output_row_cnt(o_output_row)
    );
    
    // Weight memory
    c1_weight_memory u_weight_mem (
        .clk(clk),
        .rst_n(reset_n),
        .weight_req(weight_req),
        .kernel_idx(kernel_idx),
        .weight_0(weight_0), .weight_1(weight_1), .weight_2(weight_2),
        .weight_3(weight_3), .weight_4(weight_4), .weight_5(weight_5),
        .weight_6(weight_6), .weight_7(weight_7), .weight_8(weight_8),
        .weight_9(weight_9), .weight_10(weight_10), .weight_11(weight_11),
        .weight_12(weight_12), .weight_13(weight_13), .weight_14(weight_14),
        .weight_15(weight_15), .weight_16(weight_16), .weight_17(weight_17),
        .weight_18(weight_18), .weight_19(weight_19), .weight_20(weight_20),
        .weight_21(weight_21), .weight_22(weight_22), .weight_23(weight_23),
        .weight_24(weight_24),
        .weight_valid(weight_valid)
    );
    
    // PE instances - Channel 0
    conv_pe_5x5 u_pe_ch0 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch0), .pe_out(pe_out_ch0),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch0[0]), .in_W2(weight_ch0[1]), .in_W3(weight_ch0[2]), 
        .in_W4(weight_ch0[3]), .in_W5(weight_ch0[4]),
        .in_W6(weight_ch0[5]), .in_W7(weight_ch0[6]), .in_W8(weight_ch0[7]), 
        .in_W9(weight_ch0[8]), .in_W10(weight_ch0[9]),
        .in_W11(weight_ch0[10]), .in_W12(weight_ch0[11]), .in_W13(weight_ch0[12]), 
        .in_W14(weight_ch0[13]), .in_W15(weight_ch0[14]),
        .in_W16(weight_ch0[15]), .in_W17(weight_ch0[16]), .in_W18(weight_ch0[17]), 
        .in_W19(weight_ch0[18]), .in_W20(weight_ch0[19]),
        .in_W21(weight_ch0[20]), .in_W22(weight_ch0[21]), .in_W23(weight_ch0[22]), 
        .in_W24(weight_ch0[23]), .in_W25(weight_ch0[24])
    );
    
    // PE Channel 1
    conv_pe_5x5 u_pe_ch1 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch1), .pe_out(pe_out_ch1),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch1[0]), .in_W2(weight_ch1[1]), .in_W3(weight_ch1[2]), 
        .in_W4(weight_ch1[3]), .in_W5(weight_ch1[4]),
        .in_W6(weight_ch1[5]), .in_W7(weight_ch1[6]), .in_W8(weight_ch1[7]), 
        .in_W9(weight_ch1[8]), .in_W10(weight_ch1[9]),
        .in_W11(weight_ch1[10]), .in_W12(weight_ch1[11]), .in_W13(weight_ch1[12]), 
        .in_W14(weight_ch1[13]), .in_W15(weight_ch1[14]),
        .in_W16(weight_ch1[15]), .in_W17(weight_ch1[16]), .in_W18(weight_ch1[17]), 
        .in_W19(weight_ch1[18]), .in_W20(weight_ch1[19]),
        .in_W21(weight_ch1[20]), .in_W22(weight_ch1[21]), .in_W23(weight_ch1[22]), 
        .in_W24(weight_ch1[23]), .in_W25(weight_ch1[24])
    );
    
    // PE Channel 2
    conv_pe_5x5 u_pe_ch2 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch2), .pe_out(pe_out_ch2),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch2[0]), .in_W2(weight_ch2[1]), .in_W3(weight_ch2[2]), 
        .in_W4(weight_ch2[3]), .in_W5(weight_ch2[4]),
        .in_W6(weight_ch2[5]), .in_W7(weight_ch2[6]), .in_W8(weight_ch2[7]), 
        .in_W9(weight_ch2[8]), .in_W10(weight_ch2[9]),
        .in_W11(weight_ch2[10]), .in_W12(weight_ch2[11]), .in_W13(weight_ch2[12]), 
        .in_W14(weight_ch2[13]), .in_W15(weight_ch2[14]),
        .in_W16(weight_ch2[15]), .in_W17(weight_ch2[16]), .in_W18(weight_ch2[17]), 
        .in_W19(weight_ch2[18]), .in_W20(weight_ch2[19]),
        .in_W21(weight_ch2[20]), .in_W22(weight_ch2[21]), .in_W23(weight_ch2[22]), 
        .in_W24(weight_ch2[23]), .in_W25(weight_ch2[24])
    );
    
    // PE Channel 3
    conv_pe_5x5 u_pe_ch3 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch3), .pe_out(pe_out_ch3),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch3[0]), .in_W2(weight_ch3[1]), .in_W3(weight_ch3[2]), 
        .in_W4(weight_ch3[3]), .in_W5(weight_ch3[4]),
        .in_W6(weight_ch3[5]), .in_W7(weight_ch3[6]), .in_W8(weight_ch3[7]), 
        .in_W9(weight_ch3[8]), .in_W10(weight_ch3[9]),
        .in_W11(weight_ch3[10]), .in_W12(weight_ch3[11]), .in_W13(weight_ch3[12]), 
        .in_W14(weight_ch3[13]), .in_W15(weight_ch3[14]),
        .in_W16(weight_ch3[15]), .in_W17(weight_ch3[16]), .in_W18(weight_ch3[17]), 
        .in_W19(weight_ch3[18]), .in_W20(weight_ch3[19]),
        .in_W21(weight_ch3[20]), .in_W22(weight_ch3[21]), .in_W23(weight_ch3[22]), 
        .in_W24(weight_ch3[23]), .in_W25(weight_ch3[24])
    );
    
    // PE Channel 4
    conv_pe_5x5 u_pe_ch4 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch4), .pe_out(pe_out_ch4),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch4[0]), .in_W2(weight_ch4[1]), .in_W3(weight_ch4[2]), 
        .in_W4(weight_ch4[3]), .in_W5(weight_ch4[4]),
        .in_W6(weight_ch4[5]), .in_W7(weight_ch4[6]), .in_W8(weight_ch4[7]), 
        .in_W9(weight_ch4[8]), .in_W10(weight_ch4[9]),
        .in_W11(weight_ch4[10]), .in_W12(weight_ch4[11]), .in_W13(weight_ch4[12]), 
        .in_W14(weight_ch4[13]), .in_W15(weight_ch4[14]),
        .in_W16(weight_ch4[15]), .in_W17(weight_ch4[16]), .in_W18(weight_ch4[17]), 
        .in_W19(weight_ch4[18]), .in_W20(weight_ch4[19]),
        .in_W21(weight_ch4[20]), .in_W22(weight_ch4[21]), .in_W23(weight_ch4[22]), 
        .in_W24(weight_ch4[23]), .in_W25(weight_ch4[24])
    );
    
    // PE Channel 5
    conv_pe_5x5 u_pe_ch5 (
        .clk(clk), .reset_n(reset_n),
        .valid_in(o_conv_valid & weights_loaded),
        .valid_out(valid_out_ch5), .pe_out(pe_out_ch5),
        .relu_en(relu_en), .quan_en(quan_en), .psum(32'd0),
        .in_IF1(window_0_0), .in_IF2(window_0_1), .in_IF3(window_0_2), 
        .in_IF4(window_0_3), .in_IF5(window_0_4),
        .in_IF6(window_1_0), .in_IF7(window_1_1), .in_IF8(window_1_2), 
        .in_IF9(window_1_3), .in_IF10(window_1_4),
        .in_IF11(window_2_0), .in_IF12(window_2_1), .in_IF13(window_2_2), 
        .in_IF14(window_2_3), .in_IF15(window_2_4),
        .in_IF16(window_3_0), .in_IF17(window_3_1), .in_IF18(window_3_2), 
        .in_IF19(window_3_3), .in_IF20(window_3_4),
        .in_IF21(window_4_0), .in_IF22(window_4_1), .in_IF23(window_4_2), 
        .in_IF24(window_4_3), .in_IF25(window_4_4),
        .in_W1(weight_ch5[0]), .in_W2(weight_ch5[1]), .in_W3(weight_ch5[2]), 
        .in_W4(weight_ch5[3]), .in_W5(weight_ch5[4]),
        .in_W6(weight_ch5[5]), .in_W7(weight_ch5[6]), .in_W8(weight_ch5[7]), 
        .in_W9(weight_ch5[8]), .in_W10(weight_ch5[9]),
        .in_W11(weight_ch5[10]), .in_W12(weight_ch5[11]), .in_W13(weight_ch5[12]), 
        .in_W14(weight_ch5[13]), .in_W15(weight_ch5[14]),
        .in_W16(weight_ch5[15]), .in_W17(weight_ch5[16]), .in_W18(weight_ch5[17]), 
        .in_W19(weight_ch5[18]), .in_W20(weight_ch5[19]),
        .in_W21(weight_ch5[20]), .in_W22(weight_ch5[21]), .in_W23(weight_ch5[22]), 
        .in_W24(weight_ch5[23]), .in_W25(weight_ch5[24])
    );
    
    // Weight loading state machine
    always @(posedge clk) begin
        if (!reset_n) begin
            state <= IDLE;
            weight_req <= 1'b0;
            kernel_idx <= 3'd0;
            weights_loaded <= 1'b0;
            line_controller_start <= 1'b0;
            wait_cnt <= 4'd0;
            
            // Initialize weights
            for (i = 0; i < 25; i = i + 1) begin
                weight_ch0[i] <= 8'sd0;
                weight_ch1[i] <= 8'sd0;
                weight_ch2[i] <= 8'sd0;
                weight_ch3[i] <= 8'sd0;
                weight_ch4[i] <= 8'sd0;
                weight_ch5[i] <= 8'sd0;
            end
        end else begin
            case (state)
                IDLE: begin
                    weight_req <= 1'b0;
                    line_controller_start <= 1'b0;
                    if (i_start) begin
                        state <= SET_IDX;
                        kernel_idx <= 3'd0;
                        weights_loaded <= 1'b0;
                        wait_cnt <= 4'd0;
                    end
                end
                
                SET_IDX: begin
                    weight_req <= 1'b0;
                    wait_cnt <= wait_cnt + 1'b1;
                    if (wait_cnt >= 4'd2) begin
                        state <= PULSE_REQ;
                        wait_cnt <= 4'd0;
                    end
                end
                
                PULSE_REQ: begin
                    weight_req <= 1'b1;
                    state <= WAIT_WEIGHT;
                    wait_cnt <= 4'd0;
                end
                
                WAIT_WEIGHT: begin
                    weight_req <= 1'b1;
                    wait_cnt <= wait_cnt + 1'b1;
                    
                    if (weight_valid) begin
                        // Store weights for current channel
                        case (kernel_idx)
                            3'd0: begin
                                weight_ch0[0] <= weight_0; weight_ch0[1] <= weight_1; weight_ch0[2] <= weight_2; 
                                weight_ch0[3] <= weight_3; weight_ch0[4] <= weight_4; weight_ch0[5] <= weight_5;
                                weight_ch0[6] <= weight_6; weight_ch0[7] <= weight_7; weight_ch0[8] <= weight_8;
                                weight_ch0[9] <= weight_9; weight_ch0[10] <= weight_10; weight_ch0[11] <= weight_11;
                                weight_ch0[12] <= weight_12; weight_ch0[13] <= weight_13; weight_ch0[14] <= weight_14;
                                weight_ch0[15] <= weight_15; weight_ch0[16] <= weight_16; weight_ch0[17] <= weight_17;
                                weight_ch0[18] <= weight_18; weight_ch0[19] <= weight_19; weight_ch0[20] <= weight_20;
                                weight_ch0[21] <= weight_21; weight_ch0[22] <= weight_22; weight_ch0[23] <= weight_23;
                                weight_ch0[24] <= weight_24;
                            end
                            3'd1: begin
                                weight_ch1[0] <= weight_0; weight_ch1[1] <= weight_1; weight_ch1[2] <= weight_2;
                                weight_ch1[3] <= weight_3; weight_ch1[4] <= weight_4; weight_ch1[5] <= weight_5;
                                weight_ch1[6] <= weight_6; weight_ch1[7] <= weight_7; weight_ch1[8] <= weight_8;
                                weight_ch1[9] <= weight_9; weight_ch1[10] <= weight_10; weight_ch1[11] <= weight_11;
                                weight_ch1[12] <= weight_12; weight_ch1[13] <= weight_13; weight_ch1[14] <= weight_14;
                                weight_ch1[15] <= weight_15; weight_ch1[16] <= weight_16; weight_ch1[17] <= weight_17;
                                weight_ch1[18] <= weight_18; weight_ch1[19] <= weight_19; weight_ch1[20] <= weight_20;
                                weight_ch1[21] <= weight_21; weight_ch1[22] <= weight_22; weight_ch1[23] <= weight_23;
                                weight_ch1[24] <= weight_24;
                            end
                            3'd2: begin
                                weight_ch2[0] <= weight_0; weight_ch2[1] <= weight_1; weight_ch2[2] <= weight_2;
                                weight_ch2[3] <= weight_3; weight_ch2[4] <= weight_4; weight_ch2[5] <= weight_5;
                                weight_ch2[6] <= weight_6; weight_ch2[7] <= weight_7; weight_ch2[8] <= weight_8;
                                weight_ch2[9] <= weight_9; weight_ch2[10] <= weight_10; weight_ch2[11] <= weight_11;
                                weight_ch2[12] <= weight_12; weight_ch2[13] <= weight_13; weight_ch2[14] <= weight_14;
                                weight_ch2[15] <= weight_15; weight_ch2[16] <= weight_16; weight_ch2[17] <= weight_17;
                                weight_ch2[18] <= weight_18; weight_ch2[19] <= weight_19; weight_ch2[20] <= weight_20;
                                weight_ch2[21] <= weight_21; weight_ch2[22] <= weight_22; weight_ch2[23] <= weight_23;
                                weight_ch2[24] <= weight_24;
                            end
                            3'd3: begin
                                weight_ch3[0] <= weight_0; weight_ch3[1] <= weight_1; weight_ch3[2] <= weight_2;
                                weight_ch3[3] <= weight_3; weight_ch3[4] <= weight_4; weight_ch3[5] <= weight_5;
                                weight_ch3[6] <= weight_6; weight_ch3[7] <= weight_7; weight_ch3[8] <= weight_8;
                                weight_ch3[9] <= weight_9; weight_ch3[10] <= weight_10; weight_ch3[11] <= weight_11;
                                weight_ch3[12] <= weight_12; weight_ch3[13] <= weight_13; weight_ch3[14] <= weight_14;
                                weight_ch3[15] <= weight_15; weight_ch3[16] <= weight_16; weight_ch3[17] <= weight_17;
                                weight_ch3[18] <= weight_18; weight_ch3[19] <= weight_19; weight_ch3[20] <= weight_20;
                                weight_ch3[21] <= weight_21; weight_ch3[22] <= weight_22; weight_ch3[23] <= weight_23;
                                weight_ch3[24] <= weight_24;
                            end
                            3'd4: begin
                                weight_ch4[0] <= weight_0; weight_ch4[1] <= weight_1; weight_ch4[2] <= weight_2;
                                weight_ch4[3] <= weight_3; weight_ch4[4] <= weight_4; weight_ch4[5] <= weight_5;
                                weight_ch4[6] <= weight_6; weight_ch4[7] <= weight_7; weight_ch4[8] <= weight_8;
                                weight_ch4[9] <= weight_9; weight_ch4[10] <= weight_10; weight_ch4[11] <= weight_11;
                                weight_ch4[12] <= weight_12; weight_ch4[13] <= weight_13; weight_ch4[14] <= weight_14;
                                weight_ch4[15] <= weight_15; weight_ch4[16] <= weight_16; weight_ch4[17] <= weight_17;
                                weight_ch4[18] <= weight_18; weight_ch4[19] <= weight_19; weight_ch4[20] <= weight_20;
                                weight_ch4[21] <= weight_21; weight_ch4[22] <= weight_22; weight_ch4[23] <= weight_23;
                                weight_ch4[24] <= weight_24;
                            end
                            3'd5: begin
                                weight_ch5[0] <= weight_0; weight_ch5[1] <= weight_1; weight_ch5[2] <= weight_2;
                                weight_ch5[3] <= weight_3; weight_ch5[4] <= weight_4; weight_ch5[5] <= weight_5;
                                weight_ch5[6] <= weight_6; weight_ch5[7] <= weight_7; weight_ch5[8] <= weight_8;
                                weight_ch5[9] <= weight_9; weight_ch5[10] <= weight_10; weight_ch5[11] <= weight_11;
                                weight_ch5[12] <= weight_12; weight_ch5[13] <= weight_13; weight_ch5[14] <= weight_14;
                                weight_ch5[15] <= weight_15; weight_ch5[16] <= weight_16; weight_ch5[17] <= weight_17;
                                weight_ch5[18] <= weight_18; weight_ch5[19] <= weight_19; weight_ch5[20] <= weight_20;
                                weight_ch5[21] <= weight_21; weight_ch5[22] <= weight_22; weight_ch5[23] <= weight_23;
                                weight_ch5[24] <= weight_24;
                            end
                        endcase
                        
                        state <= NEXT_KERNEL;
                        wait_cnt <= 4'd0;
                    end else if (wait_cnt >= 4'd15) begin
                        $display("ERROR: Weight loading timeout for kernel %d", kernel_idx);
                        state <= NEXT_KERNEL;
                        wait_cnt <= 4'd0;
                    end
                end
                
                NEXT_KERNEL: begin
                    weight_req <= 1'b0;
                    if (kernel_idx == 3'd5) begin
                        state <= READY;
                        weights_loaded <= 1'b1;
                        line_controller_start <= 1'b1;
                        $display("All weights loaded, starting line controller at time %0t", $time);
                    end else begin
                        kernel_idx <= kernel_idx + 1'b1;
                        state <= SET_IDX;
                        wait_cnt <= 4'd0;
                    end
                end
                
                READY: begin
                    line_controller_start <= 1'b0;  // One clock high
                    if (line_controller_done) begin
                        state <= IDLE;
                        weights_loaded <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
    // CRITICAL FIX: Simplified output capture logic
    always @(posedge clk) begin
        if (!reset_n) begin
            out_ch0 <= 8'd0;
            out_ch1 <= 8'd0;
            out_ch2 <= 8'd0;
            out_ch3 <= 8'd0;
            out_ch4 <= 8'd0;
            out_ch5 <= 8'd0;
            out_valid <= 1'b0;
        end else begin
            // Simple condition: if any PE has valid output and weights are loaded
            if (weights_loaded && (valid_out_ch0 || valid_out_ch1 || valid_out_ch2 || 
                                   valid_out_ch3 || valid_out_ch4 || valid_out_ch5)) begin
                
                // Capture outputs directly from PEs
                out_ch0 <= pe_out_ch0;
                out_ch1 <= pe_out_ch1;
                out_ch2 <= pe_out_ch2;
                out_ch3 <= pe_out_ch3;
                out_ch4 <= pe_out_ch4;
                out_ch5 <= pe_out_ch5;
                
                out_valid <= 1'b1;
                
                // Debug: Show only non-zero outputs to reduce clutter
                if (|pe_out_ch0 || |pe_out_ch1 || |pe_out_ch2 || 
                    |pe_out_ch3 || |pe_out_ch4 || |pe_out_ch5) begin
                    $display("VALID OUTPUT: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t", 
                            pe_out_ch0, pe_out_ch1, pe_out_ch2, pe_out_ch3, pe_out_ch4, pe_out_ch5, $time);
                end
            end else begin
                out_valid <= 1'b0;
            end
        end
    end
    
    // Done signal
    assign o_done = line_controller_done;
    
endmodule