import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def reset(dut):
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.ena.value = 1
    await Timer(40, unit="ns")
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
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await reset(dut)

    # Waveforms Test - Format: 0b[Freq_2bit][Amp_3bit][Func_3bit]
    # Freq=00, Amp=111 (max)
    configs = [
        ("SINE",      0b00_111_000),
        ("SAW",       0b00_111_001),
        ("SQUARE",    0b00_111_010),
        ("TRIANGLE",  0b00_111_011),
        ("QUADRATIC", 0b00_111_100),
    ]

    for name, config in configs:
        dut.ui_in.value = config
        values = await run_cycles(dut, 300)
        assert len(set(values)) >= 2, f"{name} not changing" # Square only has 2 values
        dut._log.info(f"{name} OK")

    # Frequency test sweep
    changes_per_freq = []
    for freq in range(4):
        # freq=f, amp=111, func=001 (Saw)
        dut.ui_in.value = (freq << 6) | (0b111 << 3) | 0b001
        values = await run_cycles(dut, 200)
        changes = sum(1 for i in range(1, len(values)) if values[i] != values[i-1])
        changes_per_freq.append(changes)
        dut._log.info(f"Freq {freq} changes: {changes}")

    assert changes_per_freq[0] < changes_per_freq[-1], "Frequency failed"
    dut._log.info("Frequency OK")

    # Amplitude test
    # Low: Amp=001, High: Amp=111 (Both Freq=01, Func=001)
    dut.ui_in.value = 0b01_001_001 
    low_vals = await run_cycles(dut, 200)
    dut.ui_in.value = 0b01_111_001
    high_vals = await run_cycles(dut, 200)

    assert max(high_vals) > max(low_vals), "Amplitude failed"
    dut._log.info("Amplitude OK")
