import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
import random

@cocotb.test()
async def tb_sum_bitflips(dut):
    print("Executing sum bitflips")
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz

    # N_MEMS = 10
    # MEM_ADDRS = 256
    # MEM_WIDTH = 40

    dut.rst_n.value = 0
    await Timer(50, units="ns")
    assert dut.total_bitflips.value == 0
    dut.rst_n.value = 1

    rand_list = random.sample(range(0, 399), 256) # 400 is the limit for N_MEMS = 10 
    for i in range(256):
        dut.bitflips.value = rand_list[i]
        old_total_bitflips = dut.total_bitflips.value
        bitflips = rand_list[i] # Can not read from DUT yet
        await Timer(10, units="ns")
        print(f"Old total bitflips: {int(old_total_bitflips)}. Bit flips in this cycle: {bitflips}")
        print(f"New bitflips: {int(dut.total_bitflips.value)}")
        assert dut.total_bitflips.value == int(old_total_bitflips)+int(bitflips)

    # End count is right
    assert dut.total_bitflips.value == sum(rand_list)

    # CAUTION, RIGHT NOW IF NO RST, IT STILL ADDING BECUASE BITFLIPS IS STUCK AND EVERY CYCLE ADDED TO THE TOTAL
    await Timer(100, units="ns")
    dut.rst_n.value = 0
    await Timer(50, units="ns")
    assert dut.total_bitflips.value == 0
    dut.rst_n.value = 1

