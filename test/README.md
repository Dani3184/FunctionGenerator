# Cocotb Testbench

This project uses cocotb to verify a DDS-based waveform generator.

## Requirements

Install dependencies:

pip install -r requirements.txt

## Run simulation

cd test
make

## What is tested

### Waveform generation
- Sine (LUT-based)
- Sawtooth
- Square
- Triangle
- Quadratic

### Frequency control
- 4 selectable frequency levels via ui_in[7:6]
- Verified by measuring output transition rate

### Amplitude control
- 3-bit amplitude scaling (ui_in[5:3])
- Verified by comparing signal peak values

## Expected behavior

- Output must vary over time (not constant)
- Higher frequency → more transitions per time window
- Higher amplitude → higher peak values
- Output must remain within 8-bit range (0–255)

## Clock configuration

- Clock frequency: 50 MHz
- Clock period: 20 ns

## Notes

- The testbench is fully self-checking
- Assertions are used to validate correctness
- Designed to match Tiny Tapeout verification flow