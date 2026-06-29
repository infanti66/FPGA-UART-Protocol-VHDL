# FPGA-Based UART Protocol Controller with 16x Oversampling (VHDL)

This repository contains a modular, fully synthesizable hardware implementation of the Universal Asynchronous Receiver-Transmitter (UART) serial communication protocol written in VHDL.

## Key Features
- **Independent RX/TX FSM Engines:** Decoupled structural finite state machine modules.
- **16x Oversampling Receiver:** Eliminates asynchronous data sampling alignment mismatch by executing a majority vote at the exact structural center of incoming data frames to ensure absolute data stability.
- **Framing Error Correction:** Dedicated hardware checking (`err_led`) flags missing Stop bit configurations.
- **Dynamic Baud Rate Modularity:** Fully parameterized architecture allowing simple overrides for common frequencies (9600, 115200, etc.) based on standard crystal oscillators.

## Implementation Details
- **Simulation Platform:** Verified using ModelSim / Vivado Simulator via the included `tb_top_uart.vhd` testbench script.
- **Hardware Deployment:** Designed to be flashed onto an FPGA development board (e.g., Xilinx Spartan / Artix) and integrated with a PC terminal using standard parameters (9600 Baud, 8 Data Bits, No Parity, 1 Stop Bit).
-
