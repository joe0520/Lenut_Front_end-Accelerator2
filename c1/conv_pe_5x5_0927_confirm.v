`timescale 1ns / 1ps

// conv_pe_5x5: 5x5 Convolution Processing Element for LeNet-5
// - Performs 5x5 convolution with ReLU and quantization
// - Input: 8-bit unsigned feature map, 8-bit signed weights
// - Output: 8-bit quantized result after ReLU
// - Pipeline: 1 cycle latency (valid_out aligns with processed data)

module conv_pe_5x5 (
    input           reset_n,
    input           clk,
    input           valid_in,      // input valid
    output reg      valid_out,     // aligned with pe_out (1-cycle after valid_in)
    output [7:0]    pe_out,        // quantized 8-bit output
    output [31:0]   sum_out,       // pre-activation sum (for debug)

    // Control
    input           relu_en,       // ReLU enable
    input           quan_en,       // Quantization enable  
    input [31:0]    psum,          // partial sum (can be used for bias)

    // 5x5 IFM window (UNSIGNED) - row-major order
    input [7:0] in_IF1,  in_IF2,  in_IF3,  in_IF4,  in_IF5,   // Row 0
    input [7:0] in_IF6,  in_IF7,  in_IF8,  in_IF9,  in_IF10,  // Row 1
    input [7:0] in_IF11, in_IF12, in_IF13, in_IF14, in_IF15,  // Row 2
    input [7:0] in_IF16, in_IF17, in_IF18, in_IF19, in_IF20,  // Row 3
    input [7:0] in_IF21, in_IF22, in_IF23, in_IF24, in_IF25,  // Row 4

    // 5x5 weight kernel (SIGNED) - row-major order
    input  signed [7:0] in_W1,  in_W2,  in_W3,  in_W4,  in_W5,   // Row 0
    input  signed [7:0] in_W6,  in_W7,  in_W8,  in_W9,  in_W10,  // Row 1
    input  signed [7:0] in_W11, in_W12, in_W13, in_W14, in_W15,  // Row 2
    input  signed [7:0] in_W16, in_W17, in_W18, in_W19, in_W20,  // Row 3
    input  signed [7:0] in_W21, in_W22, in_W23, in_W24, in_W25,  // Row 4

    // Debug outputs
    output [7:0]        debug_weight_0,
    output [7:0]        debug_weight_24,
    output [7:0]        debug_input_center,
    output signed [31:0] debug_sum_final
);

    // -----------------------------
    // 0-cycle: multiply & sum (combinational)
    // -----------------------------
    // Convert unsigned inputs to signed for multiplication
    wire signed [31:0] m0  = $signed({1'b0, in_IF1 }) * in_W1;
    wire signed [31:0] m1  = $signed({1'b0, in_IF2 }) * in_W2;
    wire signed [31:0] m2  = $signed({1'b0, in_IF3 }) * in_W3;
    wire signed [31:0] m3  = $signed({1'b0, in_IF4 }) * in_W4;
    wire signed [31:0] m4  = $signed({1'b0, in_IF5 }) * in_W5;
    wire signed [31:0] m5  = $signed({1'b0, in_IF6 }) * in_W6;
    wire signed [31:0] m6  = $signed({1'b0, in_IF7 }) * in_W7;
    wire signed [31:0] m7  = $signed({1'b0, in_IF8 }) * in_W8;
    wire signed [31:0] m8  = $signed({1'b0, in_IF9 }) * in_W9;
    wire signed [31:0] m9  = $signed({1'b0, in_IF10}) * in_W10;
    wire signed [31:0] m10 = $signed({1'b0, in_IF11}) * in_W11;
    wire signed [31:0] m11 = $signed({1'b0, in_IF12}) * in_W12;
    wire signed [31:0] m12 = $signed({1'b0, in_IF13}) * in_W13;
    wire signed [31:0] m13 = $signed({1'b0, in_IF14}) * in_W14;
    wire signed [31:0] m14 = $signed({1'b0, in_IF15}) * in_W15;
    wire signed [31:0] m15 = $signed({1'b0, in_IF16}) * in_W16;
    wire signed [31:0] m16 = $signed({1'b0, in_IF17}) * in_W17;
    wire signed [31:0] m17 = $signed({1'b0, in_IF18}) * in_W18;
    wire signed [31:0] m18 = $signed({1'b0, in_IF19}) * in_W19;
    wire signed [31:0] m19 = $signed({1'b0, in_IF20}) * in_W20;
    wire signed [31:0] m20 = $signed({1'b0, in_IF21}) * in_W21;
    wire signed [31:0] m21 = $signed({1'b0, in_IF22}) * in_W22;
    wire signed [31:0] m22 = $signed({1'b0, in_IF23}) * in_W23;
    wire signed [31:0] m23 = $signed({1'b0, in_IF24}) * in_W24;
    wire signed [31:0] m24 = $signed({1'b0, in_IF25}) * in_W25;

    // Sum all multiplications (grouped for better synthesis)
    wire signed [31:0] mult_sum =
        (m0+m1+m2+m3+m4) + (m5+m6+m7+m8+m9) +
        (m10+m11+m12+m13+m14) + (m15+m16+m17+m18+m19) +
        (m20+m21+m22+m23+m24);

    // Add partial sum (bias)
    wire signed [31:0] sum_with_psum = mult_sum + $signed(psum);

    // -----------------------------
    // 1-cycle: register pre-activation sum
    // -----------------------------
    reg signed [31:0] sum_final;
    always @(posedge clk) begin
        if (!reset_n) begin
            sum_final <= 32'sd0;
        end else if (valid_in) begin
            sum_final <= sum_with_psum;
        end
    end

    assign sum_out = sum_final;

    // -----------------------------
    // ReLU + Quantization (combinational) - FIXED
    // -----------------------------
    // ReLU: if negative, output 0 (proper signed comparison)
    wire signed [31:0] w_relu_out = (relu_en && (sum_final < 32'sd0)) ? 32'sd0 : sum_final;

    // Quantization: divide by 128 with rounding
    // Reference implementation from existing code
    wire [7:0] w_quan_out = (quan_en)
        ? ( (|w_relu_out[31:15]) ? 8'd255                    // Saturate to 255 if overflow
            : ((&w_relu_out[14:7]) ? w_relu_out[14:7]        // If all bits 14:7 are 1, no rounding needed
                : (w_relu_out[14:7] + w_relu_out[6])) )      // Round: add bit 6 for rounding
        : ( (w_relu_out > 32'sd255) ? 8'd255 : w_relu_out[7:0] );  // Without quantization

    assign pe_out = w_quan_out;

    // -----------------------------
    // Valid pipeline (1-cycle to match sum_final/pe_out)
    // -----------------------------
    always @(posedge clk) begin
        if (!reset_n) begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;   // pe_out becomes valid one cycle after valid_in
        end
    end

    // -----------------------------
    // Debug outputs
    // -----------------------------
    assign debug_weight_0     = in_W1[7:0];
    assign debug_weight_24    = in_W25[7:0];
    assign debug_input_center = in_IF13;
    assign debug_sum_final    = sum_final;

    // synthesis translate_off
    always @(posedge clk) begin
        if (valid_out && (pe_out > 8'd5)) begin
            $display("PE_DEBUG: sum=%0d, relu=%0d, quant=%0d  @%0t",
                     sum_final, w_relu_out, pe_out, $time);
        end
    end
    // synthesis translate_on

endmodule