import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

@cocotb.test()
async def tb_mmu(dut):
    print("Executing mmu")
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz

    # Simple Waveform Gen
    # dut.rst_n.value = 0
    # await Timer(50, units="ns")
    # dut.rst_n.value = 1
    # await Timer(3000, units="ns")

    dut.rst_n.value = 0
    await Timer(50, units="ns")
    dut.rst_n.value = 1
    assert dut.mmu_finish.value == 0
    # Automatic test
    for i in range(256):
        assert dut.addr.value == i  
        if (i% 2) == 0:
            assert int(dut.data.value) == int("1010101010101010101010101010101010101010",2)
        elif (i% 2) == 1:
            assert int(dut.data.value) == int("0101010101010101010101010101010101010101",2)
        await Timer(10, units="ns")
    
    assert dut.mmu_finish.value == 1
    assert dut.addr.value == 255

    # Reset
    dut.rst_n.value = 0
    await Timer(10, units="ns")
    assert dut.mmu_finish.value == 0
    assert dut.addr.value == 0
    assert int(dut.data.value) == int("1010101010101010101010101010101010101010",2)

