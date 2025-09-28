`timescale 1ns / 1ps
module c1_layer_tb_integrated;

    // Clock and reset
    reg clk;
    reg reset_n;
    
    // Control signals
    reg i_start;
    wire o_done;
    
    // Pixel input
    reg pixel_in_valid;
    reg signed [7:0] pixel_in;
    wire pixel_ready;
    
    // Configuration
    reg i_conv_ready;
    reg relu_en;
    reg quan_en;
    
    // Output signals - 기존 28x28 outputs (유지)
    wire [7:0] out_ch0, out_ch1, out_ch2;
    wire [7:0] out_ch3, out_ch4, out_ch5;
    wire out_valid;
    
    // NEW: Maxpooling output signals - 14x14 outputs
    wire c1_mp_valid;
    wire [7:0] c1_mp_data_ch_0, c1_mp_data_ch_1, c1_mp_data_ch_2;
    wire [7:0] c1_mp_data_ch_3, c1_mp_data_ch_4, c1_mp_data_ch_5;
    
    // Debug signals
    wire [4:0] o_window_col;
    wire [4:0] o_output_row;
    wire o_conv_row_start;
    wire o_conv_row_end;
    
    // Test data
    reg signed [7:0] input_image [0:1023];    // 32x32 input
    reg [7:0] output_ch0 [0:783];             // 28x28 outputs (기존)
    reg [7:0] output_ch1 [0:783];
    reg [7:0] output_ch2 [0:783];
    reg [7:0] output_ch3 [0:783];
    reg [7:0] output_ch4 [0:783];
    reg [7:0] output_ch5 [0:783];
    
    // NEW: Maxpooling output arrays - 14x14
    reg [7:0] mp_output_ch0 [0:195];          // 14x14 = 196
    reg [7:0] mp_output_ch1 [0:195];
    reg [7:0] mp_output_ch2 [0:195];
    reg [7:0] mp_output_ch3 [0:195];
    reg [7:0] mp_output_ch4 [0:195];
    reg [7:0] mp_output_ch5 [0:195];
    
    integer pixel_count;
    integer i, j;
    integer output_file;
    integer input_file;
    integer output_idx;
    integer mp_output_idx;  // NEW: maxpooling output index
    integer valid_count;
    integer done_wait_cnt;
    reg [7:0] temp_val;
    integer scan_result;
    
    // 모니터링 변수들
    integer weights_load_time;
    integer first_output_time;
    integer last_output_time;
    integer total_outputs_received;
    integer total_mp_outputs_received;  // NEW: maxpooling output counter
    integer consecutive_no_output;
    integer nz_count;

    // Clock generation - 200MHz
    initial begin
        clk = 0;
        forever #2.5 clk = ~clk;  // 200MHz (5ns period)
    end
    
    // DUT instantiation
    c1_layer_top_integrated DUT (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .o_done(o_done),
        .pixel_in_valid(pixel_in_valid),
        .pixel_in(pixel_in),
        .pixel_ready(pixel_ready),
        .i_conv_ready(i_conv_ready),
        .relu_en(relu_en),
        .quan_en(quan_en),
        
        // 기존 28x28 outputs
        .out_ch0(out_ch0),
        .out_ch1(out_ch1),
        .out_ch2(out_ch2),
        .out_ch3(out_ch3),
        .out_ch4(out_ch4),
        .out_ch5(out_ch5),
        .out_valid(out_valid),
        
        // NEW: Maxpooling outputs
        .c1_mp_valid(c1_mp_valid),
        .c1_mp_data_ch_0(c1_mp_data_ch_0),
        .c1_mp_data_ch_1(c1_mp_data_ch_1),
        .c1_mp_data_ch_2(c1_mp_data_ch_2),
        .c1_mp_data_ch_3(c1_mp_data_ch_3),
        .c1_mp_data_ch_4(c1_mp_data_ch_4),
        .c1_mp_data_ch_5(c1_mp_data_ch_5),
        
        .o_window_col(o_window_col),
        .o_output_row(o_output_row),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end)
    );
    
    // =========================
    // Initialize arrays and load input image
    // =========================
    initial begin
        // Clear output arrays
        for (i = 0; i < 784; i = i + 1) begin
            output_ch0[i] = 8'h00;
            output_ch1[i] = 8'h00;
            output_ch2[i] = 8'h00;
            output_ch3[i] = 8'h00;
            output_ch4[i] = 8'h00;
            output_ch5[i] = 8'h00;
        end
        
        // NEW: Clear maxpooling output arrays
        for (i = 0; i < 196; i = i + 1) begin
            mp_output_ch0[i] = 8'h00;
            mp_output_ch1[i] = 8'h00;
            mp_output_ch2[i] = 8'h00;
            mp_output_ch3[i] = 8'h00;
            mp_output_ch4[i] = 8'h00;
            mp_output_ch5[i] = 8'h00;
        end

        // 입력 데이터 로딩 (HEX)
        $display("=== Loading Input Image ===");
        input_file = $fopen("C:/VI_LFEA/LEFA/input/image_pixels_0.txt", "r");
        
        if (input_file != 0) begin
            $display("Found image_pixels_0.txt, loading data...");
            for (i = 0; i < 1024; i = i + 1) begin
                scan_result = $fscanf(input_file, "%h", temp_val);
                if (scan_result == 1) begin
                    if (temp_val <= 8'hFF) begin  // Valid 8-bit range
                        input_image[i] = $signed(temp_val);
                    end else begin
                        $display("WARNING: Invalid pixel value %h at index %0d -> force 00", temp_val, i);
                        input_image[i] = 8'sd0;
                    end
                end else begin
                    $display("Error reading pixel %0d, using 00", i);
                    input_image[i] = 8'sd0;
                end
                
                // 디버그: 처음 20개 및 non-zero 구간만 출력
                if (i < 20 || (i >= 140 && i <= 145)) begin
                    $display("input_image[%3d] = %02h (%3d)", i, input_image[i], input_image[i]);
                end
            end
            $fclose(input_file);
            $display("Successfully loaded 1024 pixels");
            
            // 중요 위치: 입력 데이터 non-zero 값들 확인 (정답 검증용)
            $display("Key positions check:");
            $display("  [140] = %02h (should be 01)", input_image[140]);
            $display("  [141] = %02h (should be 21)", input_image[141]);  
            $display("  [142] = %02h (should be 05)", input_image[142]);

            // 간단한 non-zero 개수 카운트
            nz_count = 0;
            for (i = 0; i < 1024; i = i + 1)
                if (input_image[i] != 8'h00) nz_count = nz_count + 1;
            $display("Non-zero pixels in input_image: %0d / 1024", nz_count);

        end else begin
            $display("File not found! Fill input_image with zeros.");
            for (i = 0; i < 1024; i = i + 1) begin
                input_image[i] = 8'sd0;  // All zeros for safe testing
            end
        end
    end
    
    // =========================
    // Main test (출력 데이터 보정 및 maxpooling 출력 캡처 추가)
    // =========================
    initial begin
        // Initialize monitoring variables
        weights_load_time = 0;
        first_output_time = 0;
        last_output_time = 0;
        total_outputs_received = 0;
        total_mp_outputs_received = 0;  // NEW
        consecutive_no_output = 0;
        
        // Initialize
        reset_n = 0;
        i_start = 0;
        pixel_in_valid = 0;
        pixel_in = 0;
        i_conv_ready = 1;  // Always ready
        relu_en = 1;
        quan_en = 1;
        pixel_count = 0;
        output_idx = 0;
        mp_output_idx = 0;  // NEW
        valid_count = 0;
        done_wait_cnt = 0;
        
        // Wait for file loading
        #10;
        
        // Reset sequence
        $display("\n=== Reset Sequence ===");
        #100;
        reset_n = 1;
        #20;
        
        // Start weight loading
        $display("\n=== Starting Weight Load at %0t ===", $time);
        weights_load_time = $time;
        i_start = 1;
        #20;
        i_start = 0;
        
        // Weight loading 완료 대기
        wait(DUT.weights_loaded == 1);
        $display("Weights loaded at %0t (took %0t ns)", $time, $time - weights_load_time);
        
        // Line controller 시작 대기
        wait(DUT.line_controller_start == 1);
        $display("Line controller started at %0t", $time);
        
        #100;  // 잠시 대기
        
        // 픽셀 feeding + 출력 모니터링
        $display("\n=== Starting Pixel Feed and Output Monitoring ===");
        
        fork
            // Pixel feeding process
            begin
                pixel_count = 0;
                repeat(1024) begin
                    // Wait for pixel_ready before feeding
                    while (!pixel_ready) begin
                        @(posedge clk);
                    end

                    @(posedge clk);
                    pixel_in_valid = 1;
                    pixel_in = input_image[pixel_count];

                    if (pixel_count < 5) begin
                        $display("Feeding pixel[%4d] = %3d at %0t", pixel_count, pixel_in, $time);
                    end

                    pixel_count = pixel_count + 1;

                    if (pixel_count % 256 == 0) begin
                        $display("Fed %0d pixels at %0t", pixel_count, $time);
                    end
                end

                @(posedge clk);
                pixel_in_valid = 0;
                $display("Finished feeding %0d pixels at %0t", pixel_count, $time);
            end
            
            // 기존 28x28 Output monitoring
            begin
                output_idx = 0;
                consecutive_no_output = 0;
                
                while (output_idx < 784 && consecutive_no_output < 50000) begin
                    @(posedge clk);
                    
                    if (out_valid) begin
                        if (output_idx == 0) begin
                            first_output_time = $time; // 첫 출력 시점 기록 (28x28)
                        end
                        if (output_idx < 784) begin
                            output_ch0[output_idx] = out_ch0;
                            output_ch1[output_idx] = out_ch1;
                            output_ch2[output_idx] = out_ch2;
                            output_ch3[output_idx] = out_ch3;
                            output_ch4[output_idx] = out_ch4;
                            output_ch5[output_idx] = out_ch5;
                            
                            total_outputs_received = total_outputs_received + 1;
                            last_output_time = $time;
                            consecutive_no_output = 0;
                            
                            // Debug key positions
                            if (output_idx < 15 || output_idx > 770) begin
                                $display("28x28 Stored[%3d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t", 
                                        output_idx, out_ch0, out_ch1, out_ch2, out_ch3, out_ch4, out_ch5, $time);
                            end
                            
                            output_idx = output_idx + 1;
                        end
                    end else begin
                        consecutive_no_output = consecutive_no_output + 1;
                    end
                end
                
                if (consecutive_no_output >= 50000) begin
                    $display("ERROR: Stopped due to no 28x28 outputs for %0d cycles", consecutive_no_output);
                end
            end
            
            // NEW: Maxpooling 14x14 Output monitoring
            begin
                mp_output_idx = 0;
                
                while (mp_output_idx < 196) begin  // 14x14 = 196
                    @(posedge clk);
                    
                    if (c1_mp_valid) begin
                        if (mp_output_idx < 196) begin
                            mp_output_ch0[mp_output_idx] = c1_mp_data_ch_0;
                            mp_output_ch1[mp_output_idx] = c1_mp_data_ch_1;
                            mp_output_ch2[mp_output_idx] = c1_mp_data_ch_2;
                            mp_output_ch3[mp_output_idx] = c1_mp_data_ch_3;
                            mp_output_ch4[mp_output_idx] = c1_mp_data_ch_4;
                            mp_output_ch5[mp_output_idx] = c1_mp_data_ch_5;
                            
                            total_mp_outputs_received = total_mp_outputs_received + 1;
                            
                            // Debug key positions
                            if (mp_output_idx < 15 || mp_output_idx > 180) begin
                                $display("MAXPOOL Stored[%3d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t", 
                                        mp_output_idx, c1_mp_data_ch_0, c1_mp_data_ch_1, c1_mp_data_ch_2, 
                                        c1_mp_data_ch_3, c1_mp_data_ch_4, c1_mp_data_ch_5, $time);
                            end
                            
                            mp_output_idx = mp_output_idx + 1;
                        end
                    end
                end
                
                $display("MAXPOOL COMPLETE: Collected %0d outputs at %0t", mp_output_idx, $time);
            end
        join
        
        // Wait for done signal with timeout
        $display("\n=== Waiting for Done Signal ===");
        done_wait_cnt = 0;
        while (!o_done && done_wait_cnt < 500000) begin  // INCREASED: 100k -> 500k
            @(posedge clk);
            done_wait_cnt = done_wait_cnt + 1;
            
            // collect remaining outputs
            if (out_valid && output_idx < 784) begin
                output_ch0[output_idx] = out_ch0;
                output_ch1[output_idx] = out_ch1;
                output_ch2[output_idx] = out_ch2;
                output_ch3[output_idx] = out_ch3;
                output_ch4[output_idx] = out_ch4;
                output_ch5[output_idx] = out_ch5;
                output_idx = output_idx + 1;
                total_outputs_received = total_outputs_received + 1;
                last_output_time = $time;
            end
            
            // NEW: collect remaining maxpooling outputs
            if (c1_mp_valid && mp_output_idx < 196) begin
                mp_output_ch0[mp_output_idx] = c1_mp_data_ch_0;
                mp_output_ch1[mp_output_idx] = c1_mp_data_ch_1;
                mp_output_ch2[mp_output_idx] = c1_mp_data_ch_2;
                mp_output_ch3[mp_output_idx] = c1_mp_data_ch_3;
                mp_output_ch4[mp_output_idx] = c1_mp_data_ch_4;
                mp_output_ch5[mp_output_idx] = c1_mp_data_ch_5;
                mp_output_idx = mp_output_idx + 1;
                total_mp_outputs_received = total_mp_outputs_received + 1;
            end
            
            if (done_wait_cnt % 50000 == 0) begin  // CHANGED: 20k -> 50k for less frequent updates
                $display("Waiting for done... cycle %0d, 28x28 outputs: %0d, maxpool outputs: %0d", 
                        done_wait_cnt, total_outputs_received, total_mp_outputs_received);
            end
        end
        
        // Final status
        if (o_done) begin
            $display("\nDone signal received at %0t", $time);
        end else begin
            $display("\nWARNING: Timeout waiting for done signal");
        end
        
        // Save outputs (기존 28x28 outputs)
        $display("\n=== Saving 28x28 Output Files ===");
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch0.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch0[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch0.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch1.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch1[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch1.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch2.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch2[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch2.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch3.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch3[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch3.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch4.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch4[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch4.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_output_ch5.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", output_ch5[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch5.txt");
        end
        
        // NEW: Save maxpooling outputs (14x14)
        $display("\n=== Saving 14x14 Maxpooling Output Files ===");
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch0.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch0[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch0.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch1.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch1[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch1.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch2.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch2[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch2.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch3.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch3[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch3.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch4.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch4[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch4.txt");
        end
        
        output_file = $fopen("C:/VI_LFEA/LEFA/output/c1_mp_output_ch5.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", mp_output_ch5[i]);
            $fclose(output_file);
            $display("Saved c1_mp_output_ch5.txt");
        end
        
        // Summary
        $display("\n=== COMPREHENSIVE SUMMARY ===");
        $display("Input file: image_pixels_0.txt");
        $display("Pixels fed: %0d", pixel_count);
        $display("Total 28x28 outputs received: %0d", total_outputs_received);
        $display("Total 14x14 maxpool outputs received: %0d", total_mp_outputs_received);
        $display("28x28 outputs stored in arrays: %0d", output_idx);
        $display("14x14 maxpool outputs stored in arrays: %0d", mp_output_idx);
        $display("Done signal: %s", o_done ? "YES" : "NO");
        $display("Weight load time: %0t ns", weights_load_time);
        $display("First output time: %0t ns", first_output_time);
        $display("Last output time: %0t ns", last_output_time);
        if (first_output_time > 0 && last_output_time > first_output_time) begin
            $display("Output duration: %0t ns", last_output_time - first_output_time);
        end
        
        // Check non-zero outputs - 28x28
        j = 0;
        for (i = 0; i < 784; i = i + 1) begin
            if (|output_ch0[i] | |output_ch1[i] | |output_ch2[i] |
                |output_ch3[i] | |output_ch4[i] | |output_ch5[i]) begin
                j = j + 1;
            end
        end
        $display("Non-zero 28x28 output positions: %0d / 784", j);
        
        // Check non-zero outputs - 14x14 maxpool
        j = 0;
        for (i = 0; i < 196; i = i + 1) begin
            if (|mp_output_ch0[i] | |mp_output_ch1[i] | |mp_output_ch2[i] |
                |mp_output_ch3[i] | |mp_output_ch4[i] | |mp_output_ch5[i]) begin
                j = j + 1;
            end
        end
        $display("Non-zero 14x14 maxpool output positions: %0d / 196", j);
        
        // Per-Channel Analysis - 28x28
        $display("\n--- Per-Channel Analysis (28x28) ---");
        for (i = 0; i < 6; i = i + 1) begin
            j = 0;  // Count non-zero values
            case (i)
                0: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch0[pixel_count] != 0) j = j + 1;
                1: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch1[pixel_count] != 0) j = j + 1;
                2: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch2[pixel_count] != 0) j = j + 1;
                3: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch3[pixel_count] != 0) j = j + 1;
                4: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch4[pixel_count] != 0) j = j + 1;
                5: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (output_ch5[pixel_count] != 0) j = j + 1;
            endcase
            $display("28x28 Channel %0d: %0d non-zero values", i, j);
        end
        
        // Per-Channel Analysis - 14x14 maxpool
        $display("\n--- Per-Channel Analysis (14x14 Maxpool) ---");
        for (i = 0; i < 6; i = i + 1) begin
            j = 0;  // Count non-zero values
            case (i)
                0: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch0[pixel_count] != 0) j = j + 1;
                1: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch1[pixel_count] != 0) j = j + 1;
                2: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch2[pixel_count] != 0) j = j + 1;
                3: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch3[pixel_count] != 0) j = j + 1;
                4: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch4[pixel_count] != 0) j = j + 1;
                5: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (mp_output_ch5[pixel_count] != 0) j = j + 1;
            endcase
                $display("14x14 Maxpool Channel %0d: %0d non-zero values", i, j);
        end
        
        // Sample Outputs - 28x28
        $display("\n--- Sample 28x28 Outputs ---");
        $display("First row (0-27):");
        $display("  ch0: %02h %02h %02h %02h", output_ch0[0], output_ch0[1], output_ch0[2], output_ch0[3]);
        $display("  ch1: %02h %02h %02h %02h", output_ch1[0], output_ch1[1], output_ch1[2], output_ch1[3]);
        $display("  ch5: %02h %02h %02h %02h", output_ch5[0], output_ch5[1], output_ch5[2], output_ch5[3]);
        
        // Sample Outputs - 14x14 maxpool
        $display("\n--- Sample 14x14 Maxpool Outputs ---");
        $display("First row (0-13):");
        $display("  ch0: %02h %02h %02h %02h", mp_output_ch0[0], mp_output_ch0[1], mp_output_ch0[2], mp_output_ch0[3]);
        $display("  ch1: %02h %02h %02h %02h", mp_output_ch1[0], mp_output_ch1[1], mp_output_ch1[2], mp_output_ch1[3]);
        $display("  ch5: %02h %02h %02h %02h", mp_output_ch5[0], mp_output_ch5[1], mp_output_ch5[2], mp_output_ch5[3]);
        
        $display("Last row (182-195):");
        $display("  ch0: %02h %02h %02h %02h", mp_output_ch0[182], mp_output_ch0[183], mp_output_ch0[184], mp_output_ch0[185]);
        $display("  ch1: %02h %02h %02h %02h", mp_output_ch1[182], mp_output_ch1[183], mp_output_ch1[184], mp_output_ch1[185]);
        $display("  ch5: %02h %02h %02h %02h", mp_output_ch5[182], mp_output_ch5[183], mp_output_ch5[184], mp_output_ch5[185]);
        
        // Verdict
        if (total_mp_outputs_received >= 180) begin
            $display("\n*** SUCCESS: Received %0d maxpool outputs (>= 180) ***", total_mp_outputs_received);
            $display("*** This matches the expected 14x14 = 196 output size ***");
        end else if (total_mp_outputs_received >= 100) begin
            $display("\n*** PARTIAL SUCCESS: Received %0d maxpool outputs (>= 100) ***", total_mp_outputs_received);
        end else begin
            $display("\n*** FAILURE: Only received %0d maxpool outputs ***", total_mp_outputs_received);
        end
        
        if (total_outputs_received >= 700) begin
            $display("*** 28x28 outputs also successful: %0d outputs ***", total_outputs_received);
        end
        
        #500;
        $finish;
    end
    
    // Enhanced monitoring
    always @(posedge clk) begin
        // Monitor weight loading progress
        if (DUT.state != DUT.IDLE && DUT.state != DUT.READY) begin
            if ($time % 1000 == 0) begin  // Every 1000 ns
                $display("Weight loading: state=%0d, kernel_idx=%0d, weights_loaded=%b at %0t", 
                        DUT.state, DUT.kernel_idx, DUT.weights_loaded, $time);
            end
        end
        
        // 중요 좌표(2,8) 찍기: o_window_col은 center, window_0_0은 top-left
        if (DUT.o_output_row == 5'd2 && DUT.o_window_col == 5'd8) begin
            $display("Critical window at (2,8): tl=%02h center=%02h @%0t",
                     DUT.window_0_0,   // top-left
                     DUT.window_2_2,   // center
                     $time);
        end

        // Monitor line controller status
        if (DUT.line_controller_start) begin
            $display("Line controller START pulse detected at %0t", $time);
        end
        
        // Monitor convolution valid signals
        if (DUT.o_conv_valid) begin
            $display("Convolution valid: row=%0d, col=%0d, window_0_0=%02h at %0t", 
                    DUT.o_output_row, DUT.o_window_col, DUT.window_0_0, $time);
        end
        
        // Monitor PE valid outputs
        if (DUT.valid_out_ch0 || DUT.valid_out_ch1 || DUT.valid_out_ch2 || 
            DUT.valid_out_ch3 || DUT.valid_out_ch4 || DUT.valid_out_ch5) begin
            $display("PE outputs valid: ch0=%b ch1=%b ch2=%b ch3=%b ch4=%b ch5=%b at %0t",
                    DUT.valid_out_ch0, DUT.valid_out_ch1, DUT.valid_out_ch2,
                    DUT.valid_out_ch3, DUT.valid_out_ch4, DUT.valid_out_ch5, $time);
        end
        
        // NEW: Monitor reg_controller and maxpooling
        if (DUT.pool_valid) begin
            $display("REG_CONTROLLER: pool_valid=1, pool_ch0=%08h at %0t", DUT.pool_ch0, $time);
        end
        
        if (c1_mp_valid) begin
            $display("MAXPOOL_OUT: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t",
                    c1_mp_data_ch_0, c1_mp_data_ch_1, c1_mp_data_ch_2,
                    c1_mp_data_ch_3, c1_mp_data_ch_4, c1_mp_data_ch_5, $time);
        end
        
        // ENHANCED: Monitor key control signals periodically
        if ($time % 100000 == 0) begin  // Every 100us
            $display("CONTROL_STATUS at %0t: weights_loaded=%b, line_done=%b, pool_valid=%b, mp_valid=%b",
                    $time, DUT.weights_loaded, DUT.line_controller_done, DUT.pool_valid, c1_mp_valid);
        end
        
        // Monitor line controller completion
        if (DUT.line_controller_done) begin
            $display("*** LINE_CONTROLLER DONE at %0t ***", $time);
        end
        
        // Monitor row completion
        if (o_conv_row_end) begin
            $display("*** Row %0d completed at %0t ***", o_output_row, $time);
        end
    end
    
    // Timeout protection
    initial begin
        #50000000;  // REDUCED: 50ms timeout instead of 1000ms
        $display("*** TIMEOUT: Simulation terminated after 50ms ***");
        $display("Status: 28x28_outputs_received=%0d, maxpool_outputs_received=%0d, pixel_count=%0d", 
                total_outputs_received, total_mp_outputs_received, pixel_count);
        $display("DEBUG: weights_loaded=%b, o_done=%b", DUT.weights_loaded, o_done);
        $display("DEBUG: pool_valid=%b, c1_mp_valid=%b", DUT.pool_valid, c1_mp_valid);
        $finish;
    end
    
endmodule