
# AutoGCAS - Automatic Ground Collision Avoidance System

## Overview

This project implements a PID-based flight control system using MATLAB and Lua, targeting aileron and elevator actuation in the X-Plane simulation environment. The control logic is designed for both offline analysis and real-time integration, with modular PID parameterization, feedback processing, and actuator command generation.

The MATLAB scripts simulate and generate control commands using recorded or simulated aircraft response data. The Lua script (`PID.lua`) directly manipulates flight simulator control surfaces by interfacing with simulator datarefs, enabling real-time PID control execution.

## Project Structure

```
PID-main/
└── deployment/
    ├── PID.lua                      # Lua script for real-time PID control in X-Plane
    ├── aileronGains.txt             # Aileron PID gains [Kp; Ki; Kd; N]
    ├── controlInputs.txt            # Optional manual control input file
    ├── elevatorGains.txt            # Elevator PID gains [Kp; Ki; Kd; N]
    ├── outputData.txt               # Logged or simulated aircraft state feedback
    ├── plotCommandHistory.m         # MATLAB script to visualize control commands
    ├── setpoints.txt                # Desired setpoints for roll, pitch, etc.
    ├── writeAileronCommands.m       # MATLAB aileron PID control and command generation
    ├── writeCommands.m              # Continuous control loop integrating command generation
    ├── writeElevatorCommands.m      # MATLAB aileron PID control and command generation
```

## Installation

1. Install MATLAB with the Control System Toolbox.
2. If using X-Plane, install FlyWithLua to support Lua script execution.
3. Extract this repository and place the `deployment/` folder in your working directory.
4. Confirm that MATLAB has access to all necessary script files and that permissions are set for file I/O.

## Usage

### MATLAB Simulation

1. Edit `setpoints.txt` to specify desired control targets (e.g., roll angle for ailerons, pitch for elevators).
2. Populate `aileronGains.txt` and `elevatorGains.txt` with the respective PID controller gains. Each should contain four values: `Kp`, `Ki`, `Kd`, and `N`, where `N` defines the derivative filter time constant (`Tf = 1/N`).
3. Place or generate flight data in `outputData.txt`, with time and control surface feedback variables.
4. Execute `writeCommands.m`. This script runs an infinite loop that:
   - Reads new setpoints and flight data.
   - Applies PID control logic using `writeAileronCommands` and `writeElevatorCommands`.
   - Outputs control commands to relevant actuator files.

### Visualization

After simulation, run `plotCommandHistory.m` to generate visual plots of command execution and control behavior over time.

### Real-Time Simulation (X-Plane)

1. Ensure X-Plane is running with FlyWithLua installed.
2. Place `PID.lua` in X-Plane’s FlyWithLua scripts directory.
3. The script will take control of the ailerons, elevators, and rudder via X-Plane datarefs:
   - `sim/flightmodel/controls/rail1def` (right aileron)
   - `sim/flightmodel/controls/hstab1_elv1def`, `hstab2_elv1def` (elevators)
   - `sim/flightmodel/controls/vstab1_rud1def` (rudder)
4. Adjust the Lua PID parameters as needed within the script or via bound input files.

## Dependencies

- MATLAB (with Control System Toolbox)
- Lua (with FlyWithLua for X-Plane integration)
- X-Plane (10+)
