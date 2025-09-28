`timescale 1ns / 1ps

module c1_complete_top_tb;

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

    // Final output signals (14x14 per channel after maxpooling)
    wire [7:0] final_out_ch0, final_out_ch1, final_out_ch2;
    wire [7:0] final_out_ch3, final_out_ch4, final_out_ch5;
    wire final_out_valid;

    // Debug signals
    wire [4:0] o_window_col;
    wire [4:0] o_output_row;
    wire o_conv_row_start;
    wire o_conv_row_end;
    wire conv_layer_done;
    wire [1:0] reg_controller_state;

    // Test data arrays
    reg signed [7:0] input_image [0:1023];      // 32x32 input
    reg [7:0] final_output_ch0 [0:195];         // 14x14 outputs (196 values each)
    reg [7:0] final_output_ch1 [0:195];
    reg [7:0] final_output_ch2 [0:195];
    reg [7:0] final_output_ch3 [0:195];
    reg [7:0] final_output_ch4 [0:195];
    reg [7:0] final_output_ch5 [0:195];
    // Add conv layer output arrays (28x28 like original testbench)
    reg [7:0] conv_output_ch0 [0:783];          // 28x28 conv outputs (784 values each)
    reg [7:0] conv_output_ch1 [0:783];
    reg [7:0] conv_output_ch2 [0:783];
    reg [7:0] conv_output_ch3 [0:783];
    reg [7:0] conv_output_ch4 [0:783];
    reg [7:0] conv_output_ch5 [0:783];

    // Monitoring variables
    integer pixel_count;
    integer final_output_idx;
    integer conv_output_idx;  // Add index for conv outputs
    integer i, j;
    integer input_file, output_file;
    integer scan_result;
    reg [7:0] temp_val;

    // Performance monitoring
    integer start_time, conv_done_time, final_done_time;
    integer total_final_outputs;
    integer total_conv_outputs;  // Add counter for conv outputs
    integer conv_outputs_received;
    integer pool_outputs_received;
    integer consecutive_no_output;
    integer nz_input_count, nz_final_count;

    // Clock generation - 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // DUT instantiation
    c1_complete_top DUT (
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
        .final_out_ch0(final_out_ch0),
        .final_out_ch1(final_out_ch1),
        .final_out_ch2(final_out_ch2),
        .final_out_ch3(final_out_ch3),
        .final_out_ch4(final_out_ch4),
        .final_out_ch5(final_out_ch5),
        .final_out_valid(final_out_valid),
        .o_window_col(o_window_col),
        .o_output_row(o_output_row),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end),
        .conv_layer_done(conv_layer_done),
        .reg_controller_state(reg_controller_state)
    );

    // Load input image data
    initial begin
        // Initialize arrays
        for (i = 0; i < 1024; i = i + 1) begin
            input_image[i] = 8'sd0;
        end

        for (i = 0; i < 196; i = i + 1) begin
            final_output_ch0[i] = 8'd0;
            final_output_ch1[i] = 8'd0;
            final_output_ch2[i] = 8'd0;
            final_output_ch3[i] = 8'd0;
            final_output_ch4[i] = 8'd0;
            final_output_ch5[i] = 8'd0;
        end

        // Initialize conv output arrays
        for (i = 0; i < 784; i = i + 1) begin
            conv_output_ch0[i] = 8'd0;
            conv_output_ch1[i] = 8'd0;
            conv_output_ch2[i] = 8'd0;
            conv_output_ch3[i] = 8'd0;
            conv_output_ch4[i] = 8'd0;
            conv_output_ch5[i] = 8'd0;
        end

        // Load input image
        $display("=== Loading Input Image ===");
        input_file = $fopen("data/image_pixels_0.txt", "r");

        if (input_file != 0) begin
            $display("Found image_pixels_0.txt, loading data...");
            for (i = 0; i < 1024; i = i + 1) begin
                scan_result = $fscanf(input_file, "%h", temp_val);
                if (scan_result == 1) begin
                    if (temp_val <= 8'hFF) begin
                        input_image[i] = $signed(temp_val);
                    end else begin
                        $display("WARNING: Invalid pixel value %h at index %0d -> force 00", temp_val, i);
                        input_image[i] = 8'sd0;
                    end
                end else begin
                    $display("Error reading pixel %0d, using 00", i);
                    input_image[i] = 8'sd0;
                end
            end
            $fclose(input_file);
            $display("Successfully loaded 1024 input pixels");

            // Count non-zero pixels
            nz_input_count = 0;
            for (i = 0; i < 1024; i = i + 1)
                if (input_image[i] != 8'h00) nz_input_count = nz_input_count + 1;
            $display("Non-zero input pixels: %0d / 1024", nz_input_count);

        end else begin
            $display("File not found! Using zeros for input.");
            for (i = 0; i < 1024; i = i + 1) begin
                input_image[i] = 8'sd0;
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize monitoring variables
        start_time = 0;
        conv_done_time = 0;
        final_done_time = 0;
        total_final_outputs = 0;
        total_conv_outputs = 0;
        conv_outputs_received = 0;
        pool_outputs_received = 0;
        consecutive_no_output = 0;

        // Initialize control signals
        reset_n = 0;
        i_start = 0;
        pixel_in_valid = 0;
        pixel_in = 0;
        i_conv_ready = 1;       // Always ready
        relu_en = 1;
        quan_en = 1;
        pixel_count = 0;
        final_output_idx = 0;
        conv_output_idx = 0;

        // Wait for initialization
        #10;

        // Reset sequence
        $display("\n=== Complete CNN C1 System Test ===");
        $display("Expected: 32x32 input -> 28x28 conv -> 14x14 final output");
        #100;
        reset_n = 1;
        #20;

        // Start system
        $display("\n=== Starting Complete System at %0t ===", $time);
        start_time = $time;
        i_start = 1;
        #20;
        i_start = 0;

        // Wait for weight loading completion
        wait(DUT.u_conv_layer.weights_loaded == 1);
        $display("Convolution weights loaded at %0t", $time);

        #100;

        // Start concurrent processes
        fork
            // Pixel feeding process
            begin
                pixel_count = 0;
                $display("\n=== Starting Pixel Feed ===");
                repeat(1024) begin
                    // Wait for pixel_ready
                    while (!pixel_ready) begin
                        @(posedge clk);
                    end

                    @(posedge clk);
                    pixel_in_valid = 1;
                    pixel_in = input_image[pixel_count];

                    if (pixel_count < 10 || pixel_count % 256 == 0) begin
                        $display("Fed pixel[%4d] = %3d at %0t", pixel_count, pixel_in, $time);
                    end

                    pixel_count = pixel_count + 1;
                end

                @(posedge clk);
                pixel_in_valid = 0;
                $display("Finished feeding %0d pixels at %0t", pixel_count, $time);
            end

            // Final output monitoring
            begin
                final_output_idx = 0;
                consecutive_no_output = 0;

                $display("\n=== Monitoring Final Outputs (expecting 14x14x6 = 1176 total) ===");

                while (final_output_idx < 196 && consecutive_no_output < 100000) begin
                    @(posedge clk);

                    if (final_out_valid) begin
                        if (final_output_idx < 196) begin
                            final_output_ch0[final_output_idx] = final_out_ch0;
                            final_output_ch1[final_output_idx] = final_out_ch1;
                            final_output_ch2[final_output_idx] = final_out_ch2;
                            final_output_ch3[final_output_idx] = final_out_ch3;
                            final_output_ch4[final_output_idx] = final_out_ch4;
                            final_output_ch5[final_output_idx] = final_out_ch5;

                            total_final_outputs = total_final_outputs + 1;
                            consecutive_no_output = 0;

                            if (final_output_idx < 20 || final_output_idx % 50 == 0) begin
                                $display("Final[%3d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t",
                                        final_output_idx, final_out_ch0, final_out_ch1, final_out_ch2,
                                        final_out_ch3, final_out_ch4, final_out_ch5, $time);
                            end

                            final_output_idx = final_output_idx + 1;
                        end
                    end else begin
                        consecutive_no_output = consecutive_no_output + 1;
                    end
                end

                if (consecutive_no_output >= 100000) begin
                    $display("ERROR: Stopped waiting for final outputs after %0d cycles", consecutive_no_output);
                end
            end

            // Convolution output monitoring (like original testbench)
            begin
                conv_output_idx = 0;
                $display("\n=== Monitoring Conv Outputs (expecting 28x28x6 = 4704 total) ===");

                while (conv_output_idx < 784 && !conv_layer_done) begin
                    @(posedge clk);

                    if (DUT.conv_out_valid) begin
                        if (conv_output_idx < 784) begin
                            conv_output_ch0[conv_output_idx] = DUT.conv_out_ch0;
                            conv_output_ch1[conv_output_idx] = DUT.conv_out_ch1;
                            conv_output_ch2[conv_output_idx] = DUT.conv_out_ch2;
                            conv_output_ch3[conv_output_idx] = DUT.conv_out_ch3;
                            conv_output_ch4[conv_output_idx] = DUT.conv_out_ch4;
                            conv_output_ch5[conv_output_idx] = DUT.conv_out_ch5;

                            total_conv_outputs = total_conv_outputs + 1;

                            if (conv_output_idx < 15 || conv_output_idx > 770) begin
                                $display("Conv[%3d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h at %0t",
                                        conv_output_idx, DUT.conv_out_ch0, DUT.conv_out_ch1, DUT.conv_out_ch2,
                                        DUT.conv_out_ch3, DUT.conv_out_ch4, DUT.conv_out_ch5, $time);
                            end

                            conv_output_idx = conv_output_idx + 1;
                        end
                        conv_outputs_received = conv_outputs_received + 1;
                    end
                end
                conv_done_time = $time;
                $display("Convolution layer completed at %0t (received %0d conv outputs)",
                        conv_done_time, conv_outputs_received);
            end

            // Pool output monitoring
            begin
                while (!o_done) begin
                    @(posedge clk);
                    if (DUT.pool_valid) begin
                        pool_outputs_received = pool_outputs_received + 1;
                    end
                end
            end
        join

        // Wait for overall completion
        $display("\n=== Waiting for System Completion ===");
        wait(o_done);
        final_done_time = $time;

        // Collect any remaining outputs
        repeat(100) begin
            @(posedge clk);
            if (final_out_valid && final_output_idx < 196) begin
                final_output_ch0[final_output_idx] = final_out_ch0;
                final_output_ch1[final_output_idx] = final_out_ch1;
                final_output_ch2[final_output_idx] = final_out_ch2;
                final_output_ch3[final_output_idx] = final_out_ch3;
                final_output_ch4[final_output_idx] = final_out_ch4;
                final_output_ch5[final_output_idx] = final_out_ch5;
                final_output_idx = final_output_idx + 1;
                total_final_outputs = total_final_outputs + 1;
            end
        end

        // Save conv outputs (like original testbench)
        $display("\n=== Saving Conv Output Files (28x28) ===");

        output_file = $fopen("data/c1_output_ch0.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch0[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch0.txt");
        end

        output_file = $fopen("data/c1_output_ch1.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch1[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch1.txt");
        end

        output_file = $fopen("data/c1_output_ch2.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch2[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch2.txt");
        end

        output_file = $fopen("data/c1_output_ch3.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch3[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch3.txt");
        end

        output_file = $fopen("data/c1_output_ch4.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch4[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch4.txt");
        end

        output_file = $fopen("data/c1_output_ch5.txt", "w");
        if (output_file) begin
            for (i = 0; i < 784; i = i + 1)
                $fwrite(output_file, "%0d\n", conv_output_ch5[i]);
            $fclose(output_file);
            $display("Saved c1_output_ch5.txt");
        end

        // Save final outputs
        $display("\n=== Saving Final Output Files (14x14) ===");

        output_file = $fopen("data/c1_final_output_ch0.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch0[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch0.txt");
        end

        output_file = $fopen("data/c1_final_output_ch1.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch1[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch1.txt");
        end

        output_file = $fopen("data/c1_final_output_ch2.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch2[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch2.txt");
        end

        output_file = $fopen("data/c1_final_output_ch3.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch3[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch3.txt");
        end

        output_file = $fopen("data/c1_final_output_ch4.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch4[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch4.txt");
        end

        output_file = $fopen("data/c1_final_output_ch5.txt", "w");
        if (output_file) begin
            for (i = 0; i < 196; i = i + 1)
                $fwrite(output_file, "%0d\n", final_output_ch5[i]);
            $fclose(output_file);
            $display("Saved c1_final_output_ch5.txt");
        end

        // Comprehensive analysis
        $display("\n=== COMPREHENSIVE SYSTEM ANALYSIS ===");
        $display("Input: 32x32 = 1024 pixels");
        $display("Convolution: 28x28 = 784 pixels per channel");
        $display("Final (after maxpool): 14x14 = 196 pixels per channel");
        $display("");
        $display("Timing Analysis:");
        $display("  System start: %0t ns", start_time);
        $display("  Conv layer done: %0t ns (duration: %0t ns)", conv_done_time, conv_done_time - start_time);
        $display("  System done: %0t ns (total duration: %0t ns)", final_done_time, final_done_time - start_time);
        $display("");
        $display("Data Flow Analysis:");
        $display("  Input pixels fed: %0d", pixel_count);
        $display("  Conv outputs received: %0d (expected: 784x6 = 4704)", conv_outputs_received);
        $display("  Conv outputs stored: %0d", conv_output_idx);
        $display("  Pool outputs received: %0d", pool_outputs_received);
        $display("  Final outputs collected: %0d (expected: 196x6 = 1176)", total_final_outputs);
        $display("  Final outputs stored: %0d", final_output_idx);

        // Analyze non-zero conv outputs
        j = 0;
        for (i = 0; i < 784; i = i + 1) begin
            if (|conv_output_ch0[i] | |conv_output_ch1[i] | |conv_output_ch2[i] |
                |conv_output_ch3[i] | |conv_output_ch4[i] | |conv_output_ch5[i]) begin
                j = j + 1;
            end
        end
        $display("  Non-zero conv outputs: %0d / 784", j);

        // Analyze non-zero final outputs
        nz_final_count = 0;
        for (i = 0; i < 196; i = i + 1) begin
            if (|final_output_ch0[i] | |final_output_ch1[i] | |final_output_ch2[i] |
                |final_output_ch3[i] | |final_output_ch4[i] | |final_output_ch5[i]) begin
                nz_final_count = nz_final_count + 1;
            end
        end
        $display("  Non-zero final outputs: %0d / 196", nz_final_count);

        // Per-channel conv output analysis
        $display("\n--- Per-Channel Conv Output Analysis (28x28) ---");
        for (i = 0; i < 6; i = i + 1) begin
            j = 0;
            case (i)
                0: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch0[pixel_count] != 0) j = j + 1;
                1: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch1[pixel_count] != 0) j = j + 1;
                2: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch2[pixel_count] != 0) j = j + 1;
                3: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch3[pixel_count] != 0) j = j + 1;
                4: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch4[pixel_count] != 0) j = j + 1;
                5: for (pixel_count = 0; pixel_count < 784; pixel_count = pixel_count + 1)
                       if (conv_output_ch5[pixel_count] != 0) j = j + 1;
            endcase
            $display("Conv Channel %0d: %0d non-zero values", i, j);
        end

        // Sample Conv Outputs (like original testbench)
        $display("\n--- Sample Conv Outputs (28x28 format) ---");
        $display("First row (0-27):");
        $display("  ch0: %02h %02h %02h %02h", conv_output_ch0[0], conv_output_ch0[1], conv_output_ch0[2], conv_output_ch0[3]);
        $display("  ch1: %02h %02h %02h %02h", conv_output_ch1[0], conv_output_ch1[1], conv_output_ch1[2], conv_output_ch1[3]);
        $display("  ch5: %02h %02h %02h %02h", conv_output_ch5[0], conv_output_ch5[1], conv_output_ch5[2], conv_output_ch5[3]);

        $display("Middle (392-395):");
        $display("  ch0: %02h %02h %02h %02h", conv_output_ch0[392], conv_output_ch0[393], conv_output_ch0[394], conv_output_ch0[395]);
        $display("  ch1: %02h %02h %02h %02h", conv_output_ch1[392], conv_output_ch1[393], conv_output_ch1[394], conv_output_ch1[395]);
        $display("  ch5: %02h %02h %02h %02h", conv_output_ch5[392], conv_output_ch5[393], conv_output_ch5[394], conv_output_ch5[395]);

        $display("Last row (756-783):");
        $display("  ch0: %02h %02h %02h %02h", conv_output_ch0[780], conv_output_ch0[781], conv_output_ch0[782], conv_output_ch0[783]);
        $display("  ch1: %02h %02h %02h %02h", conv_output_ch1[780], conv_output_ch1[781], conv_output_ch1[782], conv_output_ch1[783]);
        $display("  ch5: %02h %02h %02h %02h", conv_output_ch5[780], conv_output_ch5[781], conv_output_ch5[782], conv_output_ch5[783]);

        // Per-channel final output analysis
        $display("\n--- Per-Channel Final Output Analysis (14x14) ---");
        for (i = 0; i < 6; i = i + 1) begin
            j = 0;
            case (i)
                0: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch0[pixel_count] != 0) j = j + 1;
                1: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch1[pixel_count] != 0) j = j + 1;
                2: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch2[pixel_count] != 0) j = j + 1;
                3: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch3[pixel_count] != 0) j = j + 1;
                4: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch4[pixel_count] != 0) j = j + 1;
                5: for (pixel_count = 0; pixel_count < 196; pixel_count = pixel_count + 1)
                       if (final_output_ch5[pixel_count] != 0) j = j + 1;
            endcase
            $display("Final Channel %0d: %0d non-zero values", i, j);
        end

        // Sample outputs
        $display("\n--- Sample Final Outputs (14x14 format) ---");
        $display("First row (0-13):");
        $display("  ch0: %02h %02h %02h %02h", final_output_ch0[0], final_output_ch0[1], final_output_ch0[2], final_output_ch0[3]);
        $display("  ch1: %02h %02h %02h %02h", final_output_ch1[0], final_output_ch1[1], final_output_ch1[2], final_output_ch1[3]);
        $display("  ch5: %02h %02h %02h %02h", final_output_ch5[0], final_output_ch5[1], final_output_ch5[2], final_output_ch5[3]);

        $display("Middle (98-101):");
        $display("  ch0: %02h %02h %02h %02h", final_output_ch0[98], final_output_ch0[99], final_output_ch0[100], final_output_ch0[101]);
        $display("  ch1: %02h %02h %02h %02h", final_output_ch1[98], final_output_ch1[99], final_output_ch1[100], final_output_ch1[101]);
        $display("  ch5: %02h %02h %02h %02h", final_output_ch5[98], final_output_ch5[99], final_output_ch5[100], final_output_ch5[101]);

        $display("Last row (182-195):");
        $display("  ch0: %02h %02h %02h %02h", final_output_ch0[192], final_output_ch0[193], final_output_ch0[194], final_output_ch0[195]);
        $display("  ch1: %02h %02h %02h %02h", final_output_ch1[192], final_output_ch1[193], final_output_ch1[194], final_output_ch1[195]);
        $display("  ch5: %02h %02h %02h %02h", final_output_ch5[192], final_output_ch5[193], final_output_ch5[194], final_output_ch5[195]);

        // Success criteria
        if (total_conv_outputs >= 700 && total_final_outputs >= 1000) begin
            $display("\n*** COMPLETE SUCCESS: Full CNN C1 system working! ***");
            $display("    Conv outputs: %0d (>= 700), Final outputs: %0d (>= 1000)", total_conv_outputs, total_final_outputs);
        end else if (total_conv_outputs >= 700) begin
            $display("\n*** CONV SUCCESS: Convolution layer working! ***");
            $display("    Conv outputs: %0d (>= 700), Final outputs: %0d", total_conv_outputs, total_final_outputs);
        end else if (total_final_outputs >= 500) begin
            $display("\n*** PARTIAL SUCCESS: System partially working ***");
            $display("    Conv outputs: %0d, Final outputs: %0d (>= 500)", total_conv_outputs, total_final_outputs);
        end else begin
            $display("\n*** FAILURE: System not working properly ***");
            $display("    Conv outputs: %0d, Final outputs: %0d", total_conv_outputs, total_final_outputs);
        end

        #1000;
        $finish;
    end

    // Enhanced monitoring
    always @(posedge clk) begin
        // Monitor weight loading
        if (DUT.u_conv_layer.state != DUT.u_conv_layer.IDLE && DUT.u_conv_layer.state != DUT.u_conv_layer.READY) begin
            if ($time % 2000 == 0) begin
                $display("Weight loading: state=%0d, kernel=%0d at %0t",
                        DUT.u_conv_layer.state, DUT.u_conv_layer.kernel_idx, $time);
            end
        end

        // Monitor pipeline stages
        if (o_conv_row_start) begin
            $display("*** Convolution Row %0d START at %0t ***", o_output_row, $time);
        end

        if (o_conv_row_end) begin
            $display("*** Convolution Row %0d END at %0t ***", o_output_row, $time);
        end

        // Monitor register controller state changes
        if (DUT.u_reg_controller.c_state != DUT.u_reg_controller.n_state) begin
            $display("RegCtrl state: %0d -> %0d at %0t", DUT.u_reg_controller.c_state, DUT.u_reg_controller.n_state, $time);
        end

        // Monitor convolution layer completion
        if (conv_layer_done && !DUT.conv_done_reg) begin
            $display("*** CONVOLUTION LAYER COMPLETED at %0t ***", $time);
        end
    end

    // Timeout protection
    initial begin
        #50000000;  // 50ms timeout
        $display("*** TIMEOUT: Simulation terminated after 50ms ***");
        $display("Status: conv_outputs=%0d, pool_outputs=%0d, final_outputs=%0d",
                conv_outputs_received, pool_outputs_received, total_final_outputs);
        $finish;
    end

endmodule