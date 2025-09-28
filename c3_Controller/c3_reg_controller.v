`timescale 1ns / 1ps

module c3_reg_controller (
	input clk,
	input rst_n,
	input c3_valid,
    input [7:0] c3_out_0,
    input [7:0] c3_out_1,
	output reg c3_reg_valid,
	output reg [31:0] c3_reg_out_ch_0,
	output reg [31:0] c3_reg_out_ch_1,
	output reg [31:0] c3_reg_out_ch_2,
	output reg [31:0] c3_reg_out_ch_3,
	output reg [31:0] c3_reg_out_ch_4,
	output reg [31:0] c3_reg_out_ch_5,
	output reg [31:0] c3_reg_out_ch_6,
	output reg [31:0] c3_reg_out_ch_7,
	output reg [31:0] c3_reg_out_ch_8,
	output reg [31:0] c3_reg_out_ch_9,
	output reg [31:0] c3_reg_out_ch_10,
	output reg [31:0] c3_reg_out_ch_11,
	output reg [31:0] c3_reg_out_ch_12,
	output reg [31:0] c3_reg_out_ch_13,
	output reg [31:0] c3_reg_out_ch_14,
	output reg [31:0] c3_reg_out_ch_15
);
	
	localparam ping_read = 2'b00;
	localparam ping_write_pong_read = 2'b01;
	localparam pong_read = 2'b10;
	localparam pong_write_ping_read = 2'b11;

	reg push_flag;
	
	reg [3:0] w_cnt;
	reg [3:0] c_cnt;
	reg h_cnt;

	reg [7:0] ping_reg_0[0:15][0:9];
	reg [7:0] ping_reg_1[0:15][0:9];

	reg [7:0] pong_reg_0[0:15][0:9];
	reg [7:0] pong_reg_1[0:15][0:9];

	reg [1:0] c_state;
	reg [1:0] n_state;

	reg [3:0] write_cnt;

	integer i;
	integer j;

	always@(posedge clk)begin
		if(!rst_n)begin
			for(i=0; i<16; i=i+1)begin
				for(j=0; j<10; j=j+1)begin
					ping_reg_0[i][j] <=0;
					ping_reg_1[i][j] <=0;
					pong_reg_0[i][j] <=0;
					pong_reg_1[i][j] <=0;
				end
			end
		end else if(~push_flag & c3_valid) begin
			if(~h_cnt)begin
				ping_reg_0[c_cnt][w_cnt] <= c3_out_0;
				ping_reg_0[c_cnt][w_cnt+1] <= c3_out_1;
			end else begin
				ping_reg_1[c_cnt][w_cnt] <= c3_out_0;
				ping_reg_1[c_cnt][w_cnt+1] <= c3_out_1;
			end
		end else if(push_flag & c3_valid) begin
			if(~h_cnt)begin
				pong_reg_0[c_cnt][w_cnt] <= c3_out_0;
				pong_reg_0[c_cnt][w_cnt+1] <= c3_out_1;
			end else begin
				pong_reg_1[c_cnt][w_cnt] <= c3_out_0;
				pong_reg_1[c_cnt][w_cnt+1] <= c3_out_1;
			end
		end
	end

	always@(posedge clk)begin
		if(!rst_n)begin
			w_cnt <=0;
			c_cnt <=0;
			h_cnt <=0;
			push_flag<=0;
		end else if(c3_valid)begin
			if(h_cnt & (w_cnt == 8) & (c_cnt == 15))begin
				push_flag <= ~push_flag;
			end
			if((w_cnt ==8) & (c_cnt == 15))begin
				h_cnt <= ~h_cnt;
			end
			if((w_cnt == 8) & (c_cnt == 15))begin
				w_cnt <= 0;
			end else if(c_cnt == 15)begin
				w_cnt <= w_cnt + 2;
			end
			if(c_cnt == 15)begin
				c_cnt <= 0;
			end else begin
				c_cnt <= c_cnt + 1;
			end
		end
	end

	always@(posedge clk)begin
		if(!rst_n)begin
			c_state <= ping_read;
			write_cnt <= 0;
		end else begin
			c_state <= n_state;
			if(write_cnt == 8) begin
				write_cnt <= 0;
			end else if((c_state == ping_write_pong_read) | (c_state == pong_write_ping_read))begin
				write_cnt <= write_cnt + 2;
			end
		end
	end

	always@(*)begin
		n_state = c_state;
		case(c_state)
			ping_read:begin
				if(c3_valid & h_cnt & (w_cnt == 8) & (c_cnt == 15)) n_state = ping_write_pong_read;
			end
			ping_write_pong_read:begin
				if(write_cnt == 8) n_state = pong_read;
			end
			pong_read:begin
				if(c3_valid & h_cnt & (w_cnt == 8) & (c_cnt == 15)) n_state = pong_write_ping_read;
			end
			pong_write_ping_read:begin
				if(write_cnt == 8) n_state = ping_read;
			end
		endcase
	end

	always@(posedge clk)begin
		if(!rst_n)begin
			c3_reg_valid <= 0;
			c3_reg_out_ch_0 <= 0;
			c3_reg_out_ch_1 <= 0;
			c3_reg_out_ch_2 <= 0;
			c3_reg_out_ch_3 <= 0;
			c3_reg_out_ch_4 <= 0;
			c3_reg_out_ch_5 <= 0;
			c3_reg_out_ch_6 <= 0;
			c3_reg_out_ch_7 <= 0;
			c3_reg_out_ch_8 <= 0;
			c3_reg_out_ch_9 <= 0;
			c3_reg_out_ch_10 <= 0;
			c3_reg_out_ch_11 <= 0;
			c3_reg_out_ch_12 <= 0;
			c3_reg_out_ch_13 <= 0;
			c3_reg_out_ch_14 <= 0;
			c3_reg_out_ch_15 <= 0;
		end else if(c_state == ping_write_pong_read)begin
			c3_reg_valid <= 1;
			c3_reg_out_ch_0 <= {ping_reg_0[0][write_cnt], ping_reg_0[0][write_cnt+1], ping_reg_1[0][write_cnt], ping_reg_1[0][write_cnt+1]};
			c3_reg_out_ch_1 <= {ping_reg_0[1][write_cnt], ping_reg_0[1][write_cnt+1], ping_reg_1[1][write_cnt], ping_reg_1[1][write_cnt+1]};
			c3_reg_out_ch_2 <= {ping_reg_0[2][write_cnt], ping_reg_0[2][write_cnt+1], ping_reg_1[2][write_cnt], ping_reg_1[2][write_cnt+1]};
			c3_reg_out_ch_3 <= {ping_reg_0[3][write_cnt], ping_reg_0[3][write_cnt+1], ping_reg_1[3][write_cnt], ping_reg_1[3][write_cnt+1]};
			c3_reg_out_ch_4 <= {ping_reg_0[4][write_cnt], ping_reg_0[4][write_cnt+1], ping_reg_1[4][write_cnt], ping_reg_1[4][write_cnt+1]};
			c3_reg_out_ch_5 <= {ping_reg_0[5][write_cnt], ping_reg_0[5][write_cnt+1], ping_reg_1[5][write_cnt], ping_reg_1[5][write_cnt+1]};
			c3_reg_out_ch_6 <= {ping_reg_0[6][write_cnt], ping_reg_0[6][write_cnt+1], ping_reg_1[6][write_cnt], ping_reg_1[6][write_cnt+1]};
			c3_reg_out_ch_7 <= {ping_reg_0[7][write_cnt], ping_reg_0[7][write_cnt+1], ping_reg_1[7][write_cnt], ping_reg_1[7][write_cnt+1]};
			c3_reg_out_ch_8 <= {ping_reg_0[8][write_cnt], ping_reg_0[8][write_cnt+1], ping_reg_1[8][write_cnt], ping_reg_1[8][write_cnt+1]};
			c3_reg_out_ch_9 <= {ping_reg_0[9][write_cnt], ping_reg_0[9][write_cnt+1], ping_reg_1[9][write_cnt], ping_reg_1[9][write_cnt+1]};
			c3_reg_out_ch_10 <= {ping_reg_0[10][write_cnt], ping_reg_0[10][write_cnt+1], ping_reg_1[10][write_cnt], ping_reg_1[10][write_cnt+1]};
			c3_reg_out_ch_11 <= {ping_reg_0[11][write_cnt], ping_reg_0[11][write_cnt+1], ping_reg_1[11][write_cnt], ping_reg_1[11][write_cnt+1]};
			c3_reg_out_ch_12 <= {ping_reg_0[12][write_cnt], ping_reg_0[12][write_cnt+1], ping_reg_1[12][write_cnt], ping_reg_1[12][write_cnt+1]};
			c3_reg_out_ch_13 <= {ping_reg_0[13][write_cnt], ping_reg_0[13][write_cnt+1], ping_reg_1[13][write_cnt], ping_reg_1[13][write_cnt+1]};
			c3_reg_out_ch_14 <= {ping_reg_0[14][write_cnt], ping_reg_0[14][write_cnt+1], ping_reg_1[14][write_cnt], ping_reg_1[14][write_cnt+1]};
			c3_reg_out_ch_15 <= {ping_reg_0[15][write_cnt], ping_reg_0[15][write_cnt+1], ping_reg_1[15][write_cnt], ping_reg_1[15][write_cnt+1]};
		end else if(c_state == pong_write_ping_read)begin
			c3_reg_valid <= 1;
			c3_reg_out_ch_0 <= {pong_reg_0[0][write_cnt], pong_reg_0[0][write_cnt+1], pong_reg_1[0][write_cnt], pong_reg_1[0][write_cnt+1]};
			c3_reg_out_ch_1 <= {pong_reg_0[1][write_cnt], pong_reg_0[1][write_cnt+1], pong_reg_1[1][write_cnt], pong_reg_1[1][write_cnt+1]};
			c3_reg_out_ch_2 <= {pong_reg_0[2][write_cnt], pong_reg_0[2][write_cnt+1], pong_reg_1[2][write_cnt], pong_reg_1[2][write_cnt+1]};
			c3_reg_out_ch_3 <= {pong_reg_0[3][write_cnt], pong_reg_0[3][write_cnt+1], pong_reg_1[3][write_cnt], pong_reg_1[3][write_cnt+1]};
			c3_reg_out_ch_4 <= {pong_reg_0[4][write_cnt], pong_reg_0[4][write_cnt+1], pong_reg_1[4][write_cnt], pong_reg_1[4][write_cnt+1]};
			c3_reg_out_ch_5 <= {pong_reg_0[5][write_cnt], pong_reg_0[5][write_cnt+1], pong_reg_1[5][write_cnt], pong_reg_1[5][write_cnt+1]};
			c3_reg_out_ch_6 <= {pong_reg_0[6][write_cnt], pong_reg_0[6][write_cnt+1], pong_reg_1[6][write_cnt], pong_reg_1[6][write_cnt+1]};
			c3_reg_out_ch_7 <= {pong_reg_0[7][write_cnt], pong_reg_0[7][write_cnt+1], pong_reg_1[7][write_cnt], pong_reg_1[7][write_cnt+1]};
			c3_reg_out_ch_8 <= {pong_reg_0[8][write_cnt], pong_reg_0[8][write_cnt+1], pong_reg_1[8][write_cnt], pong_reg_1[8][write_cnt+1]};
			c3_reg_out_ch_9 <= {pong_reg_0[9][write_cnt], pong_reg_0[9][write_cnt+1], pong_reg_1[9][write_cnt], pong_reg_1[9][write_cnt+1]};
			c3_reg_out_ch_10 <= {pong_reg_0[10][write_cnt], pong_reg_0[10][write_cnt+1], pong_reg_1[10][write_cnt], pong_reg_1[10][write_cnt+1]};
			c3_reg_out_ch_11 <= {pong_reg_0[11][write_cnt], pong_reg_0[11][write_cnt+1], pong_reg_1[11][write_cnt], pong_reg_1[11][write_cnt+1]};
			c3_reg_out_ch_12 <= {pong_reg_0[12][write_cnt], pong_reg_0[12][write_cnt+1], pong_reg_1[12][write_cnt], pong_reg_1[12][write_cnt+1]};
			c3_reg_out_ch_13 <= {pong_reg_0[13][write_cnt], pong_reg_0[13][write_cnt+1], pong_reg_1[13][write_cnt], pong_reg_1[13][write_cnt+1]};
			c3_reg_out_ch_14 <= {pong_reg_0[14][write_cnt], pong_reg_0[14][write_cnt+1], pong_reg_1[14][write_cnt], pong_reg_1[14][write_cnt+1]};
			c3_reg_out_ch_15 <= {pong_reg_0[15][write_cnt], pong_reg_0[15][write_cnt+1], pong_reg_1[15][write_cnt], pong_reg_1[15][write_cnt+1]};
		end else begin
			c3_reg_valid <= 0;
		end
	end

endmodule