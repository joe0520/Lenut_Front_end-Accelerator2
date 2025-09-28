`timescale 1ns / 1ps

module c3_controller (
	input clk,
	input rst_n,
	input is_done,
    input c1_mp_valid,
    input [7:0] c1_mp_data_ch_0,
    input [7:0] c1_mp_data_ch_1,
    input [7:0] c1_mp_data_ch_2,
    input [7:0] c1_mp_data_ch_3,
    input [7:0] c1_mp_data_ch_4,
    input [7:0] c1_mp_data_ch_5,
	output c3_mp_out_valid,
	output [7:0] c3_mp_out_ch_0,
	output [7:0] c3_mp_out_ch_1,
	output [7:0] c3_mp_out_ch_2,
	output [7:0] c3_mp_out_ch_3,
	output [7:0] c3_mp_out_ch_4,
	output [7:0] c3_mp_out_ch_5,
	output [7:0] c3_mp_out_ch_6,
	output [7:0] c3_mp_out_ch_7,
	output [7:0] c3_mp_out_ch_8,
	output [7:0] c3_mp_out_ch_9,
	output [7:0] c3_mp_out_ch_10,
	output [7:0] c3_mp_out_ch_11,
	output [7:0] c3_mp_out_ch_12,
	output [7:0] c3_mp_out_ch_13,
	output [7:0] c3_mp_out_ch_14,
	output [7:0] c3_mp_out_ch_15
);  
    
    wire s2_valid;
    wire [239:0] s2_data_0;
    wire [239:0] s2_data_1;
    wire [239:0] s2_data_2;
    
	s2_line_controller s2_line_controller (
    .clk(clk),
    .rst_n(rst_n),
    .is_done(is_done),
    .c1_mp_valid(c1_mp_valid),
    .c1_mp_data_ch_0(c1_mp_data_ch_0),
    .c1_mp_data_ch_1(c1_mp_data_ch_1),
    .c1_mp_data_ch_2(c1_mp_data_ch_2),
    .c1_mp_data_ch_3(c1_mp_data_ch_3),
    .c1_mp_data_ch_4(c1_mp_data_ch_4),
    .c1_mp_data_ch_5(c1_mp_data_ch_5),
    .s2_valid(s2_valid),
    .s2_data_0(s2_data_0),
    .s2_data_1(s2_data_1),
    .s2_data_2(s2_data_2)
    );
    
    wire [199:0] s2_weight_0;
	wire [199:0] s2_weight_1;
	wire [199:0] s2_weight_2;
    
    c3_weight_bram_controller c3_weight_bram_controller(
	.clk(clk),
	.rst_n(rst_n),
	.s2_valid(s2_valid),
	.s2_weight_0(s2_weight_0),
	.s2_weight_1(s2_weight_1),
	.s2_weight_2(s2_weight_2)
    );
    
    wire c3_part_valid_0, c3_part_valid_1 ,c3_part_valid_2;
    wire signed [31:0] c3_part_0_0, c3_part_0_1, c3_part_0_2;
    wire signed [31:0] c3_part_1_0, c3_part_1_1, c3_part_1_2;
    
    c3_convolution_PU c3_convolution_PU_0 (
    .clk(clk),
    .rst_n(rst_n),
    .s2_valid(s2_valid),
    .s2_ifm(s2_data_0),
    .s2_weight(s2_weight_0),
    .c3_part_valid(c3_part_valid_0),
    .c3_part_0(c3_part_0_0),
    .c3_part_1(c3_part_1_0)
    );
    
    c3_convolution_PU c3_convolution_PU_1 (
    .clk(clk),
    .rst_n(rst_n),
    .s2_valid(s2_valid),
    .s2_ifm(s2_data_1),
    .s2_weight(s2_weight_1),
    .c3_part_valid(c3_part_valid_1),
    .c3_part_0(c3_part_0_1),
    .c3_part_1(c3_part_1_1)
    );
    
    c3_convolution_PU c3_convolution_PU_2 (
    .clk(clk),
    .rst_n(rst_n),
    .s2_valid(s2_valid),
    .s2_ifm(s2_data_2),
    .s2_weight(s2_weight_2),
    .c3_part_valid(c3_part_valid_2),
    .c3_part_0(c3_part_0_2),
    .c3_part_1(c3_part_1_2)
    );
    
    wire c3_part_valid = c3_part_valid_0 & c3_part_valid_1 & c3_part_valid_2;
    wire c3_valid;
    wire [7:0] c3_out_0;
    wire [7:0] c3_out_1;
    
    c3_relu_quanti c3_relu_quanti(
    .clk(clk),
    .rst_n(rst_n),
    .c3_part_valid(c3_part_valid),
    .c3_sum_0_0(c3_part_0_0),
    .c3_sum_0_1(c3_part_0_1),
    .c3_sum_0_2(c3_part_0_2),
    .c3_sum_1_0(c3_part_1_0),
    .c3_sum_1_1(c3_part_1_1),
    .c3_sum_1_2(c3_part_1_2),
    .c3_valid(c3_valid),
    .c3_out_0(c3_out_0),
    .c3_out_1(c3_out_1)
    );
    
    wire c3_reg_valid;
	wire [31:0] c3_reg_out_ch_0;
	wire [31:0] c3_reg_out_ch_1;
	wire [31:0] c3_reg_out_ch_2;
	wire [31:0] c3_reg_out_ch_3;
	wire [31:0] c3_reg_out_ch_4;
	wire [31:0] c3_reg_out_ch_5;
	wire [31:0] c3_reg_out_ch_6;
	wire [31:0] c3_reg_out_ch_7;
	wire [31:0] c3_reg_out_ch_8;
	wire [31:0] c3_reg_out_ch_9;
	wire [31:0] c3_reg_out_ch_10;
	wire [31:0] c3_reg_out_ch_11;
	wire [31:0] c3_reg_out_ch_12;
	wire [31:0] c3_reg_out_ch_13;
	wire [31:0] c3_reg_out_ch_14;
	wire [31:0] c3_reg_out_ch_15;
    
    c3_reg_controller c3_reg_controller (
	.clk(clk),
	.rst_n(rst_n),
	.c3_valid(c3_valid),
    .c3_out_0(c3_out_0),
    .c3_out_1(c3_out_1),
	.c3_reg_valid(c3_reg_valid),
	.c3_reg_out_ch_0(c3_reg_out_ch_0),
	.c3_reg_out_ch_1(c3_reg_out_ch_1),
	.c3_reg_out_ch_2(c3_reg_out_ch_2),
	.c3_reg_out_ch_3(c3_reg_out_ch_3),
	.c3_reg_out_ch_4(c3_reg_out_ch_4),
	.c3_reg_out_ch_5(c3_reg_out_ch_5),
	.c3_reg_out_ch_6(c3_reg_out_ch_6),
	.c3_reg_out_ch_7(c3_reg_out_ch_7),
	.c3_reg_out_ch_8(c3_reg_out_ch_8),
	.c3_reg_out_ch_9(c3_reg_out_ch_9),
	.c3_reg_out_ch_10(c3_reg_out_ch_10),
	.c3_reg_out_ch_11(c3_reg_out_ch_11),
	.c3_reg_out_ch_12(c3_reg_out_ch_12),
	.c3_reg_out_ch_13(c3_reg_out_ch_13),
	.c3_reg_out_ch_14(c3_reg_out_ch_14),
	.c3_reg_out_ch_15(c3_reg_out_ch_15)
    );
    
    c3_maxpooling_unit c3_maxpooling_unit(
	.clk(clk),
	.rst_n(rst_n),
	.c3_reg_valid(c3_reg_valid),
	.c3_reg_out_ch_0(c3_reg_out_ch_0),
	.c3_reg_out_ch_1(c3_reg_out_ch_1),
	.c3_reg_out_ch_2(c3_reg_out_ch_2),
	.c3_reg_out_ch_3(c3_reg_out_ch_3),
	.c3_reg_out_ch_4(c3_reg_out_ch_4),
	.c3_reg_out_ch_5(c3_reg_out_ch_5),
	.c3_reg_out_ch_6(c3_reg_out_ch_6),
	.c3_reg_out_ch_7(c3_reg_out_ch_7),
	.c3_reg_out_ch_8(c3_reg_out_ch_8),
	.c3_reg_out_ch_9(c3_reg_out_ch_9),
	.c3_reg_out_ch_10(c3_reg_out_ch_10),
	.c3_reg_out_ch_11(c3_reg_out_ch_11),
	.c3_reg_out_ch_12(c3_reg_out_ch_12),
	.c3_reg_out_ch_13(c3_reg_out_ch_13),
	.c3_reg_out_ch_14(c3_reg_out_ch_14),
	.c3_reg_out_ch_15(c3_reg_out_ch_15),
	.c3_mp_out_valid(c3_mp_out_valid),
	.c3_mp_out_ch_0(c3_mp_out_ch_0),
	.c3_mp_out_ch_1(c3_mp_out_ch_1),
	.c3_mp_out_ch_2(c3_mp_out_ch_2),
	.c3_mp_out_ch_3(c3_mp_out_ch_3),
	.c3_mp_out_ch_4(c3_mp_out_ch_4),
	.c3_mp_out_ch_5(c3_mp_out_ch_5),
	.c3_mp_out_ch_6(c3_mp_out_ch_6),
	.c3_mp_out_ch_7(c3_mp_out_ch_7),
	.c3_mp_out_ch_8(c3_mp_out_ch_8),
	.c3_mp_out_ch_9(c3_mp_out_ch_9),
	.c3_mp_out_ch_10(c3_mp_out_ch_10),
	.c3_mp_out_ch_11(c3_mp_out_ch_11),
	.c3_mp_out_ch_12(c3_mp_out_ch_12),
	.c3_mp_out_ch_13(c3_mp_out_ch_13),
	.c3_mp_out_ch_14(c3_mp_out_ch_14),
	.c3_mp_out_ch_15(c3_mp_out_ch_15)
    );
    
endmodule