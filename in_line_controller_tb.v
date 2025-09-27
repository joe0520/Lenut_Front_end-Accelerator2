`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Focused Testbench for in_line_controller
// Tests the line buffer and window generation logic specifically
//////////////////////////////////////////////////////////////////////////////////

module in_line_controller_tb();

    // Clock and Reset
    reg clk;
    reg reset_n;

    // Control Signals
    reg i_start;
    wire o_done;

    // Input Interface
    reg pixel_in_valid;
    reg [7:0] pixel_in;
    reg i_conv_ready;

    // Output Interface
    wire pixel_ready;
    wire o_conv_valid;
    wire o_conv_row_start;
    wire o_conv_row_end;

    // Window Outputs
    wire signed [7:0] window_0_0, window_0_1, window_0_2, window_0_3, window_0_4;
    wire signed [7:0] window_1_0, window_1_1, window_1_2, window_1_3, window_1_4;
    wire signed [7:0] window_2_0, window_2_1, window_2_2, window_2_3, window_2_4;
    wire signed [7:0] window_3_0, window_3_1, window_3_2, window_3_3, window_3_4;
    wire signed [7:0] window_4_0, window_4_1, window_4_2, window_4_3, window_4_4;

    // Debug Outputs
    wire [2:0] o_read_base_ptr;
    wire [2:0] o_write_ptr;
    wire [3:0] o_current_state;
    wire [4:0] o_window_col;
    wire [4:0] o_output_row_cnt;

    // Test Data
    reg [7:0] test_image [0:1023]; // 32x32 test image
    integer pixel_idx;
    integer window_count;
    integer expected_windows;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // DUT Instantiation
    in_line_controller DUT (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .o_done(o_done),
        .pixel_in_valid(pixel_in_valid),
        .pixel_in(pixel_in),
        .pixel_ready(pixel_ready),
        .o_conv_valid(o_conv_valid),
        .i_conv_ready(i_conv_ready),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end),
        .window_0_0(window_0_0), .window_0_1(window_0_1), .window_0_2(window_0_2), .window_0_3(window_0_3), .window_0_4(window_0_4),
        .window_1_0(window_1_0), .window_1_1(window_1_1), .window_1_2(window_1_2), .window_1_3(window_1_3), .window_1_4(window_1_4),
        .window_2_0(window_2_0), .window_2_1(window_2_1), .window_2_2(window_2_2), .window_2_3(window_2_3), .window_2_4(window_2_4),
        .window_3_0(window_3_0), .window_3_1(window_3_1), .window_3_2(window_3_2), .window_3_3(window_3_3), .window_3_4(window_3_4),
        .window_4_0(window_4_0), .window_4_1(window_4_1), .window_4_2(window_4_2), .window_4_3(window_4_3), .window_4_4(window_4_4),
        .o_read_base_ptr(o_read_base_ptr),
        .o_write_ptr(o_write_ptr),
        .o_current_state(o_current_state),
        .o_window_col(o_window_col),
        .o_output_row_cnt(o_output_row_cnt)
    );

    // Initialize test data
    initial begin
        // Create a simple test pattern
        for (integer i = 0; i < 1024; i = i + 1) begin
            test_image[i] = (i % 256); // Simple incrementing pattern
        end

        // Add some recognizable patterns
        test_image[0] = 8'hAA;    // Top-left corner
        test_image[31] = 8'hBB;   // Top-right corner
        test_image[992] = 8'hCC;  // Bottom-left corner
        test_image[1023] = 8'hDD; // Bottom-right corner

        // Add diagonal pattern
        for (integer i = 0; i < 32; i = i + 1) begin
            test_image[i * 32 + i] = 8'hEE; // Main diagonal
        end
    end

    // Main Test Sequence
    initial begin
        $display("=== in_line_controller Testbench Started ===");

        // Initialize
        reset_n = 0;
        i_start = 0;
        pixel_in_valid = 0;
        pixel_in = 8'h00;
        i_conv_ready = 1;
        pixel_idx = 0;
        window_count = 0;
        expected_windows = 28 * 28; // 784 windows expected

        // Reset
        repeat(10) @(posedge clk);
        reset_n = 1;
        repeat(5) @(posedge clk);

        $display("Reset complete, starting test at time %0t", $time);

        // Start the controller
        i_start = 1;
        @(posedge clk);
        i_start = 0;

        // Feed pixels and monitor windows
        fork
            // Pixel feeding thread
            feed_pixels();

            // Window monitoring thread
            monitor_windows();

            // State monitoring thread
            monitor_states();
        join

        // Final checks
        if (window_count == expected_windows) begin
            $display("=== TEST PASSED: Generated %0d windows (expected %0d) ===",
                    window_count, expected_windows);
        end else begin
            $display("=== TEST FAILED: Generated %0d windows (expected %0d) ===",
                    window_count, expected_windows);
        end

        $display("=== Testbench Complete ===");
        $finish;
    end

    // Pixel Feeding Task
    task feed_pixels;
        begin
            // Wait a bit for controller to be ready
            repeat(10) @(posedge clk);

            for (pixel_idx = 0; pixel_idx < 1024; pixel_idx = pixel_idx + 1) begin
                // Only feed pixel when controller is ready to consume
                wait_for_pixel_consumption();
                @(posedge clk);
                pixel_in_valid = 1;
                pixel_in = test_image[pixel_idx];

                // Debug: Show pixel feeding for first few and special cases
                if (pixel_idx < 20 || test_image[pixel_idx] >= 8'hAA) begin
                    $display("Feeding pixel[%0d] = %02h (row=%0d, col=%0d) at %0t",
                            pixel_idx, test_image[pixel_idx], pixel_idx/32, pixel_idx%32, $time);
                end
            end

            @(posedge clk);
            pixel_in_valid = 0;
            $display("All %0d pixels fed at time %0t", pixel_idx, $time);

            // Wait for completion
            wait(o_done);
            $display("Controller signaled done at time %0t", $time);
        end
    endtask

    // Wait for Controller to be Ready for Pixel Consumption
    task wait_for_pixel_consumption;
        begin
            // Simply wait for pixel_ready signal
            while (!pixel_ready) begin
                @(posedge clk);
            end
        end
    endtask

    // Window Monitoring Task
    task monitor_windows;
        integer expected_center_row, expected_center_col, expected_idx;
        reg [7:0] expected_center_val;
        integer error_count;
        begin
            error_count = 0;
            while (!o_done) begin
                @(posedge clk);
                if (o_conv_valid) begin
                    window_count = window_count + 1;

                    // Calculate expected center pixel position
                    expected_center_row = (window_count - 1) / 28 + 2; // Add 2 for padding
                    expected_center_col = (window_count - 1) % 28 + 2; // Add 2 for padding
                    expected_idx = expected_center_row * 32 + expected_center_col;
                    expected_center_val = test_image[expected_idx];

                    // Verify center pixel
                    if (window_2_2 !== expected_center_val) begin
                        $display("ERROR: Window %0d center mismatch at (%0d,%0d). Expected: %02h, Got: %02h",
                                window_count, expected_center_row, expected_center_col, expected_center_val, window_2_2);
                        error_count = error_count + 1;
                    end

                    // Print detailed window info for first few windows and problem area
                    if (window_count <= 5 || (window_count >= 90 && window_count <= 95)) begin
                        $display("\n=== Window %0d (row=%0d, col=%0d) at time %0t ===",
                                window_count, o_output_row_cnt, o_window_col, $time);
                        $display("Row 0: %02h %02h %02h %02h %02h",
                                window_0_0, window_0_1, window_0_2, window_0_3, window_0_4);
                        $display("Row 1: %02h %02h %02h %02h %02h",
                                window_1_0, window_1_1, window_1_2, window_1_3, window_1_4);
                        $display("Row 2: %02h %02h %02h %02h %02h",
                                window_2_0, window_2_1, window_2_2, window_2_3, window_2_4);
                        $display("Row 3: %02h %02h %02h %02h %02h",
                                window_3_0, window_3_1, window_3_2, window_3_3, window_3_4);
                        $display("Row 4: %02h %02h %02h %02h %02h",
                                window_4_0, window_4_1, window_4_2, window_4_3, window_4_4);
                        $display("Center pixel: %02h", window_2_2);
                    end else if (window_count % 28 == 1) begin
                        // Print start of each row
                        $display("Window %0d: Starting row %0d, center=%02h (expected=%02h) at %0t",
                                window_count, o_output_row_cnt, window_2_2, expected_center_val, $time);
                    end
                end
            end

            // Report verification results
            if (error_count == 0) begin
                $display("=== WINDOW VERIFICATION PASSED: All %0d windows have correct center pixels ===", window_count);
            end else begin
                $display("=== WINDOW VERIFICATION FAILED: %0d errors found in %0d windows ===", error_count, window_count);
            end
        end
    endtask

    // State Monitoring Task
    task monitor_states;
        reg [3:0] prev_state;
        begin
            prev_state = 4'hF; // Invalid initial state

            while (!o_done) begin
                @(posedge clk);
                if (o_current_state != prev_state) begin
                    case (o_current_state)
                        4'd0: $display("State: IDLE at %0t", $time);
                        4'd1: $display("State: LOAD_INIT at %0t", $time);
                        4'd2: $display("State: CONV_ROW (row=%0d) at %0t", o_output_row_cnt, $time);
                        4'd3: $display("State: ROLL (rd_ptr=%0d->%0d, wr_ptr=%0d) at %0t",
                                      o_read_base_ptr, (o_read_base_ptr+1)%6, o_write_ptr, $time);
                        4'd4: $display("State: FINISH at %0t", $time);
                        default: $display("State: UNKNOWN(%0d) at %0t", o_current_state, $time);
                    endcase
                    prev_state = o_current_state;
                end

                // Monitor pointer changes
                if (o_conv_row_start) begin
                    $display("=== Row Start: row=%0d, rd_ptr=%0d, wr_ptr=%0d at %0t ===",
                            o_output_row_cnt, o_read_base_ptr, o_write_ptr, $time);
                end

                if (o_conv_row_end) begin
                    $display("=== Row End: row=%0d completed at %0t ===", o_output_row_cnt, $time);
                end
            end
        end
    endtask

    // Timeout watchdog
    initial begin
        #10000000; // 10ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

endmodule