`timescale 1ns / 1ps

module c3_controller_tb;

	reg clk;
	reg rst_n;
	reg is_done;
    reg c1_mp_valid;
    reg [7:0] c1_mp_data_ch_0;
    reg [7:0] c1_mp_data_ch_1;
    reg [7:0] c1_mp_data_ch_2;
    reg [7:0] c1_mp_data_ch_3;
    reg [7:0] c1_mp_data_ch_4;
    reg [7:0] c1_mp_data_ch_5;
	wire c3_mp_out_valid;
	wire [7:0] c3_mp_out_ch_0;
	wire [7:0] c3_mp_out_ch_1;
	wire [7:0] c3_mp_out_ch_2;
	wire [7:0] c3_mp_out_ch_3;
	wire [7:0] c3_mp_out_ch_4;
	wire [7:0] c3_mp_out_ch_5;
	wire [7:0] c3_mp_out_ch_6;
	wire [7:0] c3_mp_out_ch_7;
	wire [7:0] c3_mp_out_ch_8;
	wire [7:0] c3_mp_out_ch_9;
	wire [7:0] c3_mp_out_ch_10;
	wire [7:0] c3_mp_out_ch_11;
	wire [7:0] c3_mp_out_ch_12;
	wire [7:0] c3_mp_out_ch_13;
	wire [7:0] c3_mp_out_ch_14;
	wire [7:0] c3_mp_out_ch_15;
	
	reg [7:0] buf_c3_mp_out_ch_0;
	reg [7:0] buf_c3_mp_out_ch_1;
	reg [7:0] buf_c3_mp_out_ch_2;
	reg [7:0] buf_c3_mp_out_ch_3;
	reg [7:0] buf_c3_mp_out_ch_4;
	reg [7:0] buf_c3_mp_out_ch_5;
	reg [7:0] buf_c3_mp_out_ch_6;
	reg [7:0] buf_c3_mp_out_ch_7;
	reg [7:0] buf_c3_mp_out_ch_8;
	reg [7:0] buf_c3_mp_out_ch_9;
	reg [7:0] buf_c3_mp_out_ch_10;
	reg [7:0] buf_c3_mp_out_ch_11;
	reg [7:0] buf_c3_mp_out_ch_12;
	reg [7:0] buf_c3_mp_out_ch_13;
	reg [7:0] buf_c3_mp_out_ch_14;
	reg [7:0] buf_c3_mp_out_ch_15;

	reg start = 0;

	reg [7:0] mem_c1_mp_data[0:14*14*6-1];
	
	reg buf_c3_mp_out_valid;
	
	reg [7:0] answer[0:25*16-1];
	reg [4:0] buf_ans_cnt;
	reg [4:0] ans_cnt;
	reg [7:0] answer_data[0:15];

	reg [7:0] c1_w_cnt;
	reg [13:0] c1_delay;

	always @(posedge clk) begin
		if(!rst_n)begin
			c1_w_cnt <= 0;
			is_done <= 0;
		end else if(c1_w_cnt == 14*14 & c1_delay == 8790)begin
			c1_w_cnt <= 0;
			is_done <= 1;
		end else if(start && c1_delay<14)begin
			c1_w_cnt <= c1_w_cnt + 1;
			is_done <= 0;
		end else begin
			is_done <= 0;
		end
	end
    
    always @(posedge clk) begin
        if (is_done) begin
            $display("Simulation finished at %0t", $time);
            $finish;
        end
    end
    
	always @(posedge clk) begin
		if(!rst_n)begin
			c1_delay <= 0;
		end else if(c1_delay == 8790)begin
			c1_delay <= 0;
		end else if(start)begin
			c1_delay <= c1_delay + 1;
		end
	end

	always @(posedge clk) begin
		if(rst_n == 0) begin
			c1_mp_valid <= 0;
			c1_mp_data_ch_0 <=0;
			c1_mp_data_ch_1 <=0;
			c1_mp_data_ch_2 <=0;
			c1_mp_data_ch_3 <=0;
			c1_mp_data_ch_4 <=0;
			c1_mp_data_ch_5 <=0;
		end else if (start && c1_delay<14) begin
			c1_mp_valid <= 1;
			c1_mp_data_ch_0 <= mem_c1_mp_data[14*14*0 + c1_w_cnt];
			c1_mp_data_ch_1 <= mem_c1_mp_data[14*14*1 + c1_w_cnt];
			c1_mp_data_ch_2 <= mem_c1_mp_data[14*14*2 + c1_w_cnt];
			c1_mp_data_ch_3 <= mem_c1_mp_data[14*14*3 + c1_w_cnt];
			c1_mp_data_ch_4 <= mem_c1_mp_data[14*14*4 + c1_w_cnt];
			c1_mp_data_ch_5 <= mem_c1_mp_data[14*14*5 + c1_w_cnt];
		end else begin
			c1_mp_valid <= 0;
		end
	end
	
	always@(*)begin
	   if(buf_c3_mp_out_valid)begin
           if(answer_data[0] != buf_c3_mp_out_ch_0) begin
                $display("0_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[0], buf_c3_mp_out_ch_0);
            end
            if(answer_data[1] != buf_c3_mp_out_ch_1) begin
                $display("1_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[1], buf_c3_mp_out_ch_1);
            end
            if(answer_data[2] != buf_c3_mp_out_ch_2) begin
                $display("2_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[2], buf_c3_mp_out_ch_2);
            end
            if(answer_data[3] != buf_c3_mp_out_ch_3) begin
                $display("3_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[3], buf_c3_mp_out_ch_3);
            end
            if(answer_data[4] != buf_c3_mp_out_ch_4) begin
                $display("4_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[4], buf_c3_mp_out_ch_4);
            end
            if(answer_data[5] != buf_c3_mp_out_ch_5) begin
                $display("5_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[5], buf_c3_mp_out_ch_5);
            end
            if(answer_data[6] != buf_c3_mp_out_ch_6) begin
                $display("6_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[6], buf_c3_mp_out_ch_6);
            end
            if(answer_data[7] != buf_c3_mp_out_ch_7) begin
                $display("7_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[7], buf_c3_mp_out_ch_7);
            end
            if(answer_data[8] != buf_c3_mp_out_ch_8) begin
                $display("8_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[8], buf_c3_mp_out_ch_8);
            end
            if(answer_data[9] != buf_c3_mp_out_ch_9) begin
                $display("9_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[9], buf_c3_mp_out_ch_9);
            end
            if(answer_data[10] != buf_c3_mp_out_ch_10) begin
                $display("10_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[10], buf_c3_mp_out_ch_10);
            end
            if(answer_data[11] != buf_c3_mp_out_ch_11) begin
                $display("11_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[11], buf_c3_mp_out_ch_11);
            end
            if(answer_data[12] != buf_c3_mp_out_ch_12) begin
                $display("12_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[12], buf_c3_mp_out_ch_12);
            end
            if(answer_data[13] != buf_c3_mp_out_ch_13) begin
                $display("13_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[13], buf_c3_mp_out_ch_13);
            end
            if(answer_data[14] != buf_c3_mp_out_ch_14) begin
                $display("14_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[14], buf_c3_mp_out_ch_14);
            end
            if(answer_data[15] != buf_c3_mp_out_ch_15) begin
                $display("15_Mismatch at %0d: answer=%0d, output=%0d", buf_ans_cnt, answer_data[15], buf_c3_mp_out_ch_15);
            end
        end
	end
	
	always@(posedge clk)begin
	   if(!rst_n)begin
	       buf_c3_mp_out_valid <= 0;
	       buf_c3_mp_out_ch_0 <=0;
	       buf_c3_mp_out_ch_1 <= 0;
	       buf_c3_mp_out_ch_2 <= 0;
	       buf_c3_mp_out_ch_3 <= 0;
	       buf_c3_mp_out_ch_4 <= 0;
	       buf_c3_mp_out_ch_5 <= 0;
	       buf_c3_mp_out_ch_6 <= 0;
	       buf_c3_mp_out_ch_7 <= 0;
	       buf_c3_mp_out_ch_8 <= 0;
	       buf_c3_mp_out_ch_9 <= 0;
	       buf_c3_mp_out_ch_10 <= 0;
	       buf_c3_mp_out_ch_11 <= 0;
	       buf_c3_mp_out_ch_12 <= 0;
	       buf_c3_mp_out_ch_13 <= 0;
	       buf_c3_mp_out_ch_14 <= 0;
	       buf_c3_mp_out_ch_15 <= 0;
	       buf_ans_cnt <= 0;
	   end else begin
	       buf_c3_mp_out_valid <= c3_mp_out_valid;
	       buf_ans_cnt <= ans_cnt;
	       buf_c3_mp_out_ch_0 <= c3_mp_out_ch_0;
	       buf_c3_mp_out_ch_1 <= c3_mp_out_ch_1;
	       buf_c3_mp_out_ch_2 <= c3_mp_out_ch_2;
	       buf_c3_mp_out_ch_3 <= c3_mp_out_ch_3;
	       buf_c3_mp_out_ch_4 <= c3_mp_out_ch_4;
	       buf_c3_mp_out_ch_5 <= c3_mp_out_ch_5;
	       buf_c3_mp_out_ch_6 <= c3_mp_out_ch_6;
	       buf_c3_mp_out_ch_7 <= c3_mp_out_ch_7;
	       buf_c3_mp_out_ch_8 <= c3_mp_out_ch_8;
	       buf_c3_mp_out_ch_9 <= c3_mp_out_ch_9;
	       buf_c3_mp_out_ch_10 <= c3_mp_out_ch_10;
	       buf_c3_mp_out_ch_11 <= c3_mp_out_ch_11;
	       buf_c3_mp_out_ch_12 <= c3_mp_out_ch_12;
	       buf_c3_mp_out_ch_13 <= c3_mp_out_ch_13;
	       buf_c3_mp_out_ch_14 <= c3_mp_out_ch_14;
	       buf_c3_mp_out_ch_15 <= c3_mp_out_ch_15;
	   end
	end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            ans_cnt <= 0;
            answer_data[0] <= 0;
            answer_data[1] <= 0;
            answer_data[2] <= 0;
            answer_data[3] <= 0;
            answer_data[4] <= 0;
            answer_data[5] <= 0;
            answer_data[6] <= 0;
            answer_data[7] <= 0;
            answer_data[8] <= 0;
            answer_data[9] <= 0;
            answer_data[10] <= 0;
            answer_data[11] <= 0;
            answer_data[12] <= 0;
            answer_data[13] <= 0;
            answer_data[14] <= 0;
            answer_data[15] <= 0;
        end else if(c3_mp_out_valid)begin
            ans_cnt <= ans_cnt + 1;
            answer_data[0] <= answer[25*0  + ans_cnt];
            answer_data[1] <= answer[25*1  + ans_cnt];
            answer_data[2] <= answer[25*2  + ans_cnt];
            answer_data[3] <= answer[25*3  + ans_cnt];
            answer_data[4] <= answer[25*4  + ans_cnt];
            answer_data[5] <= answer[25*5  + ans_cnt];
            answer_data[6] <= answer[25*6  + ans_cnt];
            answer_data[7] <= answer[25*7  + ans_cnt];
            answer_data[8] <= answer[25*8  + ans_cnt];
            answer_data[9] <= answer[25*9  + ans_cnt];
            answer_data[10] <= answer[25*10  + ans_cnt];
            answer_data[11] <= answer[25*11  + ans_cnt];
            answer_data[12] <= answer[25*12  + ans_cnt];
            answer_data[13] <= answer[25*13  + ans_cnt];
            answer_data[14] <= answer[25*14  + ans_cnt];
            answer_data[15] <= answer[25*15  + ans_cnt];
        end
    end
    

    
	c3_controller c3_controller_dut(
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
	
    
    
	always #5 clk = ~clk;
	
	initial begin
		$readmemh("C:/Users/khmga/Desktop/c3_Controller/tb/cnn_outputs_2/input.txt", mem_c1_mp_data);
		$readmemh("C:/Users/khmga/Desktop/c3_Controller/tb/cnn_outputs_2/mp_out.txt", answer);
		clk = 0;
		rst_n = 0;
		#10;
		rst_n = 1;
		#65;
		start = 1;
	end

endmodule