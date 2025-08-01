
# AutoGCAS - Automatic Ground Collision Avoidance System

## Overview

This project implements a PID-based flight control system using MATLAB and Lua, targeting aileron and elevator actuation in the X-Plane simulation environment. The control logic supports both offline simulation and real-time integration. The MATLAB scripts simulate and generate control commands using recorded or live aircraft response data. The Lua script interfaces with X-Plane via datarefs to control aircraft surfaces in real time.

## Project Structure

```
PID-main/
├── deployment/
│   ├── PID.lua
│   ├── aileronGains.txt
│   ├── controlInputs.txt
│   ├── elevatorGains.txt
│   ├── outputData.txt
│   ├── plotCommandHistory.m
│   ├── setpoints.txt
│   ├── writeAileronCommands.m
│   ├── writeCommands.m
│   ├── writeElevatorCommands.m
│
├── tuning/
│   ├── aileron dir/
│   ├── elevator dir/
│   ├── rudder dir/
│   ├── throttle dir/
│   ├── loadTransientData.m
│   └── plotTransientData.m
```

## Installation

1. Install MATLAB with the Control System Toolbox.
2. Install FlyWithLua in X-Plane to support Lua script execution.
3. Clone or extract this repository into your working directory.
4. Ensure MATLAB has access to all script files and write permissions for output logging.

## Usage

### MATLAB Simulation

1. Configure `setpoints.txt` with the desired roll, pitch, yaw, and throttle setpoints.
2. Populate `aileronGains.txt` and `elevatorGains.txt` with the respective PID controller gains. Each should contain four values: `Kp`, `Ki`, `Kd`, and `N`, where `N` defines the derivative filter time constant (`Tf = 1/N`).
3. Provide aircraft feedback data in `outputData.txt`, including timestamped control variables.
4. Run `writeCommands.m` to start the control loop. It will:
   - Continuously read setpoints and feedback
   - Apply PID control logic using `writeAileronCommands` and `writeElevatorCommands`.
   - Output control commands to relevant actuator files.

### Tuning and Transient Analysis

Use the scripts in the `tuning/` directory for transient performance evaluation:

- `loadTransientData.m`: Loads simulation or logged data for analysis
- `plotTransientData.m`: Visualizes transient response, overshoot, and settling behavior

These scripts can be applied to tune PID parameters interactively by analyzing closed-loop responses.

### Visualization

After simulation, run `plotCommandHistory.m` to inspect actuator command trends, identify anomalies, and validate control behavior.

### Real-Time Simulation (X-Plane)

1. Launch X-Plane with FlyWithLua enabled.
2. Copy `PID.lua` into the FlyWithLua scripts directory.
3. The script interfaces with these control surfaces using datarefs:
   - Aileron: `sim/flightmodel/controls/rail1def`
   - Elevator: `sim/flightmodel/controls/hstab1_elv1def`, `hstab2_elv1def`
   - Rudder: `sim/flightmodel/controls/vstab1_rud1def`
4. The Lua script will issue control commands in real time using PID logic, based on setpoints and internal feedback.


### System Identification

The project includes Simulink models and system ID sessions used for identifying the plant models of the aileron and elevator channels.

- `tuning/aileron dir/aileron_SIM.slx`: Simulink model for simulating aileron dynamics
- `tuning/aileron dir/aileron_sysID.sid`: System Identification session for aileron model

- `tuning/elevator dir/elevator_SIM.slx`: Simulink model for simulating elevator dynamics
- `tuning/elevator dir/elevator_sysID.sid`: System Identification session for elevator model

These tools support frequency response analysis, validation against transient data, and refinement of closed-loop behavior before PID integration.


## Dependencies

- MATLAB (with Control System Toolbox)
- Lua (with FlyWithLua plugin for X-Plane)
- X-Plane 10 or later
