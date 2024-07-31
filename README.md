# Fitness_Tracker_Analyzer
# Fitness Tracker Analyzer

## Overview

The Fitness Tracker Analyzer project is a Verilog-based design for tracking fitness metrics, specifically steps and distance. The system is built to target the XC7A100T-1CSG324C device and includes modules for pulse generation, step counting, BCD conversion, and seven-segment display driving.

## Modules

### 1. FitBit_Tracker
This module tracks the number of steps and calculates the overflow status when the step count exceeds the maximum value. It also computes the distance based on the steps taken.

#### Inputs
- `PULSE`: Pulse signal indicating a step.
- `CLK`: System clock.
- `RESET`: Reset signal.

#### Outputs
- `STEPS`: 14-bit register representing the step count.
- `OFLOW`: Overflow flag.
- `DISTANCE`: 5-bit wire representing the distance.

### 2. PULSE_Generator
Generates a pulse based on the selected mode, start, and stop signals.

#### Inputs
- `MODE`: Mode selection (2-bit).
- `STOP`: Stop signal.
- `START`: Start signal.
- `CLK`: System clock.
- `RST`: Reset signal.

#### Outputs
- `PULSE`: Pulse output.

### 3. seg_driver
Drives a seven-segment display to show BCD digits.

#### Inputs
- `bcd`: 16-bit BCD input.
- `dot`: Dot enable signal.
- `clk`: System clock.

#### Outputs
- `cathode`: Cathode signals for the seven-segment display.
- `anode`: Anode signals for the seven-segment display.

### 4. bcd_seven
Converts a 4-bit BCD value to a seven-segment display format.

#### Inputs
- `bcd`: 4-bit BCD input.
- `dot`: Dot enable signal.

#### Outputs
- `segs_with_dp`: 8-bit output for seven-segment display with dot.

### 5. binarytobcd
Converts a binary number to BCD format.

#### Inputs
- `binary`: 14-bit binary input.
- `start`: Start signal.
- `clk`: System clock.

#### Outputs
- `done`: Done signal.
- `bcd`: 16-bit BCD output.

### 6. fitbit
Main module integrating the above components to create the fitness tracker.

#### Inputs
- `clk`: System clock.
- `start`: Start signal.
- `stop`: Stop signal.
- `reset`: Reset signal.
- `mode`: Mode selection (2-bit).

#### Outputs
- `oflow`: Overflow flag.
- `cathode`: Cathode signals for the seven-segment display.
- `anode`: Anode signals for the seven-segment display.

### 7. debouncer
Debounces input signals to avoid spurious changes.

#### Inputs
- `clk`: System clock.
- `rst`: Reset signal.
- `i_sig`: Input signal.

#### Outputs
- `o_sig_debounced`: Debounced output signal.

## Dependencies

None specified.

## Usage

1. **Instantiate the `fitbit` module** in your top-level design file.
2. **Connect the inputs and outputs** as required for your application.
3. **Program the target device** (XC7A100T-1CSG324C) using appropriate FPGA programming tools.

## Additional Comments

- Ensure proper clock signal management to avoid timing issues.
- Verify the reset functionality to ensure the system initializes correctly.
