`timescale 1ns / 1ps

module c3_relu_quanti(
    input clk,
    input rst_n,
    input c3_part_valid,
    input signed [31:0] c3_sum_0_0,
    input signed [31:0] c3_sum_0_1,
    input signed [31:0] c3_sum_0_2,
    input signed [31:0] c3_sum_1_0,
    input signed [31:0] c3_sum_1_1,
    input signed [31:0] c3_sum_1_2,
    output reg c3_valid,
    output reg [7:0] c3_out_0,
    output reg [7:0] c3_out_1
);
    //pipe_0
    reg total_valid;
    reg sum_flag;
    reg signed [31:0] c3_sum_save_0;
    reg signed [31:0] c3_sum_save_1;
    reg signed [31:0] c3_sum_total_0;
    reg signed [31:0] c3_sum_total_1;

    //pipe_1
    reg relu_valid;
    reg [31:0] relu_0;
    reg [31:0] relu_1;

    //pipe_0_operation
    always @(posedge clk) begin
        if(!rst_n)begin
            sum_flag <= 0;
            c3_sum_save_0 <= 0;
            c3_sum_save_1 <= 0;
            c3_sum_total_0 <= 0;
            c3_sum_total_1 <= 0;
        end else if(c3_part_valid)begin
            if(sum_flag)begin
                sum_flag <= 0;
                c3_sum_save_0 <= 0;
                c3_sum_save_1 <= 0;
                c3_sum_total_0 <= c3_sum_0_0 + c3_sum_0_1 + c3_sum_0_2 + c3_sum_save_0;
                c3_sum_total_1 <= c3_sum_1_0 + c3_sum_1_1 + c3_sum_1_2 + c3_sum_save_1;
            end else begin
                sum_flag <= 1;
                c3_sum_save_0 <= c3_sum_0_0 + c3_sum_0_1 + c3_sum_0_2;
                c3_sum_save_1 <= c3_sum_1_0 + c3_sum_1_1 + c3_sum_1_2;
            end
        end
    end

    //pipe_1_operation
    always@(posedge clk)begin
        if(!rst_n)begin
            relu_0 <= 0;
            relu_1 <= 0;
        end else if(total_valid)begin
            if(0 >= c3_sum_total_0) relu_0 <= 0;
            else relu_0 <= c3_sum_total_0;
            if(0 >= c3_sum_total_1) relu_1 <= 0;
            else relu_1 <= c3_sum_total_1;
        end
    end

    //pipe_2_operation
    always@(posedge clk)begin
        if(!rst_n)begin
            c3_out_0 <=0;
            c3_out_1 <=0;
        end else if(relu_valid)begin
            if(|(relu_0[31:15]))begin
                c3_out_0 <=255;
            end else if((&relu_0[14:7]))begin
                c3_out_0 <= relu_0[14:7];
            end else begin
                c3_out_0 <= relu_0[14:7] + relu_0[6];
            end
            if(|(relu_1[31:15]))begin
                c3_out_1 <=255;
            end else if((&relu_1[14:7]))begin
                c3_out_1 <= relu_1[14:7];
            end else begin
                c3_out_1 <= relu_1[14:7] + relu_1[6];
            end
        end
    end

    //pipeline_valid
    always@(posedge clk)begin
        if(!rst_n)begin
            total_valid <= 0;
            relu_valid <= 0;
            c3_valid <= 0;
        end else begin
            total_valid <= c3_part_valid & sum_flag;
            relu_valid <= total_valid;
            c3_valid <= relu_valid;
        end
    end

endmodule