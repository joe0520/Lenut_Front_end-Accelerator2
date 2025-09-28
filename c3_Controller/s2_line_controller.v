`timescale 1ns / 1ps

module s2_line_controller (
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
    output reg s2_valid,
    output reg [239:0] s2_data_0,
    output reg [239:0] s2_data_1,
    output reg [239:0] s2_data_2
);
    localparam read_0 = 3'd0;
    localparam read_1 = 3'd1;
    localparam read_2 = 3'd2;
    localparam read_3 = 3'd3;
    localparam read_4 = 3'd4;
    localparam read_5 = 3'd5;

    localparam write_first = 3'd0;
    localparam write_0 = 3'd1;
    localparam write_1 = 3'd2;
    localparam write_2 = 3'd3;
    localparam write_3 = 3'd4;
    localparam write_4 = 3'd5;
    localparam write_5 = 3'd6;

    reg [7:0] s2_ch0_line[0:5][0:13];
    reg [7:0] s2_ch1_line[0:5][0:13];
    reg [7:0] s2_ch2_line[0:5][0:13];
    reg [7:0] s2_ch3_line[0:5][0:13];
    reg [7:0] s2_ch4_line[0:5][0:13];
    reg [7:0] s2_ch5_line[0:5][0:13];

    integer i;
    integer j;

    reg [2:0] r_c_state;
    reg [2:0] r_n_state;
    reg [3:0] r_cnt;

    reg [2:0] w_c_state;
    reg [2:0] w_n_state;
    reg [2:0] w_cnt; //0-5 , 2-7, 4-9, 6-11, 8-13
    reg [3:0] w_repeat_cnt; //0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    reg filter_cnt;// 0-2, 3-5


    //READ
    always@(posedge clk)begin
        if(!rst_n)begin
            r_c_state <= read_0;
            r_cnt <= 0;
        end else if (is_done) begin
            r_c_state <= read_0;
            r_cnt <= 0;
        end else begin
            r_c_state <= r_n_state;
            if(r_cnt ==13 & c1_mp_valid)begin
                r_cnt <= 0;
            end else if(c1_mp_valid) begin
                r_cnt <= r_cnt + 1;
            end
        end
    end

    always@(*)begin
        r_n_state = r_c_state;
        case(r_c_state)
            read_0 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_1;
            end
            read_1 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_2;
            end
            read_2 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_3;
            end
            read_3 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_4;
            end
            read_4 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_5;
            end
            read_5 : begin
                if(r_cnt ==13 & c1_mp_valid) r_n_state = read_0;
            end
        endcase
    end

    always@(posedge clk)begin
        if(!rst_n)begin
            for(i=0; i<6; i=i+1)begin
                for(j=0; j<14; j=j+1)begin
                    s2_ch0_line[i][j] <= 0;
                    s2_ch1_line[i][j] <= 0;
                    s2_ch2_line[i][j] <= 0;
                    s2_ch3_line[i][j] <= 0;
                    s2_ch4_line[i][j] <= 0;
                    s2_ch5_line[i][j] <= 0;
                end
            end
        end else begin
            case(r_c_state)
                read_0:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[0][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[0][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[0][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[0][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[0][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[0][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
                read_1:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[1][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[1][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[1][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[1][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[1][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[1][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
                read_2:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[2][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[2][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[2][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[2][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[2][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[2][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
                read_3:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[3][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[3][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[3][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[3][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[3][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[3][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
                read_4:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[4][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[4][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[4][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[4][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[4][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[4][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
                read_5:begin
                    if(c1_mp_valid)begin
                        s2_ch0_line[5][r_cnt] <= c1_mp_data_ch_0;
                        s2_ch1_line[5][r_cnt] <= c1_mp_data_ch_1;
                        s2_ch2_line[5][r_cnt] <= c1_mp_data_ch_2;
                        s2_ch3_line[5][r_cnt] <= c1_mp_data_ch_3;
                        s2_ch4_line[5][r_cnt] <= c1_mp_data_ch_4;
                        s2_ch5_line[5][r_cnt] <= c1_mp_data_ch_5;
                    end 
                end
            endcase
        end
    end

    //WRITE
    always@(posedge clk)begin
        if(!rst_n)begin
            w_c_state <= write_first;
        end else if(is_done) begin
            w_c_state <= write_first;
        end else begin
            w_c_state <= w_n_state;
        end
    end

    always@(*)begin
        w_n_state = w_c_state;
        case(w_c_state)
            write_first : begin
                if((r_c_state == read_4) & r_cnt == 13) w_n_state = write_0;
            end
            write_0 : begin
                if((r_c_state == read_5) & r_cnt == 13) w_n_state = write_1;
            end
            write_1 : begin
                if((r_c_state == read_0) & r_cnt == 13) w_n_state = write_2;
            end
            write_2 : begin
                if((r_c_state == read_1) & r_cnt == 13) w_n_state = write_3;
            end
            write_3 : begin
                if((r_c_state == read_2) & r_cnt == 13) w_n_state = write_4;
            end
            write_4 : begin
                if((r_c_state == read_3) & r_cnt == 13) w_n_state = write_5;
            end
            write_5 : begin
                if((r_c_state == read_4) & r_cnt == 13) w_n_state = write_0;
            end
        endcase
    end

    always@(posedge clk)begin
        if(!rst_n)begin
            w_cnt <= 0;
            w_repeat_cnt <= 0;
            filter_cnt <= 0;
        end else if(w_cnt == 5 & (w_c_state != w_n_state)) begin //maybe timing violation?
            w_cnt <= 0;
            w_repeat_cnt <= 0;
            filter_cnt <= 0;
        end else if(w_cnt != 5 & (w_c_state != write_first))begin
            //w_cnt
            if((w_repeat_cnt == 15) & filter_cnt)begin
            w_cnt <= w_cnt + 1;
            end
            //w_repeat_cnt
            if(filter_cnt)begin
                w_repeat_cnt <= w_repeat_cnt + 1;
            end
            //filter_cnt
            filter_cnt <= ~filter_cnt;
        end
    end

    always@(posedge clk)begin
        if(!rst_n)begin
            s2_valid <= 0;
            s2_data_0 <= 0;
            s2_data_1 <= 0;
            s2_data_2 <= 0;
        end else if(w_cnt != 5)begin
            if(w_c_state != write_first) s2_valid <= 1;
            else s2_valid <= 0;
            case(w_c_state)
                write_0 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[0][0],s2_ch3_line[0][1],s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5]
                                                ,s2_ch3_line[1][0],s2_ch3_line[1][1],s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5]
                                                ,s2_ch3_line[2][0],s2_ch3_line[2][1],s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5]
                                                ,s2_ch3_line[3][0],s2_ch3_line[3][1],s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5]
                                                ,s2_ch3_line[4][0],s2_ch3_line[4][1],s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[0][0],s2_ch4_line[0][1],s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5]
                                                ,s2_ch4_line[1][0],s2_ch4_line[1][1],s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5]
                                                ,s2_ch4_line[2][0],s2_ch4_line[2][1],s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5]
                                                ,s2_ch4_line[3][0],s2_ch4_line[3][1],s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5]
                                                ,s2_ch4_line[4][0],s2_ch4_line[4][1],s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[0][0],s2_ch5_line[0][1],s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5]
                                                ,s2_ch5_line[1][0],s2_ch5_line[1][1],s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5]
                                                ,s2_ch5_line[2][0],s2_ch5_line[2][1],s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5]
                                                ,s2_ch5_line[3][0],s2_ch5_line[3][1],s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5]
                                                ,s2_ch5_line[4][0],s2_ch5_line[4][1],s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[0][0],s2_ch0_line[0][1],s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5]
                                                ,s2_ch0_line[1][0],s2_ch0_line[1][1],s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5]
                                                ,s2_ch0_line[2][0],s2_ch0_line[2][1],s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5]
                                                ,s2_ch0_line[3][0],s2_ch0_line[3][1],s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5]
                                                ,s2_ch0_line[4][0],s2_ch0_line[4][1],s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[0][0],s2_ch1_line[0][1],s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5]
                                                ,s2_ch1_line[1][0],s2_ch1_line[1][1],s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5]
                                                ,s2_ch1_line[2][0],s2_ch1_line[2][1],s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5]
                                                ,s2_ch1_line[3][0],s2_ch1_line[3][1],s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5]
                                                ,s2_ch1_line[4][0],s2_ch1_line[4][1],s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[0][0],s2_ch2_line[0][1],s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5]
                                                ,s2_ch2_line[1][0],s2_ch2_line[1][1],s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5]
                                                ,s2_ch2_line[2][0],s2_ch2_line[2][1],s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5]
                                                ,s2_ch2_line[3][0],s2_ch2_line[3][1],s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5]
                                                ,s2_ch2_line[4][0],s2_ch2_line[4][1],s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7]
                                                ,s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7]
                                                ,s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7]
                                                ,s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7]
                                                ,s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7]
                                                ,s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7]
                                                ,s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7]
                                                ,s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7]
                                                ,s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7]
                                                ,s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7]
                                                ,s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7]
                                                ,s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7]
                                                ,s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7]
                                                ,s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7]
                                                ,s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7]
                                                ,s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7]
                                                ,s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7]
                                                ,s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7]
                                                ,s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7]
                                                ,s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7]
                                                ,s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7]
                                                ,s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7]
                                                ,s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7]
                                                ,s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7]
                                                ,s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9]
                                                ,s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9]
                                                ,s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9]
                                                ,s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9]
                                                ,s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9]
                                                ,s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9]
                                                ,s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9]
                                                ,s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9]
                                                ,s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9]
                                                ,s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9]
                                                ,s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9]
                                                ,s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9]
                                                ,s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9]
                                                ,s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9]
                                                ,s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9]
                                                ,s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9]
                                                ,s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9]
                                                ,s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9]
                                                ,s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9]
                                                ,s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9]
                                                ,s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9]
                                                ,s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9]
                                                ,s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9]
                                                ,s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9]
                                                ,s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11]
                                                ,s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11]
                                                ,s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11]
                                                ,s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11]
                                                ,s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11]
                                                ,s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11]
                                                ,s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11]
                                                ,s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11]
                                                ,s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11]
                                                ,s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11]
                                                ,s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11]
                                                ,s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11]
                                                ,s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11]
                                                ,s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11]
                                                ,s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11]
                                                ,s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11]
                                                ,s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11]
                                                ,s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11]
                                                ,s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11]
                                                ,s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11]
                                                ,s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11]
                                                ,s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11]
                                                ,s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11]
                                                ,s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11]
                                                ,s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11],s2_ch3_line[0][12],s2_ch3_line[0][13]
                                                ,s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11],s2_ch3_line[1][12],s2_ch3_line[1][13]
                                                ,s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11],s2_ch3_line[2][12],s2_ch3_line[2][13]
                                                ,s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11],s2_ch3_line[3][12],s2_ch3_line[3][13]
                                                ,s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11],s2_ch3_line[4][12],s2_ch3_line[4][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11],s2_ch4_line[0][12],s2_ch4_line[0][13]
                                                ,s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11],s2_ch4_line[1][12],s2_ch4_line[1][13]
                                                ,s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11],s2_ch4_line[2][12],s2_ch4_line[2][13]
                                                ,s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11],s2_ch4_line[3][12],s2_ch4_line[3][13]
                                                ,s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11],s2_ch4_line[4][12],s2_ch4_line[4][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11],s2_ch5_line[0][12],s2_ch5_line[0][13]
                                                ,s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11],s2_ch5_line[1][12],s2_ch5_line[1][13]
                                                ,s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11],s2_ch5_line[2][12],s2_ch5_line[2][13]
                                                ,s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11],s2_ch5_line[3][12],s2_ch5_line[3][13]
                                                ,s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11],s2_ch5_line[4][12],s2_ch5_line[4][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11],s2_ch0_line[0][12],s2_ch0_line[0][13]
                                                ,s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11],s2_ch0_line[1][12],s2_ch0_line[1][13]
                                                ,s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11],s2_ch0_line[2][12],s2_ch0_line[2][13]
                                                ,s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11],s2_ch0_line[3][12],s2_ch0_line[3][13]
                                                ,s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11],s2_ch0_line[4][12],s2_ch0_line[4][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11],s2_ch1_line[0][12],s2_ch1_line[0][13]
                                                ,s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11],s2_ch1_line[1][12],s2_ch1_line[1][13]
                                                ,s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11],s2_ch1_line[2][12],s2_ch1_line[2][13]
                                                ,s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11],s2_ch1_line[3][12],s2_ch1_line[3][13]
                                                ,s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11],s2_ch1_line[4][12],s2_ch1_line[4][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11],s2_ch2_line[0][12],s2_ch2_line[0][13]
                                                ,s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11],s2_ch2_line[1][12],s2_ch2_line[1][13]
                                                ,s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11],s2_ch2_line[2][12],s2_ch2_line[2][13]
                                                ,s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11],s2_ch2_line[3][12],s2_ch2_line[3][13]
                                                ,s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11],s2_ch2_line[4][12],s2_ch2_line[4][13]
                                                };
                            end
                        end
                    endcase
                end
                write_1 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[1][0],s2_ch3_line[1][1],s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5]
                                                ,s2_ch3_line[2][0],s2_ch3_line[2][1],s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5]
                                                ,s2_ch3_line[3][0],s2_ch3_line[3][1],s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5]
                                                ,s2_ch3_line[4][0],s2_ch3_line[4][1],s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5]
                                                ,s2_ch3_line[5][0],s2_ch3_line[5][1],s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[1][0],s2_ch4_line[1][1],s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5]
                                                ,s2_ch4_line[2][0],s2_ch4_line[2][1],s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5]
                                                ,s2_ch4_line[3][0],s2_ch4_line[3][1],s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5]
                                                ,s2_ch4_line[4][0],s2_ch4_line[4][1],s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5]
                                                ,s2_ch4_line[5][0],s2_ch4_line[5][1],s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[1][0],s2_ch5_line[1][1],s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5]
                                                ,s2_ch5_line[2][0],s2_ch5_line[2][1],s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5]
                                                ,s2_ch5_line[3][0],s2_ch5_line[3][1],s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5]
                                                ,s2_ch5_line[4][0],s2_ch5_line[4][1],s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5]
                                                ,s2_ch5_line[5][0],s2_ch5_line[5][1],s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[1][0],s2_ch0_line[1][1],s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5]
                                                ,s2_ch0_line[2][0],s2_ch0_line[2][1],s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5]
                                                ,s2_ch0_line[3][0],s2_ch0_line[3][1],s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5]
                                                ,s2_ch0_line[4][0],s2_ch0_line[4][1],s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5]
                                                ,s2_ch0_line[5][0],s2_ch0_line[5][1],s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[1][0],s2_ch1_line[1][1],s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5]
                                                ,s2_ch1_line[2][0],s2_ch1_line[2][1],s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5]
                                                ,s2_ch1_line[3][0],s2_ch1_line[3][1],s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5]
                                                ,s2_ch1_line[4][0],s2_ch1_line[4][1],s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5]
                                                ,s2_ch1_line[5][0],s2_ch1_line[5][1],s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[1][0],s2_ch2_line[1][1],s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5]
                                                ,s2_ch2_line[2][0],s2_ch2_line[2][1],s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5]
                                                ,s2_ch2_line[3][0],s2_ch2_line[3][1],s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5]
                                                ,s2_ch2_line[4][0],s2_ch2_line[4][1],s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5]
                                                ,s2_ch2_line[5][0],s2_ch2_line[5][1],s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7]
                                                ,s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7]
                                                ,s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7]
                                                ,s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7]
                                                ,s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7]
                                                ,s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7]
                                                ,s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7]
                                                ,s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7]
                                                ,s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7]
                                                ,s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7]
                                                ,s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7]
                                                ,s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7]
                                                ,s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7]
                                                ,s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7]
                                                ,s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7]
                                                ,s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7]
                                                ,s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7]
                                                ,s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7]
                                                ,s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7]
                                                ,s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7]
                                                ,s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7]
                                                ,s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7]
                                                ,s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7]
                                                ,s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7]
                                                ,s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9]
                                                ,s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9]
                                                ,s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9]
                                                ,s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9]
                                                ,s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9]
                                                ,s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9]
                                                ,s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9]
                                                ,s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9]
                                                ,s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9]
                                                ,s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9]
                                                ,s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9]
                                                ,s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9]
                                                ,s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9]
                                                ,s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9]
                                                ,s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9]
                                                ,s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9]
                                                ,s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9]
                                                ,s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9]
                                                ,s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9]
                                                ,s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9]
                                                ,s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9]
                                                ,s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9]
                                                ,s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9]
                                                ,s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9]
                                                ,s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11]
                                                ,s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11]
                                                ,s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11]
                                                ,s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11]
                                                ,s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11]
                                                ,s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11]
                                                ,s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11]
                                                ,s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11]
                                                ,s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11]
                                                ,s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11]
                                                ,s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11]
                                                ,s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11]
                                                ,s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11]
                                                ,s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11]
                                                ,s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11]
                                                ,s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11]
                                                ,s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11]
                                                ,s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11]
                                                ,s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11]
                                                ,s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11]
                                                ,s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11]
                                                ,s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11]
                                                ,s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11]
                                                ,s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11]
                                                ,s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11],s2_ch3_line[1][12],s2_ch3_line[1][13]
                                                ,s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11],s2_ch3_line[2][12],s2_ch3_line[2][13]
                                                ,s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11],s2_ch3_line[3][12],s2_ch3_line[3][13]
                                                ,s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11],s2_ch3_line[4][12],s2_ch3_line[4][13]
                                                ,s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11],s2_ch3_line[5][12],s2_ch3_line[5][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11],s2_ch4_line[1][12],s2_ch4_line[1][13]
                                                ,s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11],s2_ch4_line[2][12],s2_ch4_line[2][13]
                                                ,s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11],s2_ch4_line[3][12],s2_ch4_line[3][13]
                                                ,s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11],s2_ch4_line[4][12],s2_ch4_line[4][13]
                                                ,s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11],s2_ch4_line[5][12],s2_ch4_line[5][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11],s2_ch5_line[1][12],s2_ch5_line[1][13]
                                                ,s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11],s2_ch5_line[2][12],s2_ch5_line[2][13]
                                                ,s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11],s2_ch5_line[3][12],s2_ch5_line[3][13]
                                                ,s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11],s2_ch5_line[4][12],s2_ch5_line[4][13]
                                                ,s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11],s2_ch5_line[5][12],s2_ch5_line[5][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11],s2_ch0_line[1][12],s2_ch0_line[1][13]
                                                ,s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11],s2_ch0_line[2][12],s2_ch0_line[2][13]
                                                ,s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11],s2_ch0_line[3][12],s2_ch0_line[3][13]
                                                ,s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11],s2_ch0_line[4][12],s2_ch0_line[4][13]
                                                ,s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11],s2_ch0_line[5][12],s2_ch0_line[5][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11],s2_ch1_line[1][12],s2_ch1_line[1][13]
                                                ,s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11],s2_ch1_line[2][12],s2_ch1_line[2][13]
                                                ,s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11],s2_ch1_line[3][12],s2_ch1_line[3][13]
                                                ,s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11],s2_ch1_line[4][12],s2_ch1_line[4][13]
                                                ,s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11],s2_ch1_line[5][12],s2_ch1_line[5][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11],s2_ch2_line[1][12],s2_ch2_line[1][13]
                                                ,s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11],s2_ch2_line[2][12],s2_ch2_line[2][13]
                                                ,s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11],s2_ch2_line[3][12],s2_ch2_line[3][13]
                                                ,s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11],s2_ch2_line[4][12],s2_ch2_line[4][13]
                                                ,s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11],s2_ch2_line[5][12],s2_ch2_line[5][13]
                                                };
                            end
                        end
                    endcase
                end
                write_2 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[2][0],s2_ch3_line[2][1],s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5]
                                                ,s2_ch3_line[3][0],s2_ch3_line[3][1],s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5]
                                                ,s2_ch3_line[4][0],s2_ch3_line[4][1],s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5]
                                                ,s2_ch3_line[5][0],s2_ch3_line[5][1],s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5]
                                                ,s2_ch3_line[0][0],s2_ch3_line[0][1],s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[2][0],s2_ch4_line[2][1],s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5]
                                                ,s2_ch4_line[3][0],s2_ch4_line[3][1],s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5]
                                                ,s2_ch4_line[4][0],s2_ch4_line[4][1],s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5]
                                                ,s2_ch4_line[5][0],s2_ch4_line[5][1],s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5]
                                                ,s2_ch4_line[0][0],s2_ch4_line[0][1],s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[2][0],s2_ch5_line[2][1],s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5]
                                                ,s2_ch5_line[3][0],s2_ch5_line[3][1],s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5]
                                                ,s2_ch5_line[4][0],s2_ch5_line[4][1],s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5]
                                                ,s2_ch5_line[5][0],s2_ch5_line[5][1],s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5]
                                                ,s2_ch5_line[0][0],s2_ch5_line[0][1],s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[2][0],s2_ch0_line[2][1],s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5]
                                                ,s2_ch0_line[3][0],s2_ch0_line[3][1],s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5]
                                                ,s2_ch0_line[4][0],s2_ch0_line[4][1],s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5]
                                                ,s2_ch0_line[5][0],s2_ch0_line[5][1],s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5]
                                                ,s2_ch0_line[0][0],s2_ch0_line[0][1],s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[2][0],s2_ch1_line[2][1],s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5]
                                                ,s2_ch1_line[3][0],s2_ch1_line[3][1],s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5]
                                                ,s2_ch1_line[4][0],s2_ch1_line[4][1],s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5]
                                                ,s2_ch1_line[5][0],s2_ch1_line[5][1],s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5]
                                                ,s2_ch1_line[0][0],s2_ch1_line[0][1],s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[2][0],s2_ch2_line[2][1],s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5]
                                                ,s2_ch2_line[3][0],s2_ch2_line[3][1],s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5]
                                                ,s2_ch2_line[4][0],s2_ch2_line[4][1],s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5]
                                                ,s2_ch2_line[5][0],s2_ch2_line[5][1],s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5]
                                                ,s2_ch2_line[0][0],s2_ch2_line[0][1],s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7]
                                                ,s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7]
                                                ,s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7]
                                                ,s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7]
                                                ,s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7]
                                                ,s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7]
                                                ,s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7]
                                                ,s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7]
                                                ,s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7]
                                                ,s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7]
                                                ,s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7]
                                                ,s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7]
                                                ,s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7]
                                                ,s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7]
                                                ,s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7]
                                                ,s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7]
                                                ,s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7]
                                                ,s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7]
                                                ,s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7]
                                                ,s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7]
                                                ,s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7]
                                                ,s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7]
                                                ,s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7]
                                                ,s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7]
                                                ,s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9]
                                                ,s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9]
                                                ,s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9]
                                                ,s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9]
                                                ,s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9]
                                                ,s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9]
                                                ,s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9]
                                                ,s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9]
                                                ,s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9]
                                                ,s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9]
                                                ,s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9]
                                                ,s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9]
                                                ,s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9]
                                                ,s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9]
                                                ,s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9]
                                                ,s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9]
                                                ,s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9]
                                                ,s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9]
                                                ,s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9]
                                                ,s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9]
                                                ,s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9]
                                                ,s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9]
                                                ,s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9]
                                                ,s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9]
                                                ,s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11]
                                                ,s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11]
                                                ,s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11]
                                                ,s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11]
                                                ,s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11]
                                                ,s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11]
                                                ,s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11]
                                                ,s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11]
                                                ,s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11]
                                                ,s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11]
                                                ,s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11]
                                                ,s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11]
                                                ,s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11]
                                                ,s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11]
                                                ,s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11]
                                                ,s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11]
                                                ,s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11]
                                                ,s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11]
                                                ,s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11]
                                                ,s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11]
                                                ,s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11]
                                                ,s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11]
                                                ,s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11]
                                                ,s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11]
                                                ,s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11],s2_ch3_line[2][12],s2_ch3_line[2][13]
                                                ,s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11],s2_ch3_line[3][12],s2_ch3_line[3][13]
                                                ,s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11],s2_ch3_line[4][12],s2_ch3_line[4][13]
                                                ,s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11],s2_ch3_line[5][12],s2_ch3_line[5][13]
                                                ,s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11],s2_ch3_line[0][12],s2_ch3_line[0][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11],s2_ch4_line[2][12],s2_ch4_line[2][13]
                                                ,s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11],s2_ch4_line[3][12],s2_ch4_line[3][13]
                                                ,s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11],s2_ch4_line[4][12],s2_ch4_line[4][13]
                                                ,s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11],s2_ch4_line[5][12],s2_ch4_line[5][13]
                                                ,s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11],s2_ch4_line[0][12],s2_ch4_line[0][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11],s2_ch5_line[2][12],s2_ch5_line[2][13]
                                                ,s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11],s2_ch5_line[3][12],s2_ch5_line[3][13]
                                                ,s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11],s2_ch5_line[4][12],s2_ch5_line[4][13]
                                                ,s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11],s2_ch5_line[5][12],s2_ch5_line[5][13]
                                                ,s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11],s2_ch5_line[0][12],s2_ch5_line[0][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11],s2_ch0_line[2][12],s2_ch0_line[2][13]
                                                ,s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11],s2_ch0_line[3][12],s2_ch0_line[3][13]
                                                ,s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11],s2_ch0_line[4][12],s2_ch0_line[4][13]
                                                ,s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11],s2_ch0_line[5][12],s2_ch0_line[5][13]
                                                ,s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11],s2_ch0_line[0][12],s2_ch0_line[0][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11],s2_ch1_line[2][12],s2_ch1_line[2][13]
                                                ,s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11],s2_ch1_line[3][12],s2_ch1_line[3][13]
                                                ,s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11],s2_ch1_line[4][12],s2_ch1_line[4][13]
                                                ,s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11],s2_ch1_line[5][12],s2_ch1_line[5][13]
                                                ,s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11],s2_ch1_line[0][12],s2_ch1_line[0][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11],s2_ch2_line[2][12],s2_ch2_line[2][13]
                                                ,s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11],s2_ch2_line[3][12],s2_ch2_line[3][13]
                                                ,s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11],s2_ch2_line[4][12],s2_ch2_line[4][13]
                                                ,s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11],s2_ch2_line[5][12],s2_ch2_line[5][13]
                                                ,s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11],s2_ch2_line[0][12],s2_ch2_line[0][13]
                                                };
                            end
                        end
                    endcase
                end
                write_3 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[3][0],s2_ch3_line[3][1],s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5]
                                                ,s2_ch3_line[4][0],s2_ch3_line[4][1],s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5]
                                                ,s2_ch3_line[5][0],s2_ch3_line[5][1],s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5]
                                                ,s2_ch3_line[0][0],s2_ch3_line[0][1],s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5]
                                                ,s2_ch3_line[1][0],s2_ch3_line[1][1],s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[3][0],s2_ch4_line[3][1],s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5]
                                                ,s2_ch4_line[4][0],s2_ch4_line[4][1],s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5]
                                                ,s2_ch4_line[5][0],s2_ch4_line[5][1],s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5]
                                                ,s2_ch4_line[0][0],s2_ch4_line[0][1],s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5]
                                                ,s2_ch4_line[1][0],s2_ch4_line[1][1],s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[3][0],s2_ch5_line[3][1],s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5]
                                                ,s2_ch5_line[4][0],s2_ch5_line[4][1],s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5]
                                                ,s2_ch5_line[5][0],s2_ch5_line[5][1],s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5]
                                                ,s2_ch5_line[0][0],s2_ch5_line[0][1],s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5]
                                                ,s2_ch5_line[1][0],s2_ch5_line[1][1],s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[3][0],s2_ch0_line[3][1],s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5]
                                                ,s2_ch0_line[4][0],s2_ch0_line[4][1],s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5]
                                                ,s2_ch0_line[5][0],s2_ch0_line[5][1],s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5]
                                                ,s2_ch0_line[0][0],s2_ch0_line[0][1],s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5]
                                                ,s2_ch0_line[1][0],s2_ch0_line[1][1],s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[3][0],s2_ch1_line[3][1],s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5]
                                                ,s2_ch1_line[4][0],s2_ch1_line[4][1],s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5]
                                                ,s2_ch1_line[5][0],s2_ch1_line[5][1],s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5]
                                                ,s2_ch1_line[0][0],s2_ch1_line[0][1],s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5]
                                                ,s2_ch1_line[1][0],s2_ch1_line[1][1],s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[3][0],s2_ch2_line[3][1],s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5]
                                                ,s2_ch2_line[4][0],s2_ch2_line[4][1],s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5]
                                                ,s2_ch2_line[5][0],s2_ch2_line[5][1],s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5]
                                                ,s2_ch2_line[0][0],s2_ch2_line[0][1],s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5]
                                                ,s2_ch2_line[1][0],s2_ch2_line[1][1],s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7]
                                                ,s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7]
                                                ,s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7]
                                                ,s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7]
                                                ,s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7]
                                                ,s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7]
                                                ,s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7]
                                                ,s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7]
                                                ,s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7]
                                                ,s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7]
                                                ,s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7]
                                                ,s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7]
                                                ,s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7]
                                                ,s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7]
                                                ,s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7]
                                                ,s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7]
                                                ,s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7]
                                                ,s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7]
                                                ,s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7]
                                                ,s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7]
                                                ,s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7]
                                                ,s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7]
                                                ,s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7]
                                                ,s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7]
                                                ,s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9]
                                                ,s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9]
                                                ,s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9]
                                                ,s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9]
                                                ,s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9]
                                                ,s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9]
                                                ,s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9]
                                                ,s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9]
                                                ,s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9]
                                                ,s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9]
                                                ,s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9]
                                                ,s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9]
                                                ,s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9]
                                                ,s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9]
                                                ,s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9]
                                                ,s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9]
                                                ,s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9]
                                                ,s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9]
                                                ,s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9]
                                                ,s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9]
                                                ,s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9]
                                                ,s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9]
                                                ,s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9]
                                                ,s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9]
                                                ,s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11]
                                                ,s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11]
                                                ,s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11]
                                                ,s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11]
                                                ,s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11]
                                                ,s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11]
                                                ,s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11]
                                                ,s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11]
                                                ,s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11]
                                                ,s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11]
                                                ,s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11]
                                                ,s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11]
                                                ,s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11]
                                                ,s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11]
                                                ,s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11]
                                                ,s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11]
                                                ,s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11]
                                                ,s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11]
                                                ,s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11]
                                                ,s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11]
                                                ,s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11]
                                                ,s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11]
                                                ,s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11]
                                                ,s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11]
                                                ,s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11],s2_ch3_line[3][12],s2_ch3_line[3][13]
                                                ,s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11],s2_ch3_line[4][12],s2_ch3_line[4][13]
                                                ,s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11],s2_ch3_line[5][12],s2_ch3_line[5][13]
                                                ,s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11],s2_ch3_line[0][12],s2_ch3_line[0][13]
                                                ,s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11],s2_ch3_line[1][12],s2_ch3_line[1][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11],s2_ch4_line[3][12],s2_ch4_line[3][13]
                                                ,s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11],s2_ch4_line[4][12],s2_ch4_line[4][13]
                                                ,s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11],s2_ch4_line[5][12],s2_ch4_line[5][13]
                                                ,s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11],s2_ch4_line[0][12],s2_ch4_line[0][13]
                                                ,s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11],s2_ch4_line[1][12],s2_ch4_line[1][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11],s2_ch5_line[3][12],s2_ch5_line[3][13]
                                                ,s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11],s2_ch5_line[4][12],s2_ch5_line[4][13]
                                                ,s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11],s2_ch5_line[5][12],s2_ch5_line[5][13]
                                                ,s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11],s2_ch5_line[0][12],s2_ch5_line[0][13]
                                                ,s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11],s2_ch5_line[1][12],s2_ch5_line[1][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11],s2_ch0_line[3][12],s2_ch0_line[3][13]
                                                ,s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11],s2_ch0_line[4][12],s2_ch0_line[4][13]
                                                ,s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11],s2_ch0_line[5][12],s2_ch0_line[5][13]
                                                ,s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11],s2_ch0_line[0][12],s2_ch0_line[0][13]
                                                ,s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11],s2_ch0_line[1][12],s2_ch0_line[1][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11],s2_ch1_line[3][12],s2_ch1_line[3][13]
                                                ,s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11],s2_ch1_line[4][12],s2_ch1_line[4][13]
                                                ,s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11],s2_ch1_line[5][12],s2_ch1_line[5][13]
                                                ,s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11],s2_ch1_line[0][12],s2_ch1_line[0][13]
                                                ,s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11],s2_ch1_line[1][12],s2_ch1_line[1][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11],s2_ch2_line[3][12],s2_ch2_line[3][13]
                                                ,s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11],s2_ch2_line[4][12],s2_ch2_line[4][13]
                                                ,s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11],s2_ch2_line[5][12],s2_ch2_line[5][13]
                                                ,s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11],s2_ch2_line[0][12],s2_ch2_line[0][13]
                                                ,s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11],s2_ch2_line[1][12],s2_ch2_line[1][13]
                                                };
                            end
                        end
                    endcase
                end
                write_4 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[4][0],s2_ch3_line[4][1],s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5]
                                                ,s2_ch3_line[5][0],s2_ch3_line[5][1],s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5]
                                                ,s2_ch3_line[0][0],s2_ch3_line[0][1],s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5]
                                                ,s2_ch3_line[1][0],s2_ch3_line[1][1],s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5]
                                                ,s2_ch3_line[2][0],s2_ch3_line[2][1],s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[4][0],s2_ch4_line[4][1],s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5]
                                                ,s2_ch4_line[5][0],s2_ch4_line[5][1],s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5]
                                                ,s2_ch4_line[0][0],s2_ch4_line[0][1],s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5]
                                                ,s2_ch4_line[1][0],s2_ch4_line[1][1],s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5]
                                                ,s2_ch4_line[2][0],s2_ch4_line[2][1],s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[4][0],s2_ch5_line[4][1],s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5]
                                                ,s2_ch5_line[5][0],s2_ch5_line[5][1],s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5]
                                                ,s2_ch5_line[0][0],s2_ch5_line[0][1],s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5]
                                                ,s2_ch5_line[1][0],s2_ch5_line[1][1],s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5]
                                                ,s2_ch5_line[2][0],s2_ch5_line[2][1],s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[4][0],s2_ch0_line[4][1],s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5]
                                                ,s2_ch0_line[5][0],s2_ch0_line[5][1],s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5]
                                                ,s2_ch0_line[0][0],s2_ch0_line[0][1],s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5]
                                                ,s2_ch0_line[1][0],s2_ch0_line[1][1],s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5]
                                                ,s2_ch0_line[2][0],s2_ch0_line[2][1],s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[4][0],s2_ch1_line[4][1],s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5]
                                                ,s2_ch1_line[5][0],s2_ch1_line[5][1],s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5]
                                                ,s2_ch1_line[0][0],s2_ch1_line[0][1],s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5]
                                                ,s2_ch1_line[1][0],s2_ch1_line[1][1],s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5]
                                                ,s2_ch1_line[2][0],s2_ch1_line[2][1],s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[4][0],s2_ch2_line[4][1],s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5]
                                                ,s2_ch2_line[5][0],s2_ch2_line[5][1],s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5]
                                                ,s2_ch2_line[0][0],s2_ch2_line[0][1],s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5]
                                                ,s2_ch2_line[1][0],s2_ch2_line[1][1],s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5]
                                                ,s2_ch2_line[2][0],s2_ch2_line[2][1],s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[4][2],s2_ch3_line[4][3],s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7]
                                                ,s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7]
                                                ,s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7]
                                                ,s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7]
                                                ,s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[4][2],s2_ch4_line[4][3],s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7]
                                                ,s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7]
                                                ,s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7]
                                                ,s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7]
                                                ,s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[4][2],s2_ch5_line[4][3],s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7]
                                                ,s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7]
                                                ,s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7]
                                                ,s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7]
                                                ,s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[4][2],s2_ch0_line[4][3],s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7]
                                                ,s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7]
                                                ,s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7]
                                                ,s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7]
                                                ,s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[4][2],s2_ch1_line[4][3],s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7]
                                                ,s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7]
                                                ,s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7]
                                                ,s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7]
                                                ,s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[4][2],s2_ch2_line[4][3],s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7]
                                                ,s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7]
                                                ,s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7]
                                                ,s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7]
                                                ,s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[4][4],s2_ch3_line[4][5],s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9]
                                                ,s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9]
                                                ,s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9]
                                                ,s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9]
                                                ,s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[4][4],s2_ch4_line[4][5],s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9]
                                                ,s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9]
                                                ,s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9]
                                                ,s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9]
                                                ,s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[4][4],s2_ch5_line[4][5],s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9]
                                                ,s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9]
                                                ,s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9]
                                                ,s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9]
                                                ,s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[4][4],s2_ch0_line[4][5],s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9]
                                                ,s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9]
                                                ,s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9]
                                                ,s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9]
                                                ,s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[4][4],s2_ch1_line[4][5],s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9]
                                                ,s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9]
                                                ,s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9]
                                                ,s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9]
                                                ,s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[4][4],s2_ch2_line[4][5],s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9]
                                                ,s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9]
                                                ,s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9]
                                                ,s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9]
                                                ,s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[4][6],s2_ch3_line[4][7],s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11]
                                                ,s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11]
                                                ,s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11]
                                                ,s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11]
                                                ,s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[4][6],s2_ch4_line[4][7],s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11]
                                                ,s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11]
                                                ,s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11]
                                                ,s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11]
                                                ,s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[4][6],s2_ch5_line[4][7],s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11]
                                                ,s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11]
                                                ,s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11]
                                                ,s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11]
                                                ,s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[4][6],s2_ch0_line[4][7],s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11]
                                                ,s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11]
                                                ,s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11]
                                                ,s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11]
                                                ,s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[4][6],s2_ch1_line[4][7],s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11]
                                                ,s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11]
                                                ,s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11]
                                                ,s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11]
                                                ,s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[4][6],s2_ch2_line[4][7],s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11]
                                                ,s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11]
                                                ,s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11]
                                                ,s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11]
                                                ,s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[4][8],s2_ch3_line[4][9],s2_ch3_line[4][10],s2_ch3_line[4][11],s2_ch3_line[4][12],s2_ch3_line[4][13]
                                                ,s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11],s2_ch3_line[5][12],s2_ch3_line[5][13]
                                                ,s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11],s2_ch3_line[0][12],s2_ch3_line[0][13]
                                                ,s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11],s2_ch3_line[1][12],s2_ch3_line[1][13]
                                                ,s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11],s2_ch3_line[2][12],s2_ch3_line[2][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[4][8],s2_ch4_line[4][9],s2_ch4_line[4][10],s2_ch4_line[4][11],s2_ch4_line[4][12],s2_ch4_line[4][13]
                                                ,s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11],s2_ch4_line[5][12],s2_ch4_line[5][13]
                                                ,s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11],s2_ch4_line[0][12],s2_ch4_line[0][13]
                                                ,s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11],s2_ch4_line[1][12],s2_ch4_line[1][13]
                                                ,s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11],s2_ch4_line[2][12],s2_ch4_line[2][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[4][8],s2_ch5_line[4][9],s2_ch5_line[4][10],s2_ch5_line[4][11],s2_ch5_line[4][12],s2_ch5_line[4][13]
                                                ,s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11],s2_ch5_line[5][12],s2_ch5_line[5][13]
                                                ,s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11],s2_ch5_line[0][12],s2_ch5_line[0][13]
                                                ,s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11],s2_ch5_line[1][12],s2_ch5_line[1][13]
                                                ,s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11],s2_ch5_line[2][12],s2_ch5_line[2][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[4][8],s2_ch0_line[4][9],s2_ch0_line[4][10],s2_ch0_line[4][11],s2_ch0_line[4][12],s2_ch0_line[4][13]
                                                ,s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11],s2_ch0_line[5][12],s2_ch0_line[5][13]
                                                ,s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11],s2_ch0_line[0][12],s2_ch0_line[0][13]
                                                ,s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11],s2_ch0_line[1][12],s2_ch0_line[1][13]
                                                ,s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11],s2_ch0_line[2][12],s2_ch0_line[2][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[4][8],s2_ch1_line[4][9],s2_ch1_line[4][10],s2_ch1_line[4][11],s2_ch1_line[4][12],s2_ch1_line[4][13]
                                                ,s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11],s2_ch1_line[5][12],s2_ch1_line[5][13]
                                                ,s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11],s2_ch1_line[0][12],s2_ch1_line[0][13]
                                                ,s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11],s2_ch1_line[1][12],s2_ch1_line[1][13]
                                                ,s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11],s2_ch1_line[2][12],s2_ch1_line[2][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[4][8],s2_ch2_line[4][9],s2_ch2_line[4][10],s2_ch2_line[4][11],s2_ch2_line[4][12],s2_ch2_line[4][13]
                                                ,s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11],s2_ch2_line[5][12],s2_ch2_line[5][13]
                                                ,s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11],s2_ch2_line[0][12],s2_ch2_line[0][13]
                                                ,s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11],s2_ch2_line[1][12],s2_ch2_line[1][13]
                                                ,s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11],s2_ch2_line[2][12],s2_ch2_line[2][13]
                                                };
                            end
                        end
                    endcase
                end
                write_5 : begin
                    case(w_cnt)
                        0:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[5][0],s2_ch3_line[5][1],s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5]
                                                ,s2_ch3_line[0][0],s2_ch3_line[0][1],s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5]
                                                ,s2_ch3_line[1][0],s2_ch3_line[1][1],s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5]
                                                ,s2_ch3_line[2][0],s2_ch3_line[2][1],s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5]
                                                ,s2_ch3_line[3][0],s2_ch3_line[3][1],s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5]
                                                };
                                s2_data_1 <=    {s2_ch4_line[5][0],s2_ch4_line[5][1],s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5]
                                                ,s2_ch4_line[0][0],s2_ch4_line[0][1],s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5]
                                                ,s2_ch4_line[1][0],s2_ch4_line[1][1],s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5]
                                                ,s2_ch4_line[2][0],s2_ch4_line[2][1],s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5]
                                                ,s2_ch4_line[3][0],s2_ch4_line[3][1],s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5]
                                                };
                                s2_data_2 <=    {s2_ch5_line[5][0],s2_ch5_line[5][1],s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5]
                                                ,s2_ch5_line[0][0],s2_ch5_line[0][1],s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5]
                                                ,s2_ch5_line[1][0],s2_ch5_line[1][1],s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5]
                                                ,s2_ch5_line[2][0],s2_ch5_line[2][1],s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5]
                                                ,s2_ch5_line[3][0],s2_ch5_line[3][1],s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[5][0],s2_ch0_line[5][1],s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5]
                                                ,s2_ch0_line[0][0],s2_ch0_line[0][1],s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5]
                                                ,s2_ch0_line[1][0],s2_ch0_line[1][1],s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5]
                                                ,s2_ch0_line[2][0],s2_ch0_line[2][1],s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5]
                                                ,s2_ch0_line[3][0],s2_ch0_line[3][1],s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5]
                                                };
                                s2_data_1 <=    {s2_ch1_line[5][0],s2_ch1_line[5][1],s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5]
                                                ,s2_ch1_line[0][0],s2_ch1_line[0][1],s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5]
                                                ,s2_ch1_line[1][0],s2_ch1_line[1][1],s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5]
                                                ,s2_ch1_line[2][0],s2_ch1_line[2][1],s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5]
                                                ,s2_ch1_line[3][0],s2_ch1_line[3][1],s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5]
                                                };
                                s2_data_2 <=    {s2_ch2_line[5][0],s2_ch2_line[5][1],s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5]
                                                ,s2_ch2_line[0][0],s2_ch2_line[0][1],s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5]
                                                ,s2_ch2_line[1][0],s2_ch2_line[1][1],s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5]
                                                ,s2_ch2_line[2][0],s2_ch2_line[2][1],s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5]
                                                ,s2_ch2_line[3][0],s2_ch2_line[3][1],s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5]
                                                };
                            end
                        end
                        1:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[5][2],s2_ch3_line[5][3],s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7]
                                                ,s2_ch3_line[0][2],s2_ch3_line[0][3],s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7]
                                                ,s2_ch3_line[1][2],s2_ch3_line[1][3],s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7]
                                                ,s2_ch3_line[2][2],s2_ch3_line[2][3],s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7]
                                                ,s2_ch3_line[3][2],s2_ch3_line[3][3],s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7]
                                                };
                                s2_data_1 <=    {s2_ch4_line[5][2],s2_ch4_line[5][3],s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7]
                                                ,s2_ch4_line[0][2],s2_ch4_line[0][3],s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7]
                                                ,s2_ch4_line[1][2],s2_ch4_line[1][3],s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7]
                                                ,s2_ch4_line[2][2],s2_ch4_line[2][3],s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7]
                                                ,s2_ch4_line[3][2],s2_ch4_line[3][3],s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7]
                                                };
                                s2_data_2 <=    {s2_ch5_line[5][2],s2_ch5_line[5][3],s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7]
                                                ,s2_ch5_line[0][2],s2_ch5_line[0][3],s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7]
                                                ,s2_ch5_line[1][2],s2_ch5_line[1][3],s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7]
                                                ,s2_ch5_line[2][2],s2_ch5_line[2][3],s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7]
                                                ,s2_ch5_line[3][2],s2_ch5_line[3][3],s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[5][2],s2_ch0_line[5][3],s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7]
                                                ,s2_ch0_line[0][2],s2_ch0_line[0][3],s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7]
                                                ,s2_ch0_line[1][2],s2_ch0_line[1][3],s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7]
                                                ,s2_ch0_line[2][2],s2_ch0_line[2][3],s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7]
                                                ,s2_ch0_line[3][2],s2_ch0_line[3][3],s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7]
                                                };
                                s2_data_1 <=    {s2_ch1_line[5][2],s2_ch1_line[5][3],s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7]
                                                ,s2_ch1_line[0][2],s2_ch1_line[0][3],s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7]
                                                ,s2_ch1_line[1][2],s2_ch1_line[1][3],s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7]
                                                ,s2_ch1_line[2][2],s2_ch1_line[2][3],s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7]
                                                ,s2_ch1_line[3][2],s2_ch1_line[3][3],s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7]
                                                };
                                s2_data_2 <=    {s2_ch2_line[5][2],s2_ch2_line[5][3],s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7]
                                                ,s2_ch2_line[0][2],s2_ch2_line[0][3],s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7]
                                                ,s2_ch2_line[1][2],s2_ch2_line[1][3],s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7]
                                                ,s2_ch2_line[2][2],s2_ch2_line[2][3],s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7]
                                                ,s2_ch2_line[3][2],s2_ch2_line[3][3],s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7]
                                                };
                            end
                        end
                        2:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[5][4],s2_ch3_line[5][5],s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9]
                                                ,s2_ch3_line[0][4],s2_ch3_line[0][5],s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9]
                                                ,s2_ch3_line[1][4],s2_ch3_line[1][5],s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9]
                                                ,s2_ch3_line[2][4],s2_ch3_line[2][5],s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9]
                                                ,s2_ch3_line[3][4],s2_ch3_line[3][5],s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9]
                                                };
                                s2_data_1 <=    {s2_ch4_line[5][4],s2_ch4_line[5][5],s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9]
                                                ,s2_ch4_line[0][4],s2_ch4_line[0][5],s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9]
                                                ,s2_ch4_line[1][4],s2_ch4_line[1][5],s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9]
                                                ,s2_ch4_line[2][4],s2_ch4_line[2][5],s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9]
                                                ,s2_ch4_line[3][4],s2_ch4_line[3][5],s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9]
                                                };
                                s2_data_2 <=    {s2_ch5_line[5][4],s2_ch5_line[5][5],s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9]
                                                ,s2_ch5_line[0][4],s2_ch5_line[0][5],s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9]
                                                ,s2_ch5_line[1][4],s2_ch5_line[1][5],s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9]
                                                ,s2_ch5_line[2][4],s2_ch5_line[2][5],s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9]
                                                ,s2_ch5_line[3][4],s2_ch5_line[3][5],s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9]
                                                };
                            end else begin
                                s2_data_0 <=    {s2_ch0_line[5][4],s2_ch0_line[5][5],s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9]
                                                ,s2_ch0_line[0][4],s2_ch0_line[0][5],s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9]
                                                ,s2_ch0_line[1][4],s2_ch0_line[1][5],s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9]
                                                ,s2_ch0_line[2][4],s2_ch0_line[2][5],s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9]
                                                ,s2_ch0_line[3][4],s2_ch0_line[3][5],s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9]
                                                };
                                s2_data_1 <=    {s2_ch1_line[5][4],s2_ch1_line[5][5],s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9]
                                                ,s2_ch1_line[0][4],s2_ch1_line[0][5],s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9]
                                                ,s2_ch1_line[1][4],s2_ch1_line[1][5],s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9]
                                                ,s2_ch1_line[2][4],s2_ch1_line[2][5],s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9]
                                                ,s2_ch1_line[3][4],s2_ch1_line[3][5],s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9]
                                                };
                                s2_data_2 <=    {s2_ch2_line[5][4],s2_ch2_line[5][5],s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9]
                                                ,s2_ch2_line[0][4],s2_ch2_line[0][5],s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9]
                                                ,s2_ch2_line[1][4],s2_ch2_line[1][5],s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9]
                                                ,s2_ch2_line[2][4],s2_ch2_line[2][5],s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9]
                                                ,s2_ch2_line[3][4],s2_ch2_line[3][5],s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9]
                                                };
                            end
                        end
                        3:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[5][6],s2_ch3_line[5][7],s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11]
                                                ,s2_ch3_line[0][6],s2_ch3_line[0][7],s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11]
                                                ,s2_ch3_line[1][6],s2_ch3_line[1][7],s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11]
                                                ,s2_ch3_line[2][6],s2_ch3_line[2][7],s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11]
                                                ,s2_ch3_line[3][6],s2_ch3_line[3][7],s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11]
                                                };
                                s2_data_1 <=    {s2_ch4_line[5][6],s2_ch4_line[5][7],s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11]
                                                ,s2_ch4_line[0][6],s2_ch4_line[0][7],s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11]
                                                ,s2_ch4_line[1][6],s2_ch4_line[1][7],s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11]
                                                ,s2_ch4_line[2][6],s2_ch4_line[2][7],s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11]
                                                ,s2_ch4_line[3][6],s2_ch4_line[3][7],s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11]
                                                };
                                s2_data_2 <=    {s2_ch5_line[5][6],s2_ch5_line[5][7],s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11]
                                                ,s2_ch5_line[0][6],s2_ch5_line[0][7],s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11]
                                                ,s2_ch5_line[1][6],s2_ch5_line[1][7],s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11]
                                                ,s2_ch5_line[2][6],s2_ch5_line[2][7],s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11]
                                                ,s2_ch5_line[3][6],s2_ch5_line[3][7],s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[5][6],s2_ch0_line[5][7],s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11]
                                                ,s2_ch0_line[0][6],s2_ch0_line[0][7],s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11]
                                                ,s2_ch0_line[1][6],s2_ch0_line[1][7],s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11]
                                                ,s2_ch0_line[2][6],s2_ch0_line[2][7],s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11]
                                                ,s2_ch0_line[3][6],s2_ch0_line[3][7],s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11]
                                                };
                                s2_data_1 <=    {s2_ch1_line[5][6],s2_ch1_line[5][7],s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11]
                                                ,s2_ch1_line[0][6],s2_ch1_line[0][7],s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11]
                                                ,s2_ch1_line[1][6],s2_ch1_line[1][7],s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11]
                                                ,s2_ch1_line[2][6],s2_ch1_line[2][7],s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11]
                                                ,s2_ch1_line[3][6],s2_ch1_line[3][7],s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11]
                                                };
                                s2_data_2 <=    {s2_ch2_line[5][6],s2_ch2_line[5][7],s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11]
                                                ,s2_ch2_line[0][6],s2_ch2_line[0][7],s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11]
                                                ,s2_ch2_line[1][6],s2_ch2_line[1][7],s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11]
                                                ,s2_ch2_line[2][6],s2_ch2_line[2][7],s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11]
                                                ,s2_ch2_line[3][6],s2_ch2_line[3][7],s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11]
                                                };
                            end
                        end
                        4:begin
                            if(filter_cnt)begin
                                s2_data_0 <=    {s2_ch3_line[5][8],s2_ch3_line[5][9],s2_ch3_line[5][10],s2_ch3_line[5][11],s2_ch3_line[5][12],s2_ch3_line[5][13]
                                                ,s2_ch3_line[0][8],s2_ch3_line[0][9],s2_ch3_line[0][10],s2_ch3_line[0][11],s2_ch3_line[0][12],s2_ch3_line[0][13]
                                                ,s2_ch3_line[1][8],s2_ch3_line[1][9],s2_ch3_line[1][10],s2_ch3_line[1][11],s2_ch3_line[1][12],s2_ch3_line[1][13]
                                                ,s2_ch3_line[2][8],s2_ch3_line[2][9],s2_ch3_line[2][10],s2_ch3_line[2][11],s2_ch3_line[2][12],s2_ch3_line[2][13]
                                                ,s2_ch3_line[3][8],s2_ch3_line[3][9],s2_ch3_line[3][10],s2_ch3_line[3][11],s2_ch3_line[3][12],s2_ch3_line[3][13]
                                                };
                                s2_data_1 <=    {s2_ch4_line[5][8],s2_ch4_line[5][9],s2_ch4_line[5][10],s2_ch4_line[5][11],s2_ch4_line[5][12],s2_ch4_line[5][13]
                                                ,s2_ch4_line[0][8],s2_ch4_line[0][9],s2_ch4_line[0][10],s2_ch4_line[0][11],s2_ch4_line[0][12],s2_ch4_line[0][13]
                                                ,s2_ch4_line[1][8],s2_ch4_line[1][9],s2_ch4_line[1][10],s2_ch4_line[1][11],s2_ch4_line[1][12],s2_ch4_line[1][13]
                                                ,s2_ch4_line[2][8],s2_ch4_line[2][9],s2_ch4_line[2][10],s2_ch4_line[2][11],s2_ch4_line[2][12],s2_ch4_line[2][13]
                                                ,s2_ch4_line[3][8],s2_ch4_line[3][9],s2_ch4_line[3][10],s2_ch4_line[3][11],s2_ch4_line[3][12],s2_ch4_line[3][13]
                                                };
                                s2_data_2 <=    {s2_ch5_line[5][8],s2_ch5_line[5][9],s2_ch5_line[5][10],s2_ch5_line[5][11],s2_ch5_line[5][12],s2_ch5_line[5][13]
                                                ,s2_ch5_line[0][8],s2_ch5_line[0][9],s2_ch5_line[0][10],s2_ch5_line[0][11],s2_ch5_line[0][12],s2_ch5_line[0][13]
                                                ,s2_ch5_line[1][8],s2_ch5_line[1][9],s2_ch5_line[1][10],s2_ch5_line[1][11],s2_ch5_line[1][12],s2_ch5_line[1][13]
                                                ,s2_ch5_line[2][8],s2_ch5_line[2][9],s2_ch5_line[2][10],s2_ch5_line[2][11],s2_ch5_line[2][12],s2_ch5_line[2][13]
                                                ,s2_ch5_line[3][8],s2_ch5_line[3][9],s2_ch5_line[3][10],s2_ch5_line[3][11],s2_ch5_line[3][12],s2_ch5_line[3][13]
                                                };
                            end else begin 
                                s2_data_0 <=    {s2_ch0_line[5][8],s2_ch0_line[5][9],s2_ch0_line[5][10],s2_ch0_line[5][11],s2_ch0_line[5][12],s2_ch0_line[5][13]
                                                ,s2_ch0_line[0][8],s2_ch0_line[0][9],s2_ch0_line[0][10],s2_ch0_line[0][11],s2_ch0_line[0][12],s2_ch0_line[0][13]
                                                ,s2_ch0_line[1][8],s2_ch0_line[1][9],s2_ch0_line[1][10],s2_ch0_line[1][11],s2_ch0_line[1][12],s2_ch0_line[1][13]
                                                ,s2_ch0_line[2][8],s2_ch0_line[2][9],s2_ch0_line[2][10],s2_ch0_line[2][11],s2_ch0_line[2][12],s2_ch0_line[2][13]
                                                ,s2_ch0_line[3][8],s2_ch0_line[3][9],s2_ch0_line[3][10],s2_ch0_line[3][11],s2_ch0_line[3][12],s2_ch0_line[3][13]
                                                };
                                s2_data_1 <=    {s2_ch1_line[5][8],s2_ch1_line[5][9],s2_ch1_line[5][10],s2_ch1_line[5][11],s2_ch1_line[5][12],s2_ch1_line[5][13]
                                                ,s2_ch1_line[0][8],s2_ch1_line[0][9],s2_ch1_line[0][10],s2_ch1_line[0][11],s2_ch1_line[0][12],s2_ch1_line[0][13]
                                                ,s2_ch1_line[1][8],s2_ch1_line[1][9],s2_ch1_line[1][10],s2_ch1_line[1][11],s2_ch1_line[1][12],s2_ch1_line[1][13]
                                                ,s2_ch1_line[2][8],s2_ch1_line[2][9],s2_ch1_line[2][10],s2_ch1_line[2][11],s2_ch1_line[2][12],s2_ch1_line[2][13]
                                                ,s2_ch1_line[3][8],s2_ch1_line[3][9],s2_ch1_line[3][10],s2_ch1_line[3][11],s2_ch1_line[3][12],s2_ch1_line[3][13]
                                                };
                                s2_data_2 <=    {s2_ch2_line[5][8],s2_ch2_line[5][9],s2_ch2_line[5][10],s2_ch2_line[5][11],s2_ch2_line[5][12],s2_ch2_line[5][13]
                                                ,s2_ch2_line[0][8],s2_ch2_line[0][9],s2_ch2_line[0][10],s2_ch2_line[0][11],s2_ch2_line[0][12],s2_ch2_line[0][13]
                                                ,s2_ch2_line[1][8],s2_ch2_line[1][9],s2_ch2_line[1][10],s2_ch2_line[1][11],s2_ch2_line[1][12],s2_ch2_line[1][13]
                                                ,s2_ch2_line[2][8],s2_ch2_line[2][9],s2_ch2_line[2][10],s2_ch2_line[2][11],s2_ch2_line[2][12],s2_ch2_line[2][13]
                                                ,s2_ch2_line[3][8],s2_ch2_line[3][9],s2_ch2_line[3][10],s2_ch2_line[3][11],s2_ch2_line[3][12],s2_ch2_line[3][13]
                                                };
                            end
                        end
                    endcase
                end
            endcase
        end else begin
            s2_valid <= 0;
        end
    end


endmodule