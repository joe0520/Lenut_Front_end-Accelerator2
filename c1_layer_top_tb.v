`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Testbench for C1 Layer Top Module
// Tests the complete CNN C1 layer implementation
//////////////////////////////////////////////////////////////////////////////////

module c1_layer_top_tb();

    // Clock and Reset
    reg clk;
    reg reset_n;

    // Control Signals
    reg i_start;
    wire o_done;

    // Input Interface
    reg pixel_in_valid;
    reg signed [7:0] pixel_in;
    reg i_conv_ready;

    // Configuration
    reg relu_en;
    reg quan_en;

    // Output Interface
    wire [7:0] out_ch0, out_ch1, out_ch2, out_ch3, out_ch4, out_ch5;
    wire out_valid;

    // Debug Outputs
    wire [4:0] o_window_col;
    wire [4:0] o_output_row;
    wire o_conv_row_start;
    wire o_conv_row_end;

    // Test Data Storage
    reg [7:0] input_image [0:1023];     // 32x32 input image
    reg [7:0] expected_output [0:4703]; // 28x28x6 expected output
    reg [7:0] actual_output [0:4703];   // Store actual results

    // Test Control Variables
    integer pixel_count;
    integer output_count;
    integer i, j, ch;
    integer error_count;
    integer file_handle;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // DUT Instantiation
    c1_layer_top DUT (
        .clk(clk),
        .reset_n(reset_n),
        .i_start(i_start),
        .o_done(o_done),
        .pixel_in_valid(pixel_in_valid),
        .pixel_in(pixel_in),
        .i_conv_ready(i_conv_ready),
        .relu_en(relu_en),
        .quan_en(quan_en),
        .out_ch0(out_ch0),
        .out_ch1(out_ch1),
        .out_ch2(out_ch2),
        .out_ch3(out_ch3),
        .out_ch4(out_ch4),
        .out_ch5(out_ch5),
        .out_valid(out_valid),
        .o_window_col(o_window_col),
        .o_output_row(o_output_row),
        .o_conv_row_start(o_conv_row_start),
        .o_conv_row_end(o_conv_row_end)
    );

    // Load Test Data
    initial begin
        // Load input image data
        $readmemh("c1/image_pixels_0.txt", input_image);
        $display("Loaded input image data");

        // Load expected output data
        $readmemh("c1/layer_1_output.txt", expected_output);
        $display("Loaded expected output data");

        // Initialize variables
        pixel_count = 0;
        output_count = 0;
        error_count = 0;
    end

    // Test Sequence
    initial begin
        $display("=== C1 Layer Testbench Started ===");

        // Initialize signals
        reset_n = 0;
        i_start = 0;
        pixel_in_valid = 0;
        pixel_in = 8'h00;
        i_conv_ready = 1;  // Always ready to receive convolution results
        relu_en = 1;       // Enable ReLU
        quan_en = 1;       // Enable quantization

        // Reset sequence
        repeat(10) @(posedge clk);
        reset_n = 1;
        repeat(5) @(posedge clk);

        $display("Reset complete, starting test at time %0t", $time);

        // Start the convolution process
        i_start = 1;
        @(posedge clk);
        i_start = 0;

        // Feed input pixels
        fork
            // Input pixel feeding thread
            begin
                repeat(20) @(posedge clk); // Wait for weight loading

                for (i = 0; i < 1024; i = i + 1) begin
                    @(posedge clk);
                    pixel_in_valid = 1;
                    pixel_in = $signed(input_image[i]);
                    pixel_count = pixel_count + 1;

                    // Debug: Print non-zero pixels
                    if (input_image[i] != 8'h00) begin
                        $display("Input pixel[%0d] = %02h (row=%0d, col=%0d) at %0t",
                                i, input_image[i], i/32, i%32, $time);
                    end
                end

                @(posedge clk);
                pixel_in_valid = 0;
                $display("All %0d input pixels fed at time %0t", pixel_count, $time);
            end

            // Output monitoring thread
            begin
                while (!o_done) begin
                    @(posedge clk);
                    if (out_valid) begin
                        // Store outputs for each channel
                        actual_output[output_count * 6 + 0] = out_ch0;
                        actual_output[output_count * 6 + 1] = out_ch1;
                        actual_output[output_count * 6 + 2] = out_ch2;
                        actual_output[output_count * 6 + 3] = out_ch3;
                        actual_output[output_count * 6 + 4] = out_ch4;
                        actual_output[output_count * 6 + 5] = out_ch5;

                        // Debug: Print outputs for verification
                        if (output_count < 100) begin // Print first 100 outputs
                            $display("Output[%0d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h (row=%0d, col=%0d) at %0t",
                                    output_count, out_ch0, out_ch1, out_ch2, out_ch3, out_ch4, out_ch5,
                                    o_output_row, o_window_col, $time);
                        end

                        output_count = output_count + 1;
                    end
                end
            end
        join

        $display("Convolution completed at time %0t", $time);
        $display("Total outputs generated: %0d (expected: 784)", output_count);

        // Verify results
        verify_results();

        // Test completion
        if (error_count == 0) begin
            $display("=== TEST PASSED: All outputs match expected values ===");
        end else begin
            $display("=== TEST FAILED: %0d mismatches found ===", error_count);
        end

        $display("=== Testbench Complete ===");
        $finish;
    end

    // Result Verification Task
    task verify_results;
        begin
            $display("\n=== Verifying Results ===");

            // Compare channel 0 outputs (first 784 values from expected output)
            for (i = 0; i < 784; i = i + 1) begin
                if (i < output_count) begin
                    if (actual_output[i * 6] !== expected_output[i]) begin
                        $display("MISMATCH at output %0d: expected=%02h, actual=%02h (row=%0d, col=%0d)",
                                i, expected_output[i], actual_output[i * 6], i/28, i%28);
                        error_count = error_count + 1;

                        // Stop after finding too many errors
                        if (error_count >= 10) begin
                            $display("Too many errors, stopping verification...");
                            i = 784; // Break the loop
                        end
                    end else if (i < 20) begin
                        // Print first 20 matching results
                        $display("MATCH at output %0d: expected=%02h, actual=%02h",
                                i, expected_output[i], actual_output[i * 6]);
                    end
                end else begin
                    $display("ERROR: Missing output %0d", i);
                    error_count = error_count + 1;
                end
            end

            // Write results to file for detailed analysis
            file_handle = $fopen("simulation_results.txt", "w");
            if (file_handle) begin
                $fwrite(file_handle, "=== C1 Layer Simulation Results ===\n");
                $fwrite(file_handle, "Total outputs: %0d\n", output_count);
                $fwrite(file_handle, "Error count: %0d\n", error_count);
                $fwrite(file_handle, "\nFirst 100 Channel 0 Results:\n");

                for (i = 0; i < 100 && i < output_count; i = i + 1) begin
                    $fwrite(file_handle, "Output[%3d]: Expected=%02h, Actual=%02h, Match=%s\n",
                           i, expected_output[i], actual_output[i * 6],
                           (actual_output[i * 6] == expected_output[i]) ? "YES" : "NO");
                end

                $fclose(file_handle);
                $display("Results written to simulation_results.txt");
            end
        end
    endtask

    // Timeout watchdog
    initial begin
        #50000000; // 50ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

    // Debug monitoring
    always @(posedge clk) begin
        if (o_conv_row_start) begin
            $display("=== Starting convolution row %0d at time %0t ===", o_output_row, $time);
        end

        if (o_conv_row_end) begin
            $display("=== Completed convolution row %0d at time %0t ===", o_output_row, $time);
        end
    end

endmodule