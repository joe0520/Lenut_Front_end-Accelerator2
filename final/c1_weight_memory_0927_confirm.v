`timescale 1ns / 1ps

// C1 Weight Memory - Channel-based Version (FIXED)
// 주요 개선사항: Invalid channel 처리, 메모리 초기화 검증, 더 안정적인 FSM

module c1_weight_memory(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        weight_req,          // request signal
    input  wire [2:0]  kernel_idx,          // kernel index (0~5 for 6 output channels)

    // 5x5 kernel weights outputs - SIGNED
    output reg signed [7:0]  weight_0,
    output reg signed [7:0]  weight_1,
    output reg signed [7:0]  weight_2,
    output reg signed [7:0]  weight_3,
    output reg signed [7:0]  weight_4,
    output reg signed [7:0]  weight_5,
    output reg signed [7:0]  weight_6,
    output reg signed [7:0]  weight_7,
    output reg signed [7:0]  weight_8,
    output reg signed [7:0]  weight_9,
    output reg signed [7:0]  weight_10,
    output reg signed [7:0]  weight_11,
    output reg signed [7:0]  weight_12,
    output reg signed [7:0]  weight_13,
    output reg signed [7:0]  weight_14,
    output reg signed [7:0]  weight_15,
    output reg signed [7:0]  weight_16,
    output reg signed [7:0]  weight_17,
    output reg signed [7:0]  weight_18,
    output reg signed [7:0]  weight_19,
    output reg signed [7:0]  weight_20,
    output reg signed [7:0]  weight_21,
    output reg signed [7:0]  weight_22,
    output reg signed [7:0]  weight_23,
    output reg signed [7:0]  weight_24,

    output reg         weight_valid
);

    // Memory arrays for each channel - store as 8-bit unsigned, convert to signed on output
    reg [7:0] weight_mem_ch0 [0:24]; // Channel 0: 25 weights
    reg [7:0] weight_mem_ch1 [0:24]; // Channel 1: 25 weights
    reg [7:0] weight_mem_ch2 [0:24]; // Channel 2: 25 weights
    reg [7:0] weight_mem_ch3 [0:24]; // Channel 3: 25 weights
    reg [7:0] weight_mem_ch4 [0:24]; // Channel 4: 25 weights
    reg [7:0] weight_mem_ch5 [0:24]; // Channel 5: 25 weights
    
    // Memory initialization status
    reg mem_init_done;
    
    // Integer for initialization loop
    integer i;
    
    // Initialize memory from separate channel hex files
    initial begin
        mem_init_done = 1'b0;
        
        // Initialize all memories to zero first
        for (i = 0; i < 25; i = i + 1) begin
            weight_mem_ch0[i] = 8'h00;
            weight_mem_ch1[i] = 8'h00;
            weight_mem_ch2[i] = 8'h00;
            weight_mem_ch3[i] = 8'h00;
            weight_mem_ch4[i] = 8'h00;
            weight_mem_ch5[i] = 8'h00;
        end
        
        // Load from hex files
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch0.hex", weight_mem_ch0);
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch1.hex", weight_mem_ch1);
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch2.hex", weight_mem_ch2);
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch3.hex", weight_mem_ch3);
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch4.hex", weight_mem_ch4);
        $readmemh("C:/VI_LFEA/LEFA/weights/c1_weights_ch5.hex", weight_mem_ch5);
        
        mem_init_done = 1'b1;
        
        // Debug: Display weights to verify loading
        $display("C1 Weight Memory V2 Fixed Initialization Completed:");
        $display("Channel 0: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch0[0], weight_mem_ch0[1], weight_mem_ch0[12], weight_mem_ch0[24]);
        $display("Channel 1: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch1[0], weight_mem_ch1[1], weight_mem_ch1[12], weight_mem_ch1[24]);
        $display("Channel 2: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch2[0], weight_mem_ch2[1], weight_mem_ch2[12], weight_mem_ch2[24]);
        $display("Channel 3: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch3[0], weight_mem_ch3[1], weight_mem_ch3[12], weight_mem_ch3[24]);
        $display("Channel 4: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch4[0], weight_mem_ch4[1], weight_mem_ch4[12], weight_mem_ch4[24]);
        $display("Channel 5: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem_ch5[0], weight_mem_ch5[1], weight_mem_ch5[12], weight_mem_ch5[24]);
    end
    
    // FSM states
    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam LOADING = 2'b01;
    localparam READY = 2'b10;
    
    // Current request tracking
    reg [2:0] stored_kernel_idx;
    
    // Helper function to convert unsigned to signed (two's complement interpretation)
    function signed [7:0] to_signed;
        input [7:0] unsigned_val;
        begin
            to_signed = $signed(unsigned_val);
        end
    endfunction
    
    // Task to clear all weights to zero
    task clear_all_weights;
    begin
        weight_0 <= 8'sd0;  weight_1 <= 8'sd0;  weight_2 <= 8'sd0;  weight_3 <= 8'sd0;  weight_4 <= 8'sd0;
        weight_5 <= 8'sd0;  weight_6 <= 8'sd0;  weight_7 <= 8'sd0;  weight_8 <= 8'sd0;  weight_9 <= 8'sd0;
        weight_10 <= 8'sd0; weight_11 <= 8'sd0; weight_12 <= 8'sd0; weight_13 <= 8'sd0; weight_14 <= 8'sd0;
        weight_15 <= 8'sd0; weight_16 <= 8'sd0; weight_17 <= 8'sd0; weight_18 <= 8'sd0; weight_19 <= 8'sd0;
        weight_20 <= 8'sd0; weight_21 <= 8'sd0; weight_22 <= 8'sd0; weight_23 <= 8'sd0; weight_24 <= 8'sd0;
    end
    endtask
    
    // Task to load weights from selected channel
    task load_channel_weights;
        input [2:0] ch_idx;
    begin
        if (ch_idx <= 3'd5) begin  // Valid channels only (0-5)
            case (ch_idx)
                3'd0: begin
                    weight_0 <= to_signed(weight_mem_ch0[0]);   weight_1 <= to_signed(weight_mem_ch0[1]);
                    weight_2 <= to_signed(weight_mem_ch0[2]);   weight_3 <= to_signed(weight_mem_ch0[3]);
                    weight_4 <= to_signed(weight_mem_ch0[4]);   weight_5 <= to_signed(weight_mem_ch0[5]);
                    weight_6 <= to_signed(weight_mem_ch0[6]);   weight_7 <= to_signed(weight_mem_ch0[7]);
                    weight_8 <= to_signed(weight_mem_ch0[8]);   weight_9 <= to_signed(weight_mem_ch0[9]);
                    weight_10 <= to_signed(weight_mem_ch0[10]); weight_11 <= to_signed(weight_mem_ch0[11]);
                    weight_12 <= to_signed(weight_mem_ch0[12]); weight_13 <= to_signed(weight_mem_ch0[13]);
                    weight_14 <= to_signed(weight_mem_ch0[14]); weight_15 <= to_signed(weight_mem_ch0[15]);
                    weight_16 <= to_signed(weight_mem_ch0[16]); weight_17 <= to_signed(weight_mem_ch0[17]);
                    weight_18 <= to_signed(weight_mem_ch0[18]); weight_19 <= to_signed(weight_mem_ch0[19]);
                    weight_20 <= to_signed(weight_mem_ch0[20]); weight_21 <= to_signed(weight_mem_ch0[21]);
                    weight_22 <= to_signed(weight_mem_ch0[22]); weight_23 <= to_signed(weight_mem_ch0[23]);
                    weight_24 <= to_signed(weight_mem_ch0[24]);
                end
                3'd1: begin
                    weight_0 <= to_signed(weight_mem_ch1[0]);   weight_1 <= to_signed(weight_mem_ch1[1]);
                    weight_2 <= to_signed(weight_mem_ch1[2]);   weight_3 <= to_signed(weight_mem_ch1[3]);
                    weight_4 <= to_signed(weight_mem_ch1[4]);   weight_5 <= to_signed(weight_mem_ch1[5]);
                    weight_6 <= to_signed(weight_mem_ch1[6]);   weight_7 <= to_signed(weight_mem_ch1[7]);
                    weight_8 <= to_signed(weight_mem_ch1[8]);   weight_9 <= to_signed(weight_mem_ch1[9]);
                    weight_10 <= to_signed(weight_mem_ch1[10]); weight_11 <= to_signed(weight_mem_ch1[11]);
                    weight_12 <= to_signed(weight_mem_ch1[12]); weight_13 <= to_signed(weight_mem_ch1[13]);
                    weight_14 <= to_signed(weight_mem_ch1[14]); weight_15 <= to_signed(weight_mem_ch1[15]);
                    weight_16 <= to_signed(weight_mem_ch1[16]); weight_17 <= to_signed(weight_mem_ch1[17]);
                    weight_18 <= to_signed(weight_mem_ch1[18]); weight_19 <= to_signed(weight_mem_ch1[19]);
                    weight_20 <= to_signed(weight_mem_ch1[20]); weight_21 <= to_signed(weight_mem_ch1[21]);
                    weight_22 <= to_signed(weight_mem_ch1[22]); weight_23 <= to_signed(weight_mem_ch1[23]);
                    weight_24 <= to_signed(weight_mem_ch1[24]);
                end
                3'd2: begin
                    weight_0 <= to_signed(weight_mem_ch2[0]);   weight_1 <= to_signed(weight_mem_ch2[1]);
                    weight_2 <= to_signed(weight_mem_ch2[2]);   weight_3 <= to_signed(weight_mem_ch2[3]);
                    weight_4 <= to_signed(weight_mem_ch2[4]);   weight_5 <= to_signed(weight_mem_ch2[5]);
                    weight_6 <= to_signed(weight_mem_ch2[6]);   weight_7 <= to_signed(weight_mem_ch2[7]);
                    weight_8 <= to_signed(weight_mem_ch2[8]);   weight_9 <= to_signed(weight_mem_ch2[9]);
                    weight_10 <= to_signed(weight_mem_ch2[10]); weight_11 <= to_signed(weight_mem_ch2[11]);
                    weight_12 <= to_signed(weight_mem_ch2[12]); weight_13 <= to_signed(weight_mem_ch2[13]);
                    weight_14 <= to_signed(weight_mem_ch2[14]); weight_15 <= to_signed(weight_mem_ch2[15]);
                    weight_16 <= to_signed(weight_mem_ch2[16]); weight_17 <= to_signed(weight_mem_ch2[17]);
                    weight_18 <= to_signed(weight_mem_ch2[18]); weight_19 <= to_signed(weight_mem_ch2[19]);
                    weight_20 <= to_signed(weight_mem_ch2[20]); weight_21 <= to_signed(weight_mem_ch2[21]);
                    weight_22 <= to_signed(weight_mem_ch2[22]); weight_23 <= to_signed(weight_mem_ch2[23]);
                    weight_24 <= to_signed(weight_mem_ch2[24]);
                end
                3'd3: begin
                    weight_0 <= to_signed(weight_mem_ch3[0]);   weight_1 <= to_signed(weight_mem_ch3[1]);
                    weight_2 <= to_signed(weight_mem_ch3[2]);   weight_3 <= to_signed(weight_mem_ch3[3]);
                    weight_4 <= to_signed(weight_mem_ch3[4]);   weight_5 <= to_signed(weight_mem_ch3[5]);
                    weight_6 <= to_signed(weight_mem_ch3[6]);   weight_7 <= to_signed(weight_mem_ch3[7]);
                    weight_8 <= to_signed(weight_mem_ch3[8]);   weight_9 <= to_signed(weight_mem_ch3[9]);
                    weight_10 <= to_signed(weight_mem_ch3[10]); weight_11 <= to_signed(weight_mem_ch3[11]);
                    weight_12 <= to_signed(weight_mem_ch3[12]); weight_13 <= to_signed(weight_mem_ch3[13]);
                    weight_14 <= to_signed(weight_mem_ch3[14]); weight_15 <= to_signed(weight_mem_ch3[15]);
                    weight_16 <= to_signed(weight_mem_ch3[16]); weight_17 <= to_signed(weight_mem_ch3[17]);
                    weight_18 <= to_signed(weight_mem_ch3[18]); weight_19 <= to_signed(weight_mem_ch3[19]);
                    weight_20 <= to_signed(weight_mem_ch3[20]); weight_21 <= to_signed(weight_mem_ch3[21]);
                    weight_22 <= to_signed(weight_mem_ch3[22]); weight_23 <= to_signed(weight_mem_ch3[23]);
                    weight_24 <= to_signed(weight_mem_ch3[24]);
                end
                3'd4: begin
                    weight_0 <= to_signed(weight_mem_ch4[0]);   weight_1 <= to_signed(weight_mem_ch4[1]);
                    weight_2 <= to_signed(weight_mem_ch4[2]);   weight_3 <= to_signed(weight_mem_ch4[3]);
                    weight_4 <= to_signed(weight_mem_ch4[4]);   weight_5 <= to_signed(weight_mem_ch4[5]);
                    weight_6 <= to_signed(weight_mem_ch4[6]);   weight_7 <= to_signed(weight_mem_ch4[7]);
                    weight_8 <= to_signed(weight_mem_ch4[8]);   weight_9 <= to_signed(weight_mem_ch4[9]);
                    weight_10 <= to_signed(weight_mem_ch4[10]); weight_11 <= to_signed(weight_mem_ch4[11]);
                    weight_12 <= to_signed(weight_mem_ch4[12]); weight_13 <= to_signed(weight_mem_ch4[13]);
                    weight_14 <= to_signed(weight_mem_ch4[14]); weight_15 <= to_signed(weight_mem_ch4[15]);
                    weight_16 <= to_signed(weight_mem_ch4[16]); weight_17 <= to_signed(weight_mem_ch4[17]);
                    weight_18 <= to_signed(weight_mem_ch4[18]); weight_19 <= to_signed(weight_mem_ch4[19]);
                    weight_20 <= to_signed(weight_mem_ch4[20]); weight_21 <= to_signed(weight_mem_ch4[21]);
                    weight_22 <= to_signed(weight_mem_ch4[22]); weight_23 <= to_signed(weight_mem_ch4[23]);
                    weight_24 <= to_signed(weight_mem_ch4[24]);
                end
                3'd5: begin
                    weight_0 <= to_signed(weight_mem_ch5[0]);   weight_1 <= to_signed(weight_mem_ch5[1]);
                    weight_2 <= to_signed(weight_mem_ch5[2]);   weight_3 <= to_signed(weight_mem_ch5[3]);
                    weight_4 <= to_signed(weight_mem_ch5[4]);   weight_5 <= to_signed(weight_mem_ch5[5]);
                    weight_6 <= to_signed(weight_mem_ch5[6]);   weight_7 <= to_signed(weight_mem_ch5[7]);
                    weight_8 <= to_signed(weight_mem_ch5[8]);   weight_9 <= to_signed(weight_mem_ch5[9]);
                    weight_10 <= to_signed(weight_mem_ch5[10]); weight_11 <= to_signed(weight_mem_ch5[11]);
                    weight_12 <= to_signed(weight_mem_ch5[12]); weight_13 <= to_signed(weight_mem_ch5[13]);
                    weight_14 <= to_signed(weight_mem_ch5[14]); weight_15 <= to_signed(weight_mem_ch5[15]);
                    weight_16 <= to_signed(weight_mem_ch5[16]); weight_17 <= to_signed(weight_mem_ch5[17]);
                    weight_18 <= to_signed(weight_mem_ch5[18]); weight_19 <= to_signed(weight_mem_ch5[19]);
                    weight_20 <= to_signed(weight_mem_ch5[20]); weight_21 <= to_signed(weight_mem_ch5[21]);
                    weight_22 <= to_signed(weight_mem_ch5[22]); weight_23 <= to_signed(weight_mem_ch5[23]);
                    weight_24 <= to_signed(weight_mem_ch5[24]);
                end
            endcase
        end else begin
            // Invalid channel - force all weights to zero
            clear_all_weights();
        end
    end
    endtask
    
    // FSM and weight loading logic
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            weight_valid <= 1'b0;
            stored_kernel_idx <= 3'd0;
            
            // Initialize outputs to zero
            clear_all_weights();
        end
        else begin
            case (state)
                IDLE: begin
                    weight_valid <= 1'b0;
                    if (weight_req && mem_init_done) begin  // Wait for memory initialization
                        stored_kernel_idx <= kernel_idx;
                        state <= LOADING;
                        
                        $display("Loading channel %d weights, time=%0t", kernel_idx, $time);
                    end
                end
                
                LOADING: begin
                    // Load weights from the selected channel
                    load_channel_weights(stored_kernel_idx);
                    
                    state <= READY;
                    weight_valid <= 1'b1;
                    
                    // Debug: Display first few loaded weights (only for valid channels)
                    if (stored_kernel_idx <= 3'd5) begin
                        $display("Loaded channel %d: w0=%0d w1=%0d w12=%0d w24=%0d (signed values)", 
                                stored_kernel_idx, 
                                to_signed(
                                    (stored_kernel_idx == 3'd0) ? weight_mem_ch0[0] :
                                    (stored_kernel_idx == 3'd1) ? weight_mem_ch1[0] :
                                    (stored_kernel_idx == 3'd2) ? weight_mem_ch2[0] :
                                    (stored_kernel_idx == 3'd3) ? weight_mem_ch3[0] :
                                    (stored_kernel_idx == 3'd4) ? weight_mem_ch4[0] : weight_mem_ch5[0]
                                ),
                                to_signed(
                                    (stored_kernel_idx == 3'd0) ? weight_mem_ch0[1] :
                                    (stored_kernel_idx == 3'd1) ? weight_mem_ch1[1] :
                                    (stored_kernel_idx == 3'd2) ? weight_mem_ch2[1] :
                                    (stored_kernel_idx == 3'd3) ? weight_mem_ch3[1] :
                                    (stored_kernel_idx == 3'd4) ? weight_mem_ch4[1] : weight_mem_ch5[1]
                                ),
                                to_signed(
                                    (stored_kernel_idx == 3'd0) ? weight_mem_ch0[12] :
                                    (stored_kernel_idx == 3'd1) ? weight_mem_ch1[12] :
                                    (stored_kernel_idx == 3'd2) ? weight_mem_ch2[12] :
                                    (stored_kernel_idx == 3'd3) ? weight_mem_ch3[12] :
                                    (stored_kernel_idx == 3'd4) ? weight_mem_ch4[12] : weight_mem_ch5[12]
                                ),
                                to_signed(
                                    (stored_kernel_idx == 3'd0) ? weight_mem_ch0[24] :
                                    (stored_kernel_idx == 3'd1) ? weight_mem_ch1[24] :
                                    (stored_kernel_idx == 3'd2) ? weight_mem_ch2[24] :
                                    (stored_kernel_idx == 3'd3) ? weight_mem_ch3[24] :
                                    (stored_kernel_idx == 3'd4) ? weight_mem_ch4[24] : weight_mem_ch5[24]
                                ));
                    end else begin
                        $display("Loaded channel %d: All weights set to 0 (invalid channel)", stored_kernel_idx);
                    end
                end
                
                READY: begin
                    // Keep valid high until request goes low
                    if (!weight_req) begin
                        state <= IDLE;
                        weight_valid <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule