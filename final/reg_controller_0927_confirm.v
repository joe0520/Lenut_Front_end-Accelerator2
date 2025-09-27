`timescale 1ns / 1ps

module c1_reg_controller (
    input               clk,
    input               reset_n,
    
    // From convolution PEs - 6 channels
    input  [7:0]        conv_ch0,
    input  [7:0]        conv_ch1,
    input  [7:0]        conv_ch2,
    input  [7:0]        conv_ch3,
    input  [7:0]        conv_ch4,
    input  [7:0]        conv_ch5,
    input               conv_valid,
    
    // To maxpooling - 2x2 blocks for 6 channels (32bit = 4 x 8bit)
    output reg          pool_valid,
    output reg [31:0]   pool_ch0,  // {top_left, top_right, bottom_left, bottom_right}
    output reg [31:0]   pool_ch1,
    output reg [31:0]   pool_ch2,
    output reg [31:0]   pool_ch3,
    output reg [31:0]   pool_ch4,
    output reg [31:0]   pool_ch5
);

    // State parameters
    localparam PING_READ = 2'b00;
    localparam PING_WRITE_PONG_READ = 2'b01;
    localparam PONG_READ = 2'b10;
    localparam PONG_WRITE_PING_READ = 2'b11;

    // Control signals
    reg push_flag;      // 0: write to ping, 1: write to pong
    reg [4:0] w_cnt;    // width counter (0-27)
    reg [2:0] c_cnt;    // channel counter (0-5)
    reg h_cnt;          // height counter within 2-row block (0-1)
    
    // State machine
    reg [1:0] c_state;
    reg [1:0] n_state;
    
    // Read counter for outputting 2x2 blocks
    reg [4:0] read_cnt; // 0-26 (step by 2)
    
    // Ping-pong buffers: [channel][row][col]
    // Each buffer stores 2 rows of 28 pixels for 6 channels
    reg [7:0] ping_reg_0 [0:5][0:27];  // Row 0 of each channel
    reg [7:0] ping_reg_1 [0:5][0:27];  // Row 1 of each channel
    
    reg [7:0] pong_reg_0 [0:5][0:27];  // Row 0 of each channel
    reg [7:0] pong_reg_1 [0:5][0:27];  // Row 1 of each channel
    
    integer i, j;
    
    // Write logic to ping/pong buffers
    always @(posedge clk) begin
        if (!reset_n) begin
            for (i = 0; i < 6; i = i + 1) begin
                for (j = 0; j < 28; j = j + 1) begin
                    ping_reg_0[i][j] <= 8'd0;
                    ping_reg_1[i][j] <= 8'd0;
                    pong_reg_0[i][j] <= 8'd0;
                    pong_reg_1[i][j] <= 8'd0;
                end
            end
        end else if (~push_flag & conv_valid) begin
            // Write to ping buffer
            if (~h_cnt) begin
                // Write to row 0 - only write the active channel
                case (c_cnt)
                    0: ping_reg_0[0][w_cnt] <= conv_ch0;
                    1: ping_reg_0[1][w_cnt] <= conv_ch1;
                    2: ping_reg_0[2][w_cnt] <= conv_ch2;
                    3: ping_reg_0[3][w_cnt] <= conv_ch3;
                    4: ping_reg_0[4][w_cnt] <= conv_ch4;
                    5: ping_reg_0[5][w_cnt] <= conv_ch5;
                endcase
            end else begin
                // Write to row 1 - only write the active channel
                case (c_cnt)
                    0: ping_reg_1[0][w_cnt] <= conv_ch0;
                    1: ping_reg_1[1][w_cnt] <= conv_ch1;
                    2: ping_reg_1[2][w_cnt] <= conv_ch2;
                    3: ping_reg_1[3][w_cnt] <= conv_ch3;
                    4: ping_reg_1[4][w_cnt] <= conv_ch4;
                    5: ping_reg_1[5][w_cnt] <= conv_ch5;
                endcase
            end
        end else if (push_flag & conv_valid) begin
            // Write to pong buffer
            if (~h_cnt) begin
                // Write to row 0 - only write the active channel
                case (c_cnt)
                    0: pong_reg_0[0][w_cnt] <= conv_ch0;
                    1: pong_reg_0[1][w_cnt] <= conv_ch1;
                    2: pong_reg_0[2][w_cnt] <= conv_ch2;
                    3: pong_reg_0[3][w_cnt] <= conv_ch3;
                    4: pong_reg_0[4][w_cnt] <= conv_ch4;
                    5: pong_reg_0[5][w_cnt] <= conv_ch5;
                endcase
            end else begin
                // Write to row 1 - only write the active channel
                case (c_cnt)
                    0: pong_reg_1[0][w_cnt] <= conv_ch0;
                    1: pong_reg_1[1][w_cnt] <= conv_ch1;
                    2: pong_reg_1[2][w_cnt] <= conv_ch2;
                    3: pong_reg_1[3][w_cnt] <= conv_ch3;
                    4: pong_reg_1[4][w_cnt] <= conv_ch4;
                    5: pong_reg_1[5][w_cnt] <= conv_ch5;
                endcase
            end
        end
    end
    
    // Counter control logic
    always @(posedge clk) begin
        if (!reset_n) begin
            w_cnt <= 5'd0;
            c_cnt <= 3'd0;
            h_cnt <= 1'b0;
            push_flag <= 1'b0;
        end else if (conv_valid) begin
            // Switch push_flag when completing a 2-row block
            if (h_cnt & (w_cnt == 27) & (c_cnt == 5)) begin
                push_flag <= ~push_flag;
            end
            
            // Toggle height counter when completing a row
            if ((w_cnt == 27) & (c_cnt == 5)) begin
                h_cnt <= ~h_cnt;
            end
            
            // Reset width counter when completing a row
            if ((w_cnt == 27) & (c_cnt == 5)) begin
                w_cnt <= 5'd0;
            end else if (c_cnt == 5) begin
                w_cnt <= w_cnt + 1'b1;
            end
            
            // Channel counter
            if (c_cnt == 5) begin
                c_cnt <= 3'd0;
            end else begin
                c_cnt <= c_cnt + 1'b1;
            end
        end
    end
    
    // State machine control
    always @(posedge clk) begin
        if (!reset_n) begin
            c_state <= PING_READ;
            read_cnt <= 5'd0;
        end else begin
            c_state <= n_state;
            if (read_cnt == 26) begin
                read_cnt <= 5'd0;
            end else if ((c_state == PING_WRITE_PONG_READ) | (c_state == PONG_WRITE_PING_READ)) begin
                read_cnt <= read_cnt + 2'd2;  // Step by 2 for 2x2 pooling
            end
        end
    end
    
    // Next state logic
    always @(*) begin
        n_state = c_state;
        case (c_state)
            PING_READ: begin
                if (conv_valid & h_cnt & (w_cnt == 27) & (c_cnt == 5)) 
                    n_state = PING_WRITE_PONG_READ;
            end
            PING_WRITE_PONG_READ: begin
                if (read_cnt == 26) 
                    n_state = PONG_READ;
            end
            PONG_READ: begin
                if (conv_valid & h_cnt & (w_cnt == 27) & (c_cnt == 5)) 
                    n_state = PONG_WRITE_PING_READ;
            end
            PONG_WRITE_PING_READ: begin
                if (read_cnt == 26) 
                    n_state = PING_READ;
            end
        endcase
    end
    
    // Output logic - generate 2x2 blocks
    always @(posedge clk) begin
        if (!reset_n) begin
            pool_valid <= 1'b0;
            pool_ch0 <= 32'd0;
            pool_ch1 <= 32'd0;
            pool_ch2 <= 32'd0;
            pool_ch3 <= 32'd0;
            pool_ch4 <= 32'd0;
            pool_ch5 <= 32'd0;
        end else if (c_state == PING_WRITE_PONG_READ) begin
            // Read from ping buffer while writing to pong
            pool_valid <= 1'b1;
            pool_ch0 <= {ping_reg_0[0][read_cnt], ping_reg_0[0][read_cnt+1], 
                        ping_reg_1[0][read_cnt], ping_reg_1[0][read_cnt+1]};
            pool_ch1 <= {ping_reg_0[1][read_cnt], ping_reg_0[1][read_cnt+1], 
                        ping_reg_1[1][read_cnt], ping_reg_1[1][read_cnt+1]};
            pool_ch2 <= {ping_reg_0[2][read_cnt], ping_reg_0[2][read_cnt+1], 
                        ping_reg_1[2][read_cnt], ping_reg_1[2][read_cnt+1]};
            pool_ch3 <= {ping_reg_0[3][read_cnt], ping_reg_0[3][read_cnt+1], 
                        ping_reg_1[3][read_cnt], ping_reg_1[3][read_cnt+1]};
            pool_ch4 <= {ping_reg_0[4][read_cnt], ping_reg_0[4][read_cnt+1], 
                        ping_reg_1[4][read_cnt], ping_reg_1[4][read_cnt+1]};
            pool_ch5 <= {ping_reg_0[5][read_cnt], ping_reg_0[5][read_cnt+1], 
                        ping_reg_1[5][read_cnt], ping_reg_1[5][read_cnt+1]};
        end else if (c_state == PONG_WRITE_PING_READ) begin
            // Read from pong buffer while writing to ping
            pool_valid <= 1'b1;
            pool_ch0 <= {pong_reg_0[0][read_cnt], pong_reg_0[0][read_cnt+1], 
                        pong_reg_1[0][read_cnt], pong_reg_1[0][read_cnt+1]};
            pool_ch1 <= {pong_reg_0[1][read_cnt], pong_reg_0[1][read_cnt+1], 
                        pong_reg_1[1][read_cnt], pong_reg_1[1][read_cnt+1]};
            pool_ch2 <= {pong_reg_0[2][read_cnt], pong_reg_0[2][read_cnt+1], 
                        pong_reg_1[2][read_cnt], pong_reg_1[2][read_cnt+1]};
            pool_ch3 <= {pong_reg_0[3][read_cnt], pong_reg_0[3][read_cnt+1], 
                        pong_reg_1[3][read_cnt], pong_reg_1[3][read_cnt+1]};
            pool_ch4 <= {pong_reg_0[4][read_cnt], pong_reg_0[4][read_cnt+1], 
                        pong_reg_1[4][read_cnt], pong_reg_1[4][read_cnt+1]};
            pool_ch5 <= {pong_reg_0[5][read_cnt], pong_reg_0[5][read_cnt+1], 
                        pong_reg_1[5][read_cnt], pong_reg_1[5][read_cnt+1]};
        end else begin
            pool_valid <= 1'b0;
        end
    end

endmodule