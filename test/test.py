import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.utils import get_sim_time


async def reset(dut):
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


async def run_cycles(dut, cycles=200):
    values = []
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        values.append(int(dut.uo_out.value))
    return values


@cocotb.test()
async def full_test(dut):

    # 50 MHz clock
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())

    await reset(dut)

    # Verify clock period
    await RisingEdge(dut.clk)
    t1 = get_sim_time('ns')
    await RisingEdge(dut.clk)
    t2 = get_sim_time('ns')
    dut._log.info(f"Clock period = {t2 - t1} ns (should be 20 ns)")

    await run_cycles(dut, 10)

    # Waveforms
  
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

        assert len(set(values)) > 5, f"{name} not changing"
        assert max(values) <= 255, "Overflow"

        dut._log.info(f"{name} OK")

    # Frequency

    changes_per_freq = []

    for freq in range(4):
        dut.ui_in.value = (freq << 6) | (0b100 << 3) | 0b000
        values = await run_cycles(dut, 200)

        changes = sum(1 for i in range(1, len(values)) if values[i] != values[i-1])
        changes_per_freq.append(changes)

    assert changes_per_freq[0] < changes_per_freq[-1], "Frequency failed"
    dut._log.info("Frequency OK")

    # Amplitude

    dut.ui_in.value = 0b000_001_01
    low_vals = await run_cycles(dut, 200)

    dut.ui_in.value = 0b000_111_01
    high_vals = await run_cycles(dut, 200)

    assert max(high_vals) > max(low_vals), "Amplitude failed"
    dut._log.info("Amplitude OK")

    dut._log.info("ALL TESTS PASSED")