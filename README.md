# SPI Master-Slave Interface in Verilog

A complete, synchronous Serial Peripheral Interface (SPI) Master and Slave system implemented in Verilog. Designed and synthesised on FPGA using Vivado. 

---

## Architecture Overview

The system consists of a Top-Level wrapper connecting an SPI Master to an SPI Slave. The communication follows standard SPI protocol (CPOL=0, CPHA=0 --> Mode 0):
* **Master** generates the `SCLK` (derived from the system clock) and drives `CS` (Chip Select) and `MOSI` (Master Out, Slave In).
* **Slave** listens to `CS`, samples data on the falling edge of `SCLK`, and pushes it into an internal shift register.

---

## Module Descriptions

### 1. SPI Master
Driven by a 4-state Moore Finite State Machine (FSM):
* **`idle`**: Waits for the `tx_enable` pulse. Initializes clock dividers.
* **`start_tx`**: Pulls `CS` low to wake the slave.
* **`tx_data`**: Transmits 8 bits of data serially over `MOSI` starting with the MSB.
* **`end_tx`**: Pulls `CS` high to terminate the transaction and returns to idle.

### 2. SPI Slave
A purely sequential shift-register-based module. 
* Activates when `CS` is low.
* Samples the `MOSI` line on the **negative edge** of `SCLK`.
* Shifts data internally: `data <= {data[6:0], mosi}`.
* Triggers a `done` signal for one clock cycle once a full byte is received.

---

## Simulation & Waveforms

The testbench (`spi_tb.v`) instantiates the Top module, generates a high-speed system clock, applies a reset, and triggers a single-byte transmission via `tx_enable`.

---

## Debugging & Lessons Learned

During the development of this RTL, several key FPGA design principles were reinforced:

* **SystemVerilog vs. Verilog-2001:** Attempted to use `typedef enum logic` for FSM states, but since Vivado was treating the file as `.v` (Standard Verilog) instead of `.sv`, it threw syntax errors. Refactored to use standard `parameter` declarations for broad compatibility.
  
* **Combinational Latches:** Initially, default values for `mosi` and `cs` were omitted in the Master FSM's `always@(*)` block, leading to inferred latches. This was resolved by explicitly assigning default values at the top of the combinational block.
  
* **State Machine Coding Styles:** Learned the critical difference between `state` and `next_state`. Modifying the current `state` inside a combinational logic block causes race conditions; transitions must only be assigned to `next_state`.
  
* **Hierarchy Expansion:** Learned to navigate Vivado's waveform viewer to expand the Top module and drag internal FSM registers (like `count` and `state`) into the viewer to understand why external timings looked sparse.

---

## Future Improvements

* **Configurable CPOL/CPHA:** Parameterise the clock polarity and phase to support all 4 standard SPI modes.
* **MISO Implementation:** Add the `MISO` (Master In, Slave Out) line to allow full-duplex, two-way communication.







