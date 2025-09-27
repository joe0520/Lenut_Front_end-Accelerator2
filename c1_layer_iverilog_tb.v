`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Testbench for C1 Layer Top Module - iVerilog Compatible
// Tests the complete CNN C1 layer implementation using iVerilog
//////////////////////////////////////////////////////////////////////////////////

module c1_layer_iverilog_tb();

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
    reg [7:0] expected_output [0:783];  // 28x28 expected output (channel 0 only)
    reg [7:0] actual_output [0:783];    // Store actual results

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

    // Load Test Data - iVerilog compatible method
    initial begin
        // Initialize arrays
        for (i = 0; i < 1024; i = i + 1) begin
            input_image[i] = 8'h00;
        end
        for (i = 0; i < 784; i = i + 1) begin
            expected_output[i] = 8'h00;
            actual_output[i] = 8'h00;
        end

        // Load input image data
        $readmemh("../Lenut_Front_end-Accelerator2/c1/image_pixels_0.txt", input_image);
        $display("Loaded input image data");

        // Load expected output data
        $readmemh("../Lenut_Front_end-Accelerator2/c1/layer_1_output.txt", expected_output);
        $display("Loaded expected output data");

        // Initialize variables
        pixel_count = 0;
        output_count = 0;
        error_count = 0;
    end

    // Test Sequence
    initial begin
        $display("=== C1 Layer iVerilog Testbench Started ===");

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

        // Wait for weight loading to complete
        $display("Waiting for weight loading...");
        repeat(100) @(posedge clk);

        // Feed input pixels
        $display("Starting pixel input feeding...");
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

        // Monitor outputs until done or we get enough outputs
        $display("Monitoring outputs...");
        while (!o_done || output_count < 784) begin
            @(posedge clk);
            if (out_valid && output_count < 784) begin
                // Store only channel 0 output for comparison
                actual_output[output_count] = out_ch0;

                // Debug: Print first 20 and around problematic area (90-95)
                if (output_count < 20 || (output_count >= 90 && output_count <= 95)) begin
                    $display("Output[%0d]: ch0=%02h ch1=%02h ch2=%02h ch3=%02h ch4=%02h ch5=%02h (row=%0d, col=%0d) at %0t",
                            output_count, out_ch0, out_ch1, out_ch2, out_ch3, out_ch4, out_ch5,
                            o_output_row, o_window_col, $time);
                end

                output_count = output_count + 1;
            end

            // Safety timeout - if o_done is asserted, wait a bit more for final outputs
            if (o_done && output_count < 784) begin
                repeat(50) @(posedge clk);
                if (output_count < 784) begin
                    $display("Waiting for remaining outputs... (got %0d, need 784)", output_count);
                    // Wait more or exit if no more outputs come
                    repeat(100) @(posedge clk);
                end
            end
        end

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

        $display("=== iVerilog Testbench Complete ===");
        $finish;
    end

    // Result Verification Task
    task verify_results;
        begin
            $display("\n=== Verifying Results ===");

            // Compare outputs with expected values
            for (i = 0; i < 784 && i < output_count; i = i + 1) begin
                if (actual_output[i] !== expected_output[i]) begin
                    $display("MISMATCH at output %0d: expected=%02h, actual=%02h (row=%0d, col=%0d)",
                            i, expected_output[i], actual_output[i], i/28, i%28);
                    error_count = error_count + 1;

                    // Stop after finding too many errors
                    if (error_count >= 20) begin
                        $display("Too many errors, stopping verification...");
                        i = 784; // Break the loop
                    end
                end else if (i < 10 || (i >= 90 && i <= 95)) begin
                    // Print first 10 and problematic area matches
                    $display("MATCH at output %0d: expected=%02h, actual=%02h",
                            i, expected_output[i], actual_output[i]);
                end
            end

            // Check if we have the right number of outputs
            if (output_count < 784) begin
                $display("ERROR: Missing outputs. Got %0d, expected 784", output_count);
                error_count = error_count + (784 - output_count);
            end

            $display("Verification complete. Total errors: %0d", error_count);
        end
    endtask

    // Timeout watchdog
    initial begin
        #50000000; // 50ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

    // Debug monitoring for key events
    always @(posedge clk) begin
        if (o_conv_row_start) begin
            $display("=== Starting convolution row %0d at time %0t ===", o_output_row, $time);
        end

        if (o_conv_row_end) begin
            $display("=== Completed convolution row %0d at time %0t ===", o_output_row, $time);
        end
    end

    // Monitor weight loading completion
    reg weights_loaded_detected;
    initial weights_loaded_detected = 0;

    always @(posedge clk) begin
        if (!weights_loaded_detected && DUT.weights_loaded) begin
            $display("=== Weights loading completed at time %0t ===", $time);
            weights_loaded_detected = 1;
        end
    end

endmodule