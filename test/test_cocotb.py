import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

#Reset
async def reset(dut):
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

#For N cycles
async def run_cycles(dut, cycles=200):
    values = []
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        values.append(int(dut.uo_out.value))
    return values

#Main Test
@cocotb.test()
async def full_test(dut):

    # Clock 100 MHz (10 ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    await reset(dut)

#Waveform Tests
    configs = [
        ("SINE",       0b000_100_01),
        ("SAW",        0b001_111_10),
        ("SQUARE",     0b010_111_11),
        ("TRIANGLE",   0b011_011_10),
        ("QUADRATIC",  0b100_111_01),
    ]

    for name, config in configs:
        dut.ui_in.value = config
        values = await run_cycles(dut, 300)

        # Check signal is not constant
        unique_vals = len(set(values))
        assert unique_vals > 5, f"{name} waveform not changing"

        dut._log.info(f"{name} OK | unique values: {unique_vals}")

#Frequency
    dut._log.info("Testing frequency sweep")

    dut.ui_in.value = 0b000_100_00  # sine + fixed amp

    changes_per_freq = []

    for freq in range(4):
        dut.ui_in.value = (freq << 6) | (0b100 << 3) | 0b000

        values = await run_cycles(dut, 200)

        changes = sum(1 for i in range(1, len(values)) if values[i] != values[i-1])
        changes_per_freq.append(changes)

        dut._log.info(f"Freq {freq}: {changes} changes")

    assert changes_per_freq[0] < changes_per_freq[-1], "Frequency control failed"

#Amplitude Sweep
    dut._log.info("Testing amplitude sweep")

    dut.ui_in.value = 0b000_001_01  # low amplitude
    low_vals = await run_cycles(dut, 200)

    dut.ui_in.value = 0b000_111_01  # high amplitude
    high_vals = await run_cycles(dut, 200)

    assert max(high_vals) > max(low_vals), "Amplitude scaling failed"

    dut._log.info("Amplitude scaling OK")

    dut._log.info("ALL TESTS PASSED")