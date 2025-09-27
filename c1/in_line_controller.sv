// COMPLETELY FIXED: in_line_controller for 32x32 -> 28x28 5x5 convolution
module in_line_controller(
    input                 clk,
    input                 reset_n,        
    input                 i_start,      
    output reg            o_done,         
    input                 pixel_in_valid,
    input      [7:0]      pixel_in,
    output reg            o_conv_valid,   
    input                 i_conv_ready,   
    output reg            o_conv_row_start, 
    output reg            o_conv_row_end,   
    
    output reg signed [7:0] window_0_0, window_0_1, window_0_2, window_0_3, window_0_4,
    output reg signed [7:0] window_1_0, window_1_1, window_1_2, window_1_3, window_1_4,
    output reg signed [7:0] window_2_0, window_2_1, window_2_2, window_2_3, window_2_4,
    output reg signed [7:0] window_3_0, window_3_1, window_3_2, window_3_3, window_3_4,
    output reg signed [7:0] window_4_0, window_4_1, window_4_2, window_4_3, window_4_4,

    output     [2:0]      o_read_base_ptr,
    output     [2:0]      o_write_ptr,
    output     [3:0]      o_current_state,
    output     [4:0]      o_window_col,
    output     [4:0]      o_output_row_cnt
);

    // SIMPLIFIED STATE MACHINE
    localparam S_IDLE        = 4'd0;
    localparam S_LOAD_INIT   = 4'd1;  // Load first 6 rows (0-5) for initial window
    localparam S_CONV_ROW    = 4'd2;  // Process convolution row
    localparam S_ROLL        = 4'd3;  // Roll to next row  
    localparam S_FINISH      = 4'd4;  

    reg [3:0] state, next_state;
    reg [7:0] line_buffer [0:5][0:31];  // 6 line buffers, 32 pixels each
    
    // Control registers
    reg [2:0] rd_base_ptr;      // Base pointer for reading 5x5 windows
    reg [2:0] wr_ptr;           // Write pointer (which line to write next)
    reg [4:0] wr_col_cnt;       // Column counter for writing
    reg [4:0] win_col;          // Window column position (0-27)
    reg [4:0] out_row;          // Output row counter (0-27)
    reg [5:0] next_ifm_row;     // Next input feature map row to read (0-31)
    
    // Flow control
    reg row_complete;           // Current row processing complete
    reg prefetch_needed;        // Need to prefetch next row
    reg prefetch_done;          // Prefetch completed
    
    integer i, j;
    
    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (i_start) next_state = S_LOAD_INIT;
            end
            
            S_LOAD_INIT: begin
                // Wait until we have loaded 6 complete rows (rows 0-5)
                if (pixel_in_valid && wr_col_cnt == 31 && next_ifm_row == 4) begin
                    next_state = S_CONV_ROW;
                end
            end
            
            S_CONV_ROW: begin
                if (row_complete) begin
                    if (out_row < 27) begin
                        next_state = S_ROLL;
                    end else begin
                        next_state = S_FINISH;
                    end
                end
            end

            S_ROLL: begin
                // 프리페치가 필요한 경우, 완료될 때까지 대기
                if (prefetch_needed && !prefetch_done) begin
                    next_state = S_ROLL; // 대기 상태 유지
                end else begin
                    next_state = S_CONV_ROW; // 다음 행으로 진행
                end
            end
            
            S_FINISH: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (!reset_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Main control logic
    always @(posedge clk) begin
        if (!reset_n) begin
            // Reset all control signals
            o_done <= 1'b0;
            o_conv_valid <= 1'b0;
            o_conv_row_start <= 1'b0;
            o_conv_row_end <= 1'b0;
            
            // Reset pointers and counters
            rd_base_ptr <= 3'd0;
            wr_ptr <= 3'd0;
            wr_col_cnt <= 5'd0;
            win_col <= 5'd0;
            out_row <= 5'd0;
            next_ifm_row <= 6'd0;
            
            // Reset flags
            row_complete <= 1'b0;
            prefetch_needed <= 1'b0;
            prefetch_done <= 1'b0;
            
            // Initialize line buffer to zeros
            for (i = 0; i < 6; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    line_buffer[i][j] <= 8'd0;
                end
            end
            
            // Initialize window outputs
            {window_0_0, window_0_1, window_0_2, window_0_3, window_0_4} <= 40'sd0;
            {window_1_0, window_1_1, window_1_2, window_1_3, window_1_4} <= 40'sd0;
            {window_2_0, window_2_1, window_2_2, window_2_3, window_2_4} <= 40'sd0;
            {window_3_0, window_3_1, window_3_2, window_3_3, window_3_4} <= 40'sd0;
            {window_4_0, window_4_1, window_4_2, window_4_3, window_4_4} <= 40'sd0;
            
        end else begin
            // Default signal states
            o_conv_row_start <= 1'b0;
            o_conv_row_end <= 1'b0;
            
            case (state)
                S_IDLE: begin
                    o_done <= 1'b0;
                    o_conv_valid <= 1'b0;
                    if (i_start) begin
                        // Initialize for new convolution
                        rd_base_ptr <= 3'd0;
                        wr_ptr <= 3'd0;
                        wr_col_cnt <= 5'd0;
                        win_col <= 5'd0;
                        out_row <= 5'd0;
                        next_ifm_row <= 6'd0;
                        row_complete <= 1'b0;
                        prefetch_needed <= 1'b0;
                        prefetch_done <= 1'b0;
                        
                        $display("=== STARTING CONVOLUTION ===");
                        $display("Loading initial 6 rows at %0t", $time);
                    end
                end
                
                S_LOAD_INIT: begin
                    o_conv_valid <= 1'b0;
                    if (pixel_in_valid) begin
                        // Load pixel into current position
                        line_buffer[next_ifm_row][wr_col_cnt] <= pixel_in;
                        
                        // Debug: Print non-zero pixels
                        if (pixel_in != 8'd0) begin
                            $display("Loading: row=%d, col=%d, val=%02h at %0t", 
                                    next_ifm_row, wr_col_cnt, pixel_in, $time);
                        end
                        
                        // Update counters
                        if (wr_col_cnt == 31) begin
                            // Complete row loaded
                            wr_col_cnt <= 5'd0;
                            next_ifm_row <= next_ifm_row + 1;
                            $display("Completed loading row %d at %0t", next_ifm_row, $time);
                            
                            // Check if initial loading is complete
                            if (next_ifm_row == 4) begin // ** if 5, fetch 6lines / if 4, fetch 5lines? **
                                $display("=== INITIAL LOADING COMPLETE ===");
                                $display("Rows 0-4 loaded, starting convolution");
                                
                                // Prepare for convolution
                                win_col <= 5'd0;
                                wr_ptr <= 3'd5;  // Next write will be to line 5 (circular)
                                next_ifm_row <= 6'd5;  // Next input row will be row 5
                                prefetch_needed <= 1'b1;  // Will need to prefetch row 5
                                o_conv_row_start <= 1'b1;
                                $display("Completed prepare variables %d at %0t", next_ifm_row, $time);
                                
                                // Debug: Show loaded data
                                for (i = 0; i < 6; i = i + 1) begin
                                    $display("Row %0d: %02h %02h %02h %02h ...", i,
                                            line_buffer[i][0], line_buffer[i][1], 
                                            line_buffer[i][2], line_buffer[i][3]);
                                end
                            end
                        end else begin
                            wr_col_cnt <= wr_col_cnt + 1;
                        end
                    end
                end
                
                S_CONV_ROW: begin
                    // Handle convolution and prefetching
                    if (i_conv_ready && !row_complete) begin
                        // Generate 5x5 window
                        window_0_0 <= $signed(line_buffer[(rd_base_ptr + 0) % 6][win_col + 0]);
                        window_0_1 <= $signed(line_buffer[(rd_base_ptr + 0) % 6][win_col + 1]);
                        window_0_2 <= $signed(line_buffer[(rd_base_ptr + 0) % 6][win_col + 2]);
                        window_0_3 <= $signed(line_buffer[(rd_base_ptr + 0) % 6][win_col + 3]);
                        window_0_4 <= $signed(line_buffer[(rd_base_ptr + 0) % 6][win_col + 4]);
                        
                        window_1_0 <= $signed(line_buffer[(rd_base_ptr + 1) % 6][win_col + 0]);
                        window_1_1 <= $signed(line_buffer[(rd_base_ptr + 1) % 6][win_col + 1]);
                        window_1_2 <= $signed(line_buffer[(rd_base_ptr + 1) % 6][win_col + 2]);
                        window_1_3 <= $signed(line_buffer[(rd_base_ptr + 1) % 6][win_col + 3]);
                        window_1_4 <= $signed(line_buffer[(rd_base_ptr + 1) % 6][win_col + 4]);
                        
                        window_2_0 <= $signed(line_buffer[(rd_base_ptr + 2) % 6][win_col + 0]);
                        window_2_1 <= $signed(line_buffer[(rd_base_ptr + 2) % 6][win_col + 1]);
                        window_2_2 <= $signed(line_buffer[(rd_base_ptr + 2) % 6][win_col + 2]);
                        window_2_3 <= $signed(line_buffer[(rd_base_ptr + 2) % 6][win_col + 3]);
                        window_2_4 <= $signed(line_buffer[(rd_base_ptr + 2) % 6][win_col + 4]);
                        
                        window_3_0 <= $signed(line_buffer[(rd_base_ptr + 3) % 6][win_col + 0]);
                        window_3_1 <= $signed(line_buffer[(rd_base_ptr + 3) % 6][win_col + 1]);
                        window_3_2 <= $signed(line_buffer[(rd_base_ptr + 3) % 6][win_col + 2]);
                        window_3_3 <= $signed(line_buffer[(rd_base_ptr + 3) % 6][win_col + 3]);
                        window_3_4 <= $signed(line_buffer[(rd_base_ptr + 3) % 6][win_col + 4]);
                        
                        window_4_0 <= $signed(line_buffer[(rd_base_ptr + 4) % 6][win_col + 0]);
                        window_4_1 <= $signed(line_buffer[(rd_base_ptr + 4) % 6][win_col + 1]);
                        window_4_2 <= $signed(line_buffer[(rd_base_ptr + 4) % 6][win_col + 2]);
                        window_4_3 <= $signed(line_buffer[(rd_base_ptr + 4) % 6][win_col + 3]);
                        window_4_4 <= $signed(line_buffer[(rd_base_ptr + 4) % 6][win_col + 4]);
                        
                        o_conv_valid <= 1'b1;
                        
                        // Debug first few windows
                        if (out_row < 3 && win_col < 5) begin
                            $display("=== Window [%d,%d] at %0t ===", out_row, win_col, $time);
                            $display("Center: %02h (row %0d, col %0d)", 
                                    line_buffer[(rd_base_ptr + 2) % 6][win_col + 2], 
                                    (rd_base_ptr + 2) % 6, win_col + 2);
                        end
                        
                        // Check if row is complete
                        if (win_col == 27) begin
                            o_conv_row_end <= 1'b1;
                            row_complete <= 1'b1;
                            
                            $display("Row %0d completed at %0t", out_row, $time);
                        end else begin
                            win_col <= win_col + 1;
                        end
                        
                    end else begin
                        o_conv_valid <= 1'b0;
                    end
                    
                    // Handle prefetching of next row
                    if (prefetch_needed && !prefetch_done && pixel_in_valid && next_ifm_row < 32) begin
                        line_buffer[wr_ptr][wr_col_cnt] <= pixel_in;
                        
                        if (pixel_in != 8'd0) begin
                            $display("Prefetch: row=%d->line=%d, col=%d, val=%02h at %0t", 
                                    next_ifm_row, wr_ptr, wr_col_cnt, pixel_in, $time);
                        end
                        
                        if (wr_col_cnt == 31) begin
                            wr_col_cnt <= 5'd0;
                            next_ifm_row <= next_ifm_row + 1;
                            prefetch_done <= 1'b1;
                            $display("Prefetch completed: row %d into line %d at %0t", 
                                    next_ifm_row, wr_ptr, $time);
                        end else begin
                            wr_col_cnt <= wr_col_cnt + 1;
                        end
                    end
                end
                
                S_ROLL: begin
                    o_conv_valid <= 1'b0;

                    // 프리페치가 필요하고 아직 완료되지 않은 경우 대기
                    if (prefetch_needed && !prefetch_done) begin
                        $display("=== WAITING FOR PREFETCH TO COMPLETE ===");
                        $display("Waiting for row %d prefetch to line %d (col=%d) at %0t",
                                next_ifm_row, wr_ptr, wr_col_cnt, $time);

                        // 프리페치 계속 진행
                        if (pixel_in_valid && next_ifm_row < 32) begin
                            line_buffer[wr_ptr][wr_col_cnt] <= pixel_in;

                            if (pixel_in != 8'd0) begin
                                $display("Prefetch in ROLL: row=%d->line=%d, col=%d, val=%02h at %0t",
                                        next_ifm_row, wr_ptr, wr_col_cnt, pixel_in, $time);
                            end

                            if (wr_col_cnt == 31) begin
                                wr_col_cnt <= 5'd0;
                                wr_ptr <= (wr_ptr + 1) % 6;
                                next_ifm_row <= next_ifm_row + 1;
                                prefetch_done <= 1'b1;
                                $display("Prefetch completed in ROLL: row %d into line %d at %0t",
                                        next_ifm_row, wr_ptr, $time);
                            end else begin
                                wr_col_cnt <= wr_col_cnt + 1;
                            end
                        end
                    end else begin
                        // 프리페치 완료 또는 불필요한 경우 다음 행으로 진행
                        row_complete <= 1'b0;

                        $display("=== ROLLING TO NEXT ROW ===");
                        $display("out_row: %d->%d, rd_base_ptr: %d->%d, wr_ptr: %d->%d at %0t",
                                 out_row, out_row+1, rd_base_ptr, (rd_base_ptr+1)%6, wr_ptr, (wr_ptr+1)%6, $time);

                        // Update all pointers atomically
                        out_row <= out_row + 1;
                        rd_base_ptr <= (rd_base_ptr + 1) % 6;
                        win_col <= 5'd0;

                        // Set up for next row
                        if (out_row < 27) begin
                            // 더 이상 프리페치할 입력 행이 없으면 프리페치 불필요
                            if (next_ifm_row >= 32) begin
                                prefetch_needed <= 1'b0;
                                prefetch_done <= 1'b1; // 이미 완료된 것으로 처리
                            end else begin
                                prefetch_needed <= 1'b1;
                                prefetch_done <= 1'b0;
                            end
                            o_conv_row_start <= 1'b1;
                        end
                    end
                end
                
                S_FINISH: begin
                    o_conv_valid <= 1'b0;
                    o_done <= 1'b1;
                    row_complete <= 1'b0;
                    prefetch_needed <= 1'b0;
                    prefetch_done <= 1'b0;
                    
                    $display("=== CONVOLUTION FINISHED ===");
                    $display("All 28x28 outputs generated at %0t", $time);
                end
            endcase
        end
    end
    
    // Debug output assignments
    assign o_read_base_ptr = rd_base_ptr;
    assign o_write_ptr = wr_ptr;
    assign o_current_state = state;
    assign o_window_col = win_col;
    assign o_output_row_cnt = out_row;

endmodule