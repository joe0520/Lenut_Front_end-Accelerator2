`timescale 1ns / 1ps

module c3_convolution_PU (
    input clk,
    input rst_n,
    input s2_valid,
    input [239:0] s2_ifm,
    input [199:0] s2_weight,
    output reg c3_part_valid,
    output reg signed [31:0] c3_part_0,
    output reg signed [31:0] c3_part_1
);

    integer i;
    integer j;
    reg [15:0] ifm[0:29];
    reg signed [15:0] weight [0:24];

    // Combinational Logic to unpack inputs
    always @(*) begin
        for (i = 0; i < 30; i = i+1) begin
            ifm[i] = s2_ifm[((240-8*i)-1) -: 8];
        end
        for (j = 0; j < 25; j = j+1) begin
            weight[j] = $signed(s2_weight[((200-8*j)-1) -: 8]);
        end
    end

    // =================================================================
    // Pipeline Registers
    // =================================================================

    // Pipeline Valid Signals (ÆÄÀÌÇÁ¶óÀÎ ±íÀÌ¿¡ ¸Â°Ô È®Àå)
    reg s2_valid_0, s2_valid_1, s2_valid_2, s2_valid_3, s2_valid_4;

    // --- Pipe 0: Multiplication Results ---
    (* multstyle = "dsp" *) reg signed [31:0] mul_p0[0:25]; // line_0 °è»ê¿ë °ö¼À °á°ú
    (* multstyle = "dsp" *) reg signed [31:0] mul_p1[0:25]; // line_1 °è»ê¿ë °ö¼À °á°ú

    // --- Pipe 1: 1st Level Adder Tree ---
    // 2-input µ¡¼À °á°ú ÀúÀå
    reg signed [31:0] add1_p0[0:12];
    reg signed [31:0] add1_p1[0:12];

    // --- Pipe 2: 2nd Level Adder Tree ---
    // 2-input ¶Ç´Â 3-input µ¡¼À °á°ú ÀúÀå
    reg signed [31:0] add2_p0[0:5];
    reg signed [31:0] add2_p1[0:5];
    
    // --- Pipe 3: 3rd Level Adder Tree ---
    reg signed [31:0] add3_p0[0:2];
    reg signed [31:0] add3_p1[0:2];

    // --- Pipe 4: Final Summation ---
    reg signed [31:0] final_sum_p0;
    reg signed [31:0] final_sum_p1;


    // =================================================================
    // Pipeline Stage 0: Multiplication Only (DSP Target)
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 26; i = i + 1) begin
                mul_p0[i] <= 0;
                mul_p1[i] <= 0;
            end
        end else if (s2_valid) begin
            // --- Multiplications for c3_part_0 ---
            mul_p0[0]  <= $signed({ifm[0]})  * weight[0];
            mul_p0[1]  <= $signed({ifm[1]})  * weight[1];
            mul_p0[2]  <= $signed({ifm[2]})  * weight[2];
            mul_p0[3]  <= $signed({ifm[3]})  * weight[3];
            mul_p0[4]  <= $signed({ifm[4]})  * weight[4];
            mul_p0[5]  <= $signed({ifm[6]})  * weight[5];
            mul_p0[6]  <= $signed({ifm[7]})  * weight[6];
            mul_p0[7]  <= $signed({ifm[8]})  * weight[7];
            mul_p0[8]  <= $signed({ifm[9]})  * weight[8];
            mul_p0[9]  <= $signed({ifm[10]}) * weight[9];
            mul_p0[10] <= $signed({ifm[12]}) * weight[10];
            mul_p0[11] <= $signed({ifm[13]}) * weight[11];
            mul_p0[12] <= $signed({ifm[14]}) * weight[12];
            mul_p0[13] <= $signed({ifm[15]}) * weight[13];
            mul_p0[14] <= $signed({ifm[16]}) * weight[14];
            mul_p0[15] <= $signed({ifm[18]}) * weight[15];
            mul_p0[16] <= $signed({ifm[19]}) * weight[16];
            mul_p0[17] <= $signed({ifm[20]}) * weight[17];
            mul_p0[18] <= $signed({ifm[21]}) * weight[18];
            mul_p0[19] <= $signed({ifm[22]}) * weight[19];
            mul_p0[20] <= $signed({ifm[24]}) * weight[20];
            mul_p0[21] <= $signed({ifm[25]}) * weight[21];
            mul_p0[22] <= $signed({ifm[26]}) * weight[22];
            mul_p0[23] <= $signed({ifm[27]}) * weight[23];
            mul_p0[24] <= $signed({ifm[28]}) * weight[24];
            mul_p0[25] <= 0; // Dummy for alignment

            // --- Multiplications for c3_part_1 ---
            mul_p1[0]  <= $signed({ifm[1]})  * weight[0];
            mul_p1[1]  <= $signed({ifm[2]})  * weight[1];
            mul_p1[2]  <= $signed({ifm[3]})  * weight[2];
            mul_p1[3]  <= $signed({ifm[4]})  * weight[3];
            mul_p1[4]  <= $signed({ifm[5]})  * weight[4];
            mul_p1[5]  <= $signed({ifm[7]})  * weight[5];
            mul_p1[6]  <= $signed({ifm[8]})  * weight[6];
            mul_p1[7]  <= $signed({ifm[9]})  * weight[7];
            mul_p1[8]  <= $signed({ifm[10]}) * weight[8];
            mul_p1[9]  <= $signed({ifm[11]}) * weight[9];
            mul_p1[10] <= $signed({ifm[13]}) * weight[10];
            mul_p1[11] <= $signed({ifm[14]}) * weight[11];
            mul_p1[12] <= $signed({ifm[15]}) * weight[12];
            mul_p1[13] <= $signed({ifm[16]}) * weight[13];
            mul_p1[14] <= $signed({ifm[17]}) * weight[14];
            mul_p1[15] <= $signed({ifm[19]}) * weight[15];
            mul_p1[16] <= $signed({ifm[20]}) * weight[16];
            mul_p1[17] <= $signed({ifm[21]}) * weight[17];
            mul_p1[18] <= $signed({ifm[22]}) * weight[18];
            mul_p1[19] <= $signed({ifm[23]}) * weight[19];
            mul_p1[20] <= $signed({ifm[25]}) * weight[20];
            mul_p1[21] <= $signed({ifm[26]}) * weight[21];
            mul_p1[22] <= $signed({ifm[27]}) * weight[22];
            mul_p1[23] <= $signed({ifm[28]}) * weight[23];
            mul_p1[24] <= $signed({ifm[29]}) * weight[24];
            mul_p1[25] <= 0; // Dummy for alignment
        end
    end

    // =================================================================
    // Pipeline Stage 1: Adder Tree Level 1
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 13; i = i + 1) begin
                add1_p0[i] <= 0;
                add1_p1[i] <= 0;
            end
        end else if (s2_valid_0) begin
            // --- Adders for c3_part_0 ---
            add1_p0[0] <= mul_p0[0] + mul_p0[1];
            add1_p0[1] <= mul_p0[2] + mul_p0[3];
            add1_p0[2] <= mul_p0[4] + mul_p0[5];
            add1_p0[3] <= mul_p0[6] + mul_p0[7];
            add1_p0[4] <= mul_p0[8] + mul_p0[9];
            add1_p0[5] <= mul_p0[10] + mul_p0[11];
            add1_p0[6] <= mul_p0[12] + mul_p0[13];
            add1_p0[7] <= mul_p0[14] + mul_p0[15];
            add1_p0[8] <= mul_p0[16] + mul_p0[17];
            add1_p0[9] <= mul_p0[18] + mul_p0[19];
            add1_p0[10] <= mul_p0[20] + mul_p0[21];
            add1_p0[11] <= mul_p0[22] + mul_p0[23];
            add1_p0[12] <= mul_p0[24] + mul_p0[25]; // mul_p0[25] is 0

            // --- Adders for c3_part_1 ---
            add1_p1[0] <= mul_p1[0] + mul_p1[1];
            add1_p1[1] <= mul_p1[2] + mul_p1[3];
            add1_p1[2] <= mul_p1[4] + mul_p1[5];
            add1_p1[3] <= mul_p1[6] + mul_p1[7];
            add1_p1[4] <= mul_p1[8] + mul_p1[9];
            add1_p1[5] <= mul_p1[10] + mul_p1[11];
            add1_p1[6] <= mul_p1[12] + mul_p1[13];
            add1_p1[7] <= mul_p1[14] + mul_p1[15];
            add1_p1[8] <= mul_p1[16] + mul_p1[17];
            add1_p1[9] <= mul_p1[18] + mul_p1[19];
            add1_p1[10] <= mul_p1[20] + mul_p1[21];
            add1_p1[11] <= mul_p1[22] + mul_p1[23];
            add1_p1[12] <= mul_p1[24] + mul_p1[25]; // mul_p1[25] is 0
        end
    end

    // =================================================================
    // Pipeline Stage 2: Adder Tree Level 2
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 6; i = i + 1) begin
                add2_p0[i] <= 0;
                add2_p1[i] <= 0;
            end
        end else if (s2_valid_1) begin
            // --- Adders for c3_part_0 ---
            add2_p0[0] <= add1_p0[0] + add1_p0[1];
            add2_p0[1] <= add1_p0[2] + add1_p0[3];
            add2_p0[2] <= add1_p0[4] + add1_p0[5];
            add2_p0[3] <= add1_p0[6] + add1_p0[7];
            add2_p0[4] <= add1_p0[8] + add1_p0[9];
            add2_p0[5] <= add1_p0[10] + add1_p0[11] + add1_p0[12]; // 3-input add

            // --- Adders for c3_part_1 ---
            add2_p1[0] <= add1_p1[0] + add1_p1[1];
            add2_p1[1] <= add1_p1[2] + add1_p1[3];
            add2_p1[2] <= add1_p1[4] + add1_p1[5];
            add2_p1[3] <= add1_p1[6] + add1_p1[7];
            add2_p1[4] <= add1_p1[8] + add1_p1[9];
            add2_p1[5] <= add1_p1[10] + add1_p1[11] + add1_p1[12]; // 3-input add
        end
    end

    // =================================================================
    // Pipeline Stage 3: Adder Tree Level 3
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
             for (i = 0; i < 3; i = i + 1) begin
                add3_p0[i] <= 0;
                add3_p1[i] <= 0;
            end
        end else if (s2_valid_2) begin
            // --- Adders for c3_part_0 ---
            add3_p0[0] <= add2_p0[0] + add2_p0[1];
            add3_p0[1] <= add2_p0[2] + add2_p0[3];
            add3_p0[2] <= add2_p0[4] + add2_p0[5];
            
            // --- Adders for c3_part_1 ---
            add3_p1[0] <= add2_p1[0] + add2_p1[1];
            add3_p1[1] <= add2_p1[2] + add2_p1[3];
            add3_p1[2] <= add2_p1[4] + add2_p1[5];
        end
    end

    // =================================================================
    // Pipeline Stage 4: Final Summation
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            final_sum_p0 <= 0;
            final_sum_p1 <= 0;
        end else if (s2_valid_3) begin
            final_sum_p0 <= add3_p0[0] + add3_p0[1] + add3_p0[2];
            final_sum_p1 <= add3_p1[0] + add3_p1[1] + add3_p1[2];
        end
    end

    // =================================================================
    // Pipeline Stage 5: Output Register
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            c3_part_0 <= 0;
            c3_part_1 <= 0;
        end else if (s2_valid_4) begin
            c3_part_0 <= final_sum_p0;
            c3_part_1 <= final_sum_p1;
        end
    end
    
    // =================================================================
    // Pipeline Valid Signal Chain
    // =================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            s2_valid_0 <= 1'b0;
            s2_valid_1 <= 1'b0;
            s2_valid_2 <= 1'b0;
            s2_valid_3 <= 1'b0;
            s2_valid_4 <= 1'b0;
            c3_part_valid <= 1'b0;
        end else begin
            s2_valid_0 <= s2_valid;
            s2_valid_1 <= s2_valid_0;
            s2_valid_2 <= s2_valid_1;
            s2_valid_3 <= s2_valid_2;
            s2_valid_4 <= s2_valid_3;
            c3_part_valid <= s2_valid_4;
        end
    end

endmodule