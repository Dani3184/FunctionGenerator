## How it works

This project implements a Direct Digital Synthesis (DDS) waveform generator.

The core of the design is a phase accumulator that continuously increases based on a programmable frequency word. The most significant bits of the phase are used to generate different waveforms.

A sine wave is generated using a lookup table (LUT), while other waveforms (sawtooth, square, triangle, and quadratic) are derived directly from the phase value.

The selected waveform is then scaled using an amplitude control and sent to an 8-bit digital output.

The design operates with a 50 MHz system clock.

---

## Control Table

### Waveform Selection (ui_in[2:0])

| Value | Waveform |
|------|----------|
| 000 | Sine |
| 001 | Sawtooth |
| 010 | Square |
| 011 | Triangle |
| 100 | Quadratic |

### Amplitude Control (ui_in[5:3])

| Value | Level |
|------|------|
| 001 | Low |
| 010 | Medium |
| 100 | High |
| 111 | Maximum |

(Note: 000 is internally mapped to avoid zero amplitude)

### Frequency Control (ui_in[7:6])

| Value | Speed |
|------|-------|
| 00 | Very Low |
| 01 | Low |
| 10 | Medium |
| 11 | High |

---

## How to test

Apply a clock signal of 50 MHz to `clk` and release reset (`rst_n = 1`).

Set the control input using:

ui_in = (freq << 6) | (amp << 3) | func

Where:
- `func` selects the waveform
- `amp` sets the amplitude
- `freq` controls the frequency

Observe the output `uo_out[7:0]`:

- With a simulator (waveform viewer)
- Or using an external DAC connected to an oscilloscope

---

## External hardware

This design requires an external DAC to visualize the waveform.

Recommended DAC characteristics:
- Resolution: 8 bits or higher
- Input: parallel digital input
- Voltage range: 0V to 3.3V
- Sampling rate: compatible with system clock

Example implementations:
- R-2R resistor ladder DAC
- External DAC IC (e.g., MCP4901)

---

## Images

### Block Diagram
![Block Diagram](block_diagram.png)

### Waveform Output
![Waveforms](waveforms.png)

### DAC Connection (optional)
![DAC](dac_connection.png)