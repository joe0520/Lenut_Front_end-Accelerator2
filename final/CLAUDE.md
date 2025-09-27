# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a hardware accelerator implementation for the first convolutional layer (C1) of LeNet-5 CNN, designed in Verilog. The project implements a complete CNN front-end including convolution, ReLU activation, quantization, and max pooling operations. It processes 32x32 input images through 6 parallel 5x5 convolution kernels to produce 14x14 feature maps per channel.

## Architecture

### Core Pipeline Flow

The design implements a 4-stage pipeline:

1. **Input Controller (`in_line_controller.v`)**: Streams 32x32 input pixels and generates sliding 5x5 windows for convolution
2. **Convolution Processing (`conv_pe_5x5_0927_confirm.v`)**: 6 parallel processing elements perform 5x5 convolution with ReLU and quantization
3. **Register Controller (`reg_controller_0927_confirm.v`)**: Buffers 28x28 convolution outputs into 2x2 blocks for max pooling
4. **Max Pooling (`maxpooling_0927_confirm.v`)**: Reduces 28x28 feature maps to 14x14 through 2x2 max pooling

### Key Data Flow

- **Input**: 32x32 pixels, 8-bit unsigned, streamed sequentially
- **Weights**: 6 kernels of 5x5, 8-bit signed, loaded from hexadecimal file
- **Convolution Output**: 28x28 per channel, 8-bit quantized after ReLU
- **Final Output**: 14x14 per channel, 6 channels total

### Module Hierarchy

```
c1_front_top.v (top-level integration)
├── c1_weight_memory_0927_confirm.v (weight storage/loading)
├── in_line_controller.v (input streaming & windowing)
├── conv_pe_5x5_0927_confirm.v (6x parallel convolution PEs)
├── reg_controller_0927_confirm.v (output buffering)
└── maxpooling_0927_confirm.v (2x2 max pooling)
```

## Development Workflow

### Hardware Simulation

This is a pure RTL (Register Transfer Level) design project. Development typically involves:

```bash
# Verilog compilation (tool-dependent)
vlog *.v                           # ModelSim/QuestaSim
xvlog *.v                          # Vivado Simulator
iverilog -o sim *.v                # Icarus Verilog

# Simulation execution
vsim c1_layer_tb                   # ModelSim/QuestaSim
xsim c1_layer_tb                   # Vivado Simulator
./sim                              # Icarus Verilog

# Synthesis (Vivado)
vivado -mode batch -source synth_script.tcl
```

### Test Data

The project includes comprehensive test vectors:

- `data/image_pixels_0.txt`: 32x32 input image (1024 8-bit values)
- `data/c1_weights.hex`: 150 weight values for 6 kernels (25 weights each)
- `data/layer_1_output.txt`: Expected 14x14x6 output feature maps

### Key Design Parameters

- **Clock Domain**: Single clock design with synchronous reset
- **Pipeline Depth**: 4 stages with 1-cycle latency per stage
- **Memory Requirements**: 6 line buffers (32 pixels each) + weight storage
- **Precision**: 8-bit inputs/outputs, 32-bit internal accumulation
- **Quantization**: Division by 128 with saturation to 8-bit range

## Code Conventions

### Naming Patterns

- **Modules**: lowercase with underscores (`conv_pe_5x5`, `in_line_controller`)
- **Signals**: descriptive with prefixes (`i_start`, `o_done`, `pixel_in_valid`)
- **States**: UPPERCASE with descriptive names (`S_IDLE`, `S_CONV_ROW`)
- **Arrays**: bracketed indexing (`line_buffer[0:5][0:31]`)

### Port Organization

Standard RTL port ordering:
1. Clock and reset (`clk`, `reset_n`)
2. Control signals (`i_start`, `o_done`)
3. Data inputs (`pixel_in`, `pixel_in_valid`)
4. Data outputs (`out_ch0-5`, `out_valid`)
5. Debug/status outputs

### State Machine Design

All modules use explicit state encoding with clear transitions:
- Combinational next-state logic
- Synchronous state updates
- Separate output logic blocks
- Extensive debug signal generation

## Testing Strategy

### Testbench Structure (`c1_front_top_tb.v`)

The main testbench implements:
- Clock generation (100MHz)
- Reset sequence
- Input file reading (`$readmemh` for test vectors)
- Streaming pixel input with flow control
- Output capture and verification
- Comprehensive debug monitoring

### Verification Approach

1. **Functional Testing**: Compare against golden reference outputs
2. **Timing Verification**: Ensure proper pipeline behavior
3. **Corner Cases**: Test boundary conditions and edge cases
4. **Debug Monitoring**: Extensive `$display` statements for state tracking

### Debug Features

All modules include debug outputs for:
- State machine states
- Counter values
- Pipeline stage status
- Data path intermediate values

## Common Development Tasks

### Adding New Test Cases

1. Create new input file in `data/` directory
2. Generate corresponding expected output
3. Modify testbench to load new test vectors
4. Update file I/O paths in testbench

### Modifying Pipeline Depth

1. Adjust valid signal delays in each stage
2. Update state machine timing
3. Verify data alignment across pipeline
4. Update testbench timing expectations

### Weight Updates

1. Modify `data/c1_weights.hex` with new values
2. Ensure proper 2's complement format for signed weights
3. Verify weight loading sequence in `c1_weight_memory_0927_confirm.v`