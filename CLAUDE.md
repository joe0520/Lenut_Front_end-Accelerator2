# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a hardware accelerator project implementing a CNN (Convolutional Neural Network) Layer 1 (C1) in Verilog/SystemVerilog. The project focuses on LeNet-style CNN acceleration with 5x5 convolution operations on 32x32 input images producing 28x28 feature maps across 6 output channels.

## Architecture

### Key Components

- **Convolution Processing Element (`conv_pe_5x5`)**: Implements 5x5 convolution with 25 parallel multiply-accumulate units, ReLU activation, and quantization
- **Line Buffer Controller (`in_line_controller`)**: Manages streaming 32x32 input data and generates 5x5 sliding windows for convolution
- **Weight Memory (`c1_weight_memory`)**: Stores and provides access to 6 sets of 5x5 convolution kernels
- **Top-level Integration (`c1_layer_top`)**: Orchestrates weight loading, data flow, and multi-channel processing

### Data Flow

1. **Weight Loading Phase**: Sequential loading of 6 convolution kernels (25 weights each) from memory
2. **Input Streaming**: 32x32 pixel data streamed into line buffer controller
3. **Window Generation**: Controller generates 5x5 windows sliding across the input to produce 28x28 outputs
4. **Parallel Processing**: 6 processing elements operate in parallel, each with different kernel weights
5. **Output Generation**: Produces 6 channels of 28x28 quantized feature maps

### Directory Structure

- `c1/`: Core convolution layer implementation
  - `convolution_PU_improved.v`: 5x5 convolution processing element
  - `in_line_controller.sv`: Input streaming and windowing controller
  - `c1_weight_memory.v`: Weight storage and access
  - `image_pixels_0.txt`, `layer_1_output.txt`: Test data files
  - `c1_weights.hex`: Hexadecimal weight data
- `test1/`: Vivado project files
  - `test1.srcs/sources_1/new/c1_layer_top.v`: Top-level integration module
- `weights/`: Weight data files

## Development Workflow

### Hardware Simulation

Since this is a hardware design project, testing is typically done through:
- **Verilog Testbenches**: Create testbench files to simulate module behavior
- **Vivado Simulation**: Use Xilinx Vivado for RTL simulation and synthesis
- **ModelSim/QuestaSim**: Alternative simulation tools for verification

### Common Development Commands

```bash
# No traditional build system - this is pure hardware description
# Development typically uses Vivado IDE or command-line tools

# For Vivado command-line (if available):
vivado -mode batch -source build_script.tcl

# For simulation with other tools:
vlog *.v *.sv  # Compile Verilog/SystemVerilog
vsim top_module  # Start simulation
```

### Code Conventions

- **Verilog/SystemVerilog Standards**: Follows industry-standard RTL design practices
- **Naming**: 
  - Modules use lowercase with underscores (`conv_pe_5x5`, `in_line_controller`)
  - Signals use descriptive names (`pixel_in_valid`, `weight_ch0`)
  - Parameters use UPPERCASE (`S_IDLE`, `READY`)
- **Port Ordering**: Input clk/reset first, followed by data/control signals
- **Debug Signals**: Extensive use of `$display` for simulation debugging
- **State Machines**: Clear state encoding with descriptive state names

### Key Design Parameters

- **Input Size**: 32x32 pixels, 8-bit unsigned
- **Kernel Size**: 5x5 convolution, 8-bit signed weights  
- **Output Size**: 28x28 pixels per channel, 8-bit quantized
- **Channels**: 6 parallel output channels
- **Quantization**: Division by 128 with rounding and saturation

### Testing Strategy

- Input test vectors in `image_pixels_0.txt`
- Expected outputs in `layer_1_output.txt` 
- Extensive debug logging throughout simulation
- State machine verification through debug outputs
- Timing verification for pipelined operations

## Files You Should Not Modify

- Test data files (`*.txt`, `*.hex`) - these contain reference data for verification
- Vivado project files - typically auto-generated and managed by IDE