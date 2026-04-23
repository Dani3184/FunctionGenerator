# DDS Waveform Generator

## Description
This project implements a digital waveform generator based on a Direct Digital Synthesis (DDS) architecture.  
It generates multiple waveforms with programmable frequency and amplitude using an 8-bit control input.

## Clock
The design is intended to operate at a 50 MHz system clock.

## Features
- Generates:
  - Sine wave (LUT-based)
  - Sawtooth wave
  - Square wave
  - Triangle wave
  - Quadratic function
- Fully digital control via `ui_in`
- 8-bit output suitable for DAC interfacing

## Interface

### Inputs
- `clk` → system clock  
- `rst_n` → active-low reset  
- `ui_in[7:0]` → control input  

### Control Mapping
- `ui_in[2:0]` → waveform selection  
- `ui_in[5:3]` → amplitude control  
- `ui_in[7:6]` → frequency control  

### Output
- `uo_out[7:0]` → digital waveform output  

## DAC Requirements
The output is an 8-bit digital signal intended for use with an external DAC.

Recommended characteristics:
- Resolution: 8 bits or higher
- Input type: Parallel digital input
- Example: R-2R ladder DAC or external DAC IC
- Output range: 0–3.3V

## Operation
The design uses a phase accumulator (DDS) to generate periodic signals.  
The waveform is selected based on control inputs and scaled by amplitude before being sent to the output.

## Usage
The output can be connected to:
- a DAC (e.g., R-2R ladder)
- an oscilloscope
- digital signal processing systems

## Applications
- Function generators  
- Digital instrumentation  
- Embedded systems  
