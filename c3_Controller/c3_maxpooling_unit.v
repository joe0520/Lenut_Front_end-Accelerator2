`timescale 1ns / 1ps

module c3_maxpooling_unit(
	input clk,
	input rst_n,
	input c3_reg_valid,
	input [31:0] c3_reg_out_ch_0,
	input [31:0] c3_reg_out_ch_1,
	input [31:0] c3_reg_out_ch_2,
	input [31:0] c3_reg_out_ch_3,
	input [31:0] c3_reg_out_ch_4,
	input [31:0] c3_reg_out_ch_5,
	input [31:0] c3_reg_out_ch_6,
	input [31:0] c3_reg_out_ch_7,
	input [31:0] c3_reg_out_ch_8,
	input [31:0] c3_reg_out_ch_9,
	input [31:0] c3_reg_out_ch_10,
	input [31:0] c3_reg_out_ch_11,
	input [31:0] c3_reg_out_ch_12,
	input [31:0] c3_reg_out_ch_13,
	input [31:0] c3_reg_out_ch_14,
	input [31:0] c3_reg_out_ch_15,
	output reg c3_mp_out_valid,
	output reg [7:0] c3_mp_out_ch_0,
	output reg [7:0] c3_mp_out_ch_1,
	output reg [7:0] c3_mp_out_ch_2,
	output reg [7:0] c3_mp_out_ch_3,
	output reg [7:0] c3_mp_out_ch_4,
	output reg [7:0] c3_mp_out_ch_5,
	output reg [7:0] c3_mp_out_ch_6,
	output reg [7:0] c3_mp_out_ch_7,
	output reg [7:0] c3_mp_out_ch_8,
	output reg [7:0] c3_mp_out_ch_9,
	output reg [7:0] c3_mp_out_ch_10,
	output reg [7:0] c3_mp_out_ch_11,
	output reg [7:0] c3_mp_out_ch_12,
	output reg [7:0] c3_mp_out_ch_13,
	output reg [7:0] c3_mp_out_ch_14,
	output reg [7:0] c3_mp_out_ch_15
);

	reg c3_reg_valid_0;

	reg [7:0] mp_buf[0:15][0:1];

	integer i;
	integer j;

	//pipe_0_operation
	always@(posedge clk)begin
		if(!rst_n)begin
			for(i=0; i<16; i=i+1)begin
				for(j=0; j<2; j=j+1)begin
					mp_buf[i][j] <= 0;
				end
			end
		end else if(c3_reg_valid) begin
			//ch0
			if(c3_reg_out_ch_0[31:24]>c3_reg_out_ch_0[23:16]) mp_buf[0][0] <= c3_reg_out_ch_0[31:24];
			else mp_buf[0][0] <= c3_reg_out_ch_0[23:16];
			if(c3_reg_out_ch_0[15:8]>c3_reg_out_ch_0[7:0]) mp_buf[0][1] <= c3_reg_out_ch_0[15:8];
			else mp_buf[0][1] <= c3_reg_out_ch_0[7:0];
			//ch1
			if(c3_reg_out_ch_1[31:24]>c3_reg_out_ch_1[23:16]) mp_buf[1][0] <= c3_reg_out_ch_1[31:24];
			else mp_buf[1][0] <= c3_reg_out_ch_1[23:16];
			if(c3_reg_out_ch_1[15:8]>c3_reg_out_ch_1[7:0]) mp_buf[1][1] <= c3_reg_out_ch_1[15:8];
			else mp_buf[1][1] <= c3_reg_out_ch_1[7:0];
			//ch2
			if(c3_reg_out_ch_2[31:24]>c3_reg_out_ch_2[23:16]) mp_buf[2][0] <= c3_reg_out_ch_2[31:24];
			else mp_buf[2][0] <= c3_reg_out_ch_2[23:16];
			if(c3_reg_out_ch_2[15:8]>c3_reg_out_ch_2[7:0]) mp_buf[2][1] <= c3_reg_out_ch_2[15:8];
			else mp_buf[2][1] <= c3_reg_out_ch_2[7:0];
			//ch3
			if(c3_reg_out_ch_3[31:24]>c3_reg_out_ch_3[23:16]) mp_buf[3][0] <= c3_reg_out_ch_3[31:24];
			else mp_buf[3][0] <= c3_reg_out_ch_3[23:16];
			if(c3_reg_out_ch_3[15:8]>c3_reg_out_ch_3[7:0]) mp_buf[3][1] <= c3_reg_out_ch_3[15:8];
			else mp_buf[3][1] <= c3_reg_out_ch_3[7:0];
			//ch4
			if(c3_reg_out_ch_4[31:24]>c3_reg_out_ch_4[23:16]) mp_buf[4][0] <= c3_reg_out_ch_4[31:24];
			else mp_buf[4][0] <= c3_reg_out_ch_4[23:16];
			if(c3_reg_out_ch_4[15:8]>c3_reg_out_ch_4[7:0]) mp_buf[4][1] <= c3_reg_out_ch_4[15:8];
			else mp_buf[4][1] <= c3_reg_out_ch_4[7:0];
			//ch5
			if(c3_reg_out_ch_5[31:24]>c3_reg_out_ch_5[23:16]) mp_buf[5][0] <= c3_reg_out_ch_5[31:24];
			else mp_buf[5][0] <= c3_reg_out_ch_5[23:16];
			if(c3_reg_out_ch_5[15:8]>c3_reg_out_ch_5[7:0]) mp_buf[5][1] <= c3_reg_out_ch_5[15:8];
			else mp_buf[5][1] <= c3_reg_out_ch_5[7:0];
			//ch6
			if(c3_reg_out_ch_6[31:24]>c3_reg_out_ch_6[23:16]) mp_buf[6][0] <= c3_reg_out_ch_6[31:24];
			else mp_buf[6][0] <= c3_reg_out_ch_6[23:16];
			if(c3_reg_out_ch_6[15:8]>c3_reg_out_ch_6[7:0]) mp_buf[6][1] <= c3_reg_out_ch_6[15:8];
			else mp_buf[6][1] <= c3_reg_out_ch_6[7:0];
			//ch7
			if(c3_reg_out_ch_7[31:24]>c3_reg_out_ch_7[23:16]) mp_buf[7][0] <= c3_reg_out_ch_7[31:24];
			else mp_buf[7][0] <= c3_reg_out_ch_7[23:16];
			if(c3_reg_out_ch_7[15:8]>c3_reg_out_ch_7[7:0]) mp_buf[7][1] <= c3_reg_out_ch_7[15:8];
			else mp_buf[7][1] <= c3_reg_out_ch_7[7:0];
			//ch8
			if(c3_reg_out_ch_8[31:24]>c3_reg_out_ch_8[23:16]) mp_buf[8][0] <= c3_reg_out_ch_8[31:24];
			else mp_buf[8][0] <= c3_reg_out_ch_8[23:16];
			if(c3_reg_out_ch_8[15:8]>c3_reg_out_ch_8[7:0]) mp_buf[8][1] <= c3_reg_out_ch_8[15:8];
			else mp_buf[8][1] <= c3_reg_out_ch_8[7:0];
			//ch9
			if(c3_reg_out_ch_9[31:24]>c3_reg_out_ch_9[23:16]) mp_buf[9][0] <= c3_reg_out_ch_9[31:24];
			else mp_buf[9][0] <= c3_reg_out_ch_9[23:16];
			if(c3_reg_out_ch_9[15:8]>c3_reg_out_ch_9[7:0]) mp_buf[9][1] <= c3_reg_out_ch_9[15:8];
			else mp_buf[9][1] <= c3_reg_out_ch_9[7:0];
			//ch10
			if(c3_reg_out_ch_10[31:24]>c3_reg_out_ch_10[23:16]) mp_buf[10][0] <= c3_reg_out_ch_10[31:24];
			else mp_buf[10][0] <= c3_reg_out_ch_10[23:16];
			if(c3_reg_out_ch_10[15:8]>c3_reg_out_ch_10[7:0]) mp_buf[10][1] <= c3_reg_out_ch_10[15:8];
			else mp_buf[10][1] <= c3_reg_out_ch_10[7:0];
			//ch11
			if(c3_reg_out_ch_11[31:24]>c3_reg_out_ch_11[23:16]) mp_buf[11][0] <= c3_reg_out_ch_11[31:24];
			else mp_buf[11][0] <= c3_reg_out_ch_11[23:16];
			if(c3_reg_out_ch_11[15:8]>c3_reg_out_ch_11[7:0]) mp_buf[11][1] <= c3_reg_out_ch_11[15:8];
			else mp_buf[11][1] <= c3_reg_out_ch_11[7:0];
			//ch12
			if(c3_reg_out_ch_12[31:24]>c3_reg_out_ch_12[23:16]) mp_buf[12][0] <= c3_reg_out_ch_12[31:24];
			else mp_buf[12][0] <= c3_reg_out_ch_12[23:16];
			if(c3_reg_out_ch_12[15:8]>c3_reg_out_ch_12[7:0]) mp_buf[12][1] <= c3_reg_out_ch_12[15:8];
			else mp_buf[12][1] <= c3_reg_out_ch_12[7:0];
			//ch13
			if(c3_reg_out_ch_13[31:24]>c3_reg_out_ch_13[23:16]) mp_buf[13][0] <= c3_reg_out_ch_13[31:24];
			else mp_buf[13][0] <= c3_reg_out_ch_13[23:16];
			if(c3_reg_out_ch_13[15:8]>c3_reg_out_ch_13[7:0]) mp_buf[13][1] <= c3_reg_out_ch_13[15:8];
			else mp_buf[13][1] <= c3_reg_out_ch_13[7:0];
			//ch14
			if(c3_reg_out_ch_14[31:24]>c3_reg_out_ch_14[23:16]) mp_buf[14][0] <= c3_reg_out_ch_14[31:24];
			else mp_buf[14][0] <= c3_reg_out_ch_14[23:16];
			if(c3_reg_out_ch_14[15:8]>c3_reg_out_ch_14[7:0]) mp_buf[14][1] <= c3_reg_out_ch_14[15:8];
			else mp_buf[14][1] <= c3_reg_out_ch_14[7:0];
			//ch15
			if(c3_reg_out_ch_15[31:24]>c3_reg_out_ch_15[23:16]) mp_buf[15][0] <= c3_reg_out_ch_15[31:24];
			else mp_buf[15][0] <= c3_reg_out_ch_15[23:16];
			if(c3_reg_out_ch_15[15:8]>c3_reg_out_ch_15[7:0]) mp_buf[15][1] <= c3_reg_out_ch_15[15:8];
			else mp_buf[15][1] <= c3_reg_out_ch_15[7:0];
		end
	end

	//pipe_1_operation
	always@(posedge clk)begin
		if(!rst_n)begin
			c3_mp_out_ch_0 <= 0;
			c3_mp_out_ch_1 <= 0;
			c3_mp_out_ch_2 <= 0;
			c3_mp_out_ch_3 <= 0;
			c3_mp_out_ch_4 <= 0;
			c3_mp_out_ch_5 <= 0;
			c3_mp_out_ch_6 <= 0;
			c3_mp_out_ch_7 <= 0;
			c3_mp_out_ch_8 <= 0;
			c3_mp_out_ch_9 <= 0;
			c3_mp_out_ch_10 <= 0;
			c3_mp_out_ch_11 <= 0;
			c3_mp_out_ch_12 <= 0;
			c3_mp_out_ch_13 <= 0;
			c3_mp_out_ch_14 <= 0;
			c3_mp_out_ch_15 <= 0;
		end else if(c3_reg_valid_0) begin
			//ch0
			if(mp_buf[0][0]>mp_buf[0][1]) c3_mp_out_ch_0 <= mp_buf[0][0];
			else c3_mp_out_ch_0 <= mp_buf[0][1];
			//ch1
			if(mp_buf[1][0]>mp_buf[1][1]) c3_mp_out_ch_1 <= mp_buf[1][0];
			else c3_mp_out_ch_1 <= mp_buf[1][1];
			//ch2
			if(mp_buf[2][0]>mp_buf[2][1]) c3_mp_out_ch_2 <= mp_buf[2][0];
			else c3_mp_out_ch_2 <= mp_buf[2][1];
			// ch3
			if(mp_buf[3][0] > mp_buf[3][1]) c3_mp_out_ch_3 <= mp_buf[3][0];
			else c3_mp_out_ch_3 <= mp_buf[3][1];
			// ch4
			if(mp_buf[4][0] > mp_buf[4][1]) c3_mp_out_ch_4 <= mp_buf[4][0];
			else c3_mp_out_ch_4 <= mp_buf[4][1];
			// ch5
			if(mp_buf[5][0] > mp_buf[5][1]) c3_mp_out_ch_5 <= mp_buf[5][0];
			else c3_mp_out_ch_5 <= mp_buf[5][1];
			// ch6
			if(mp_buf[6][0] > mp_buf[6][1]) c3_mp_out_ch_6 <= mp_buf[6][0];
			else c3_mp_out_ch_6 <= mp_buf[6][1];
			// ch7
			if(mp_buf[7][0] > mp_buf[7][1]) c3_mp_out_ch_7 <= mp_buf[7][0];
			else c3_mp_out_ch_7 <= mp_buf[7][1];
			// ch8
			if(mp_buf[8][0] > mp_buf[8][1]) c3_mp_out_ch_8 <= mp_buf[8][0];
			else c3_mp_out_ch_8 <= mp_buf[8][1];
			// ch9
			if(mp_buf[9][0] > mp_buf[9][1]) c3_mp_out_ch_9 <= mp_buf[9][0];
			else c3_mp_out_ch_9 <= mp_buf[9][1];
			// ch10
			if(mp_buf[10][0] > mp_buf[10][1]) c3_mp_out_ch_10 <= mp_buf[10][0];
			else c3_mp_out_ch_10 <= mp_buf[10][1];
			// ch11
			if(mp_buf[11][0] > mp_buf[11][1]) c3_mp_out_ch_11 <= mp_buf[11][0];
			else c3_mp_out_ch_11 <= mp_buf[11][1];
			// ch12
			if(mp_buf[12][0] > mp_buf[12][1]) c3_mp_out_ch_12 <= mp_buf[12][0];
			else c3_mp_out_ch_12 <= mp_buf[12][1];
			// ch13
			if(mp_buf[13][0] > mp_buf[13][1]) c3_mp_out_ch_13 <= mp_buf[13][0];
			else c3_mp_out_ch_13 <= mp_buf[13][1];
			// ch14
			if(mp_buf[14][0] > mp_buf[14][1]) c3_mp_out_ch_14 <= mp_buf[14][0];
			else c3_mp_out_ch_14 <= mp_buf[14][1];
			// ch15
			if(mp_buf[15][0] > mp_buf[15][1]) c3_mp_out_ch_15 <= mp_buf[15][0];
			else c3_mp_out_ch_15 <= mp_buf[15][1];
		end
	end

	//pipeline_valid
	always@(posedge clk)begin
		if(!rst_n)begin
			c3_reg_valid_0 <= 0;
			c3_mp_out_valid <= 0;
		end else begin
			c3_reg_valid_0 <= c3_reg_valid;
			c3_mp_out_valid <= c3_reg_valid_0;
		end
	end

endmodule