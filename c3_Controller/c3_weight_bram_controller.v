`timescale 1ns / 1ps

module c3_weight_bram_controller(
	input clk,
	input rst_n,
	input s2_valid,
	output [199:0] s2_weight_0,
	output [199:0] s2_weight_1,
	output [199:0] s2_weight_2
);
    parameter hex_path = "C:/Users/khmga/Desktop/c3_Controller";
	reg [4:0] addr;
	reg [4:0] addr_save;

	always@(posedge clk)begin
		if(!rst_n)begin
			addr_save <= 0;
		end else if(s2_valid)begin
			addr_save <= addr_save + 1;
		end
	end

	always@(*)begin
		if(s2_valid)begin
			addr = addr_save + 1;
		end else begin
			addr = addr_save;
		end
	end

	xilinx_true_dual_port_no_change_2_clock_ram #(
		.RAM_WIDTH(200),                       // Specify RAM data width
		.RAM_DEPTH(32),                     // Specify RAM depth (number of entries)
		.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
		.INIT_FILE({hex_path,"/c3_weight_1st.hex"})                        // Specify name/location of RAM initialization file if using one (leave blank if not)
	) c3_weight_1st_bram (
		.addra(addr),   // Port A address bus, width determined from RAM_DEPTH
		.dina(),     // Port A RAM input data, width determined from RAM_WIDTH
		.clka(clk),     // Port A clock
		.wea('b0),       // Port A write enable
		.ena(s2_valid),       // Port A RAM Enable, for additional power savings, disable port when not in use
		.rsta(rst_n),     // Port A output reset (does not affect memory contents)
		.regcea('b0), // Port A output register enable
		.douta(s2_weight_0)   // Port A RAM output data, width determined from RAM_WIDTH
	);

	xilinx_true_dual_port_no_change_2_clock_ram #(
		.RAM_WIDTH(200),                       // Specify RAM data width
		.RAM_DEPTH(32),                     // Specify RAM depth (number of entries)
		.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
		.INIT_FILE({hex_path,"/c3_weight_2nd.hex"})                        // Specify name/location of RAM initialization file if using one (leave blank if not)
	) c3_weight_2nd_bram (
		.addra(addr),   // Port A address bus, width determined from RAM_DEPTH
		.dina(),     // Port A RAM input data, width determined from RAM_WIDTH
		.clka(clk),     // Port A clock
		.wea('b0),       // Port A write enable
		.ena(s2_valid),       // Port A RAM Enable, for additional power savings, disable port when not in use
		.rsta(rst_n),     // Port A output reset (does not affect memory contents)
		.regcea('b0), // Port A output register enable
		.douta(s2_weight_1)   // Port A RAM output data, width determined from RAM_WIDTH
	);

	xilinx_true_dual_port_no_change_2_clock_ram #(
		.RAM_WIDTH(200),                       // Specify RAM data width
		.RAM_DEPTH(32),                     // Specify RAM depth (number of entries)
		.RAM_PERFORMANCE("LOW_LATENCY"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
		.INIT_FILE({hex_path,"/c3_weight_3rd.hex"})                        // Specify name/location of RAM initialization file if using one (leave blank if not)
	) c3_weight_3rd_bram (
		.addra(addr),   // Port A address bus, width determined from RAM_DEPTH
		.dina(),     // Port A RAM input data, width determined from RAM_WIDTH
		.clka(clk),     // Port A clock
		.wea('b0),       // Port A write enable
		.ena(s2_valid),       // Port A RAM Enable, for additional power savings, disable port when not in use
		.rsta(rst_n),     // Port A output reset (does not affect memory contents)
		.regcea('b0), // Port A output register enable
		.douta(s2_weight_2)   // Port A RAM output data, width determined from RAM_WIDTH
	);

endmodule