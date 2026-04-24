## How it works

This project implements a Direct Digital Synthesis (DDS) waveform generator.

The core of the design is a phase accumulator that increases every clock cycle by a programmable frequency word (`freq_word`). The output frequency is proportional to this increment:

f_out ≈ (freq_word / 2^16) * f_clk

The most significant bits of the phase are used to generate different waveforms.

A sine wave is generated using a lookup table (LUT), while other waveforms (sawtooth, square, triangle, and quadratic) are derived directly from the phase value.

The selected waveform is then scaled using an amplitude control and sent to an 8-bit digital output.

The design operates with a 50 MHz system clock.

---

## Control Table (ui_in[7:0])

The 8-bit input is divided as follows:

[7:6] → Frequency control  
[5:3] → Amplitude control  
[2:0] → Waveform selection  

---

### Waveform Selection (ui_in[2:0])

| Bits        | Function   |
|------------|-----------|
| xxx xxx 000 | Sine      |
| xxx xxx 001 | Sawtooth  |
| xxx xxx 010 | Square    |
| xxx xxx 011 | Triangle  |
| xxx xxx 100 | Quadratic |

---

### Frequency Control (ui_in[7:6])

| Bits        | freq_word | Description        |
|------------|----------|--------------------|
| 00 xxx xxx | 1000     | Low frequency      |
| 01 xxx xxx | 5000     | Medium-low         |
| 10 xxx xxx | 15000    | Medium-high        |
| 11 xxx xxx | 30000    | High frequency     |

Note: The output frequency depends on:

f_out ≈ (freq_word / 65536) * f_clk

---

### Amplitude Control (ui_in[5:3])

| Bits        | Level    |
|------------|---------|
| xxx 001 xxx | Low     |
| xxx 010 xxx | Medium  |
| xxx 100 xxx | High    |
| xxx 111 xxx | Maximum |

Note: `000` is internally remapped to avoid zero amplitude.

---

## How to test

Apply a 50 MHz clock to `clk` and release reset (`rst_n = 1`).

Set the control input using:

ui_in = (freq << 6) | (amp << 3) | func

Where:
- `func` selects the waveform
- `amp` sets the amplitude
- `freq` controls the frequency

Observe the output `uo_out[7:0]`:
- In simulation (waveform viewer)
- Or using an external DAC and oscilloscope

### Simulation in Vivado
1. Run the behavioral simulation using `tb.v`.
2. To see the waveforms exactly as shown in the documentation, open the configuration file:
   `sim/main_waveform_config.wcfg`
   
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
