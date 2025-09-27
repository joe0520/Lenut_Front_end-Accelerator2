module c1_weight_memory(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        weight_req,          // request signal
    input  wire [2:0]  kernel_idx,          // kernel index (0~5 for 6 output channels)

    // 5x5 kernel weights outputs - FIXED: signed outputs
    output reg signed [7:0]  weight_0,
    output reg signed [7:0]  weight_1,
    output reg signed [7:0]  weight_2,
    output reg signed [7:0]  weight_3,
    output reg signed [7:0]  weight_4,
    output reg signed [7:0]  weight_5,
    output reg signed [7:0]  weight_6,
    output reg signed [7:0]  weight_7,
    output reg signed [7:0]  weight_8,
    output reg signed [7:0]  weight_9,
    output reg signed [7:0]  weight_10,
    output reg signed [7:0]  weight_11,
    output reg signed [7:0]  weight_12,
    output reg signed [7:0]  weight_13,
    output reg signed [7:0]  weight_14,
    output reg signed [7:0]  weight_15,
    output reg signed [7:0]  weight_16,
    output reg signed [7:0]  weight_17,
    output reg signed [7:0]  weight_18,
    output reg signed [7:0]  weight_19,
    output reg signed [7:0]  weight_20,
    output reg signed [7:0]  weight_21,
    output reg signed [7:0]  weight_22,
    output reg signed [7:0]  weight_23,
    output reg signed [7:0]  weight_24,

    output reg         weight_valid
);

    // Memory array - store as 8-bit unsigned, convert to signed on output
    reg [7:0] weight_mem [0:149]; // 6 kernels * 25 weights each = 150 weights
    
    // Initialize memory from hex file
    initial begin
        $readmemh("C:/Users/owner/Documents/code/Lenut_Front_end-Accelerator2//weights/c1_weights.hex", weight_mem);
        // Debug: Display weights to verify loading
        $display("Weight Memory Initialization Completed:");
        $display("Kernel 0: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem[0], weight_mem[1], weight_mem[12], weight_mem[24]);
        $display("Kernel 1: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem[25], weight_mem[26], weight_mem[37], weight_mem[49]);
        $display("Kernel 5: w0=%02x w1=%02x w12=%02x w24=%02x", 
                weight_mem[125], weight_mem[126], weight_mem[137], weight_mem[149]);
    end
    
    // FSM states
    reg [1:0] state;
    localparam IDLE = 2'b00;
    localparam LOADING = 2'b01;
    localparam READY = 2'b10;
    
    // Address calculation
    reg [7:0] base_addr;
    reg [2:0] stored_kernel_idx;
    
    // Helper function to convert unsigned to signed (two's complement interpretation)
    function signed [7:0] to_signed;
        input [7:0] unsigned_val;
        begin
            to_signed = $signed(unsigned_val);
        end
    endfunction
    
    // FSM and weight loading logic
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            weight_valid <= 1'b0;
            base_addr <= 8'd0;
            stored_kernel_idx <= 3'd0;
            
            // Initialize outputs to zero
            weight_0 <= 8'sd0;   weight_1 <= 8'sd0;   weight_2 <= 8'sd0;   weight_3 <= 8'sd0;   weight_4 <= 8'sd0;
            weight_5 <= 8'sd0;   weight_6 <= 8'sd0;   weight_7 <= 8'sd0;   weight_8 <= 8'sd0;   weight_9 <= 8'sd0;
            weight_10 <= 8'sd0;  weight_11 <= 8'sd0;  weight_12 <= 8'sd0;  weight_13 <= 8'sd0;  weight_14 <= 8'sd0;
            weight_15 <= 8'sd0;  weight_16 <= 8'sd0;  weight_17 <= 8'sd0;  weight_18 <= 8'sd0;  weight_19 <= 8'sd0;
            weight_20 <= 8'sd0;  weight_21 <= 8'sd0;  weight_22 <= 8'sd0;  weight_23 <= 8'sd0;  weight_24 <= 8'sd0;
        end
        else begin
            case (state)
                IDLE: begin
                    weight_valid <= 1'b0;
                    if (weight_req) begin
                        // Calculate base address for the requested kernel
                        base_addr <= {5'b0, kernel_idx} * 8'd25; 
                        stored_kernel_idx <= kernel_idx;
                        state <= LOADING;
                        
                        $display("Loading kernel %d weights at base_addr=%d, time=%0t", 
                                kernel_idx, {5'b0, kernel_idx} * 8'd25, $time);
                    end
                end
                
                LOADING: begin
                    // Load all 25 weights in one clock cycle with proper signed conversion
                    weight_0 <= to_signed(weight_mem[base_addr + 0]);
                    weight_1 <= to_signed(weight_mem[base_addr + 1]);
                    weight_2 <= to_signed(weight_mem[base_addr + 2]);
                    weight_3 <= to_signed(weight_mem[base_addr + 3]);
                    weight_4 <= to_signed(weight_mem[base_addr + 4]);
                    weight_5 <= to_signed(weight_mem[base_addr + 5]);
                    weight_6 <= to_signed(weight_mem[base_addr + 6]);
                    weight_7 <= to_signed(weight_mem[base_addr + 7]);
                    weight_8 <= to_signed(weight_mem[base_addr + 8]);
                    weight_9 <= to_signed(weight_mem[base_addr + 9]);
                    weight_10 <= to_signed(weight_mem[base_addr + 10]);
                    weight_11 <= to_signed(weight_mem[base_addr + 11]);
                    weight_12 <= to_signed(weight_mem[base_addr + 12]);
                    weight_13 <= to_signed(weight_mem[base_addr + 13]);
                    weight_14 <= to_signed(weight_mem[base_addr + 14]);
                    weight_15 <= to_signed(weight_mem[base_addr + 15]);
                    weight_16 <= to_signed(weight_mem[base_addr + 16]);
                    weight_17 <= to_signed(weight_mem[base_addr + 17]);
                    weight_18 <= to_signed(weight_mem[base_addr + 18]);
                    weight_19 <= to_signed(weight_mem[base_addr + 19]);
                    weight_20 <= to_signed(weight_mem[base_addr + 20]);
                    weight_21 <= to_signed(weight_mem[base_addr + 21]);
                    weight_22 <= to_signed(weight_mem[base_addr + 22]);
                    weight_23 <= to_signed(weight_mem[base_addr + 23]);
                    weight_24 <= to_signed(weight_mem[base_addr + 24]);
                    
                    state <= READY;
                    weight_valid <= 1'b1;
                    
                    // Debug: Display loaded weights
                    $display("Loaded kernel %d: w0=%d w1=%d w12=%d w24=%d (signed values)", 
                            stored_kernel_idx, 
                            to_signed(weight_mem[base_addr + 0]), 
                            to_signed(weight_mem[base_addr + 1]),
                            to_signed(weight_mem[base_addr + 12]), 
                            to_signed(weight_mem[base_addr + 24]));
                end
                
                READY: begin
                    // Keep valid high until request goes low
                    if (!weight_req) begin
                        state <= IDLE;
                        weight_valid <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule