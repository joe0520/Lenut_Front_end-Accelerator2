`timescale 1ns / 1ps

module c1_maxpooling_unit (
    input               clk,
    input               reset_n,
    
    // Input from c1_reg_controller - 32bit packed 2x2 blocks for 6 channels
    input               pool_valid,
    input  [31:0]       pool_ch0,  // {top_left[31:24], top_right[23:16], bottom_left[15:8], bottom_right[7:0]}
    input  [31:0]       pool_ch1,
    input  [31:0]       pool_ch2,
    input  [31:0]       pool_ch3,
    input  [31:0]       pool_ch4,
    input  [31:0]       pool_ch5,
    
    // Output - maxpooled values for 6 channels
    output reg          mp_out_valid,
    output reg [7:0]    mp_out_ch0,
    output reg [7:0]    mp_out_ch1,
    output reg [7:0]    mp_out_ch2,
    output reg [7:0]    mp_out_ch3,
    output reg [7:0]    mp_out_ch4,
    output reg [7:0]    mp_out_ch5
);

    // Pipeline stage 0: valid signal delay
    reg pool_valid_0;
    
    // Pipeline stage 0: intermediate max buffers for 2-stage maxpooling
    reg [7:0] mp_buf [0:5][0:1];  // [channel][0: max of top pair, 1: max of bottom pair]
    
    integer i, j;
    
    // Pipeline stage 0: Calculate max of top pair and bottom pair for each channel
    always @(posedge clk) begin
        if (!reset_n) begin
            for (i = 0; i < 6; i = i + 1) begin
                for (j = 0; j < 2; j = j + 1) begin
                    mp_buf[i][j] <= 8'd0;
                end
            end
        end else if (pool_valid) begin
            // Channel 0: Compare top_left vs top_right, bottom_left vs bottom_right
            if (pool_ch0[31:24] > pool_ch0[23:16]) mp_buf[0][0] <= pool_ch0[31:24];
            else mp_buf[0][0] <= pool_ch0[23:16];
            if (pool_ch0[15:8] > pool_ch0[7:0]) mp_buf[0][1] <= pool_ch0[15:8];
            else mp_buf[0][1] <= pool_ch0[7:0];
            
            // Channel 1
            if (pool_ch1[31:24] > pool_ch1[23:16]) mp_buf[1][0] <= pool_ch1[31:24];
            else mp_buf[1][0] <= pool_ch1[23:16];
            if (pool_ch1[15:8] > pool_ch1[7:0]) mp_buf[1][1] <= pool_ch1[15:8];
            else mp_buf[1][1] <= pool_ch1[7:0];
            
            // Channel 2
            if (pool_ch2[31:24] > pool_ch2[23:16]) mp_buf[2][0] <= pool_ch2[31:24];
            else mp_buf[2][0] <= pool_ch2[23:16];
            if (pool_ch2[15:8] > pool_ch2[7:0]) mp_buf[2][1] <= pool_ch2[15:8];
            else mp_buf[2][1] <= pool_ch2[7:0];
            
            // Channel 3
            if (pool_ch3[31:24] > pool_ch3[23:16]) mp_buf[3][0] <= pool_ch3[31:24];
            else mp_buf[3][0] <= pool_ch3[23:16];
            if (pool_ch3[15:8] > pool_ch3[7:0]) mp_buf[3][1] <= pool_ch3[15:8];
            else mp_buf[3][1] <= pool_ch3[7:0];
            
            // Channel 4
            if (pool_ch4[31:24] > pool_ch4[23:16]) mp_buf[4][0] <= pool_ch4[31:24];
            else mp_buf[4][0] <= pool_ch4[23:16];
            if (pool_ch4[15:8] > pool_ch4[7:0]) mp_buf[4][1] <= pool_ch4[15:8];
            else mp_buf[4][1] <= pool_ch4[7:0];
            
            // Channel 5
            if (pool_ch5[31:24] > pool_ch5[23:16]) mp_buf[5][0] <= pool_ch5[31:24];
            else mp_buf[5][0] <= pool_ch5[23:16];
            if (pool_ch5[15:8] > pool_ch5[7:0]) mp_buf[5][1] <= pool_ch5[15:8];
            else mp_buf[5][1] <= pool_ch5[7:0];
        end
    end
    
    // Pipeline stage 1: Final max comparison and output
    always @(posedge clk) begin
        if (!reset_n) begin
            mp_out_ch0 <= 8'd0;
            mp_out_ch1 <= 8'd0;
            mp_out_ch2 <= 8'd0;
            mp_out_ch3 <= 8'd0;
            mp_out_ch4 <= 8'd0;
            mp_out_ch5 <= 8'd0;
        end else if (pool_valid_0) begin
            // Channel 0: max of the two intermediate maxes
            if (mp_buf[0][0] > mp_buf[0][1]) mp_out_ch0 <= mp_buf[0][0];
            else mp_out_ch0 <= mp_buf[0][1];
            
            // Channel 1
            if (mp_buf[1][0] > mp_buf[1][1]) mp_out_ch1 <= mp_buf[1][0];
            else mp_out_ch1 <= mp_buf[1][1];
            
            // Channel 2
            if (mp_buf[2][0] > mp_buf[2][1]) mp_out_ch2 <= mp_buf[2][0];
            else mp_out_ch2 <= mp_buf[2][1];
            
            // Channel 3
            if (mp_buf[3][0] > mp_buf[3][1]) mp_out_ch3 <= mp_buf[3][0];
            else mp_out_ch3 <= mp_buf[3][1];
            
            // Channel 4
            if (mp_buf[4][0] > mp_buf[4][1]) mp_out_ch4 <= mp_buf[4][0];
            else mp_out_ch4 <= mp_buf[4][1];
            
            // Channel 5
            if (mp_buf[5][0] > mp_buf[5][1]) mp_out_ch5 <= mp_buf[5][0];
            else mp_out_ch5 <= mp_buf[5][1];
        end
    end
    
    // Pipeline valid signal control (2-stage pipeline)
    always @(posedge clk) begin
        if (!reset_n) begin
            pool_valid_0 <= 1'b0;
            mp_out_valid <= 1'b0;
        end else begin
            pool_valid_0 <= pool_valid;
            mp_out_valid <= pool_valid_0;
        end
    end

endmodule