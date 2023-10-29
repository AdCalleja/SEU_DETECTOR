import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

@cocotb.test()
async def tb_count_bitflips(dut):
    print("Executing count_bitflips")
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    

    # Init
    dut.rst_n.value = 0
    await Timer(50, units="ns")
    # Write
    dut.rst_n.value = 1
    dut.w_mem_en.value = 1
    # Force errors
    await Timer(1500, units="ns")
    dut.data.value = 0xFFFFFFFFFF
    #await Timer(10, units="ns")
    #dut.data.value = Release()
    await Timer(1500, units="ns")
    # Reset = change of STATE in the state machine (Write -> Read)
    dut.rst_n.value = 0
    await Timer(10, units="ns")
    # Read and Check Errors
    dut.rst_n.value = 1
    dut.w_mem_en.value = 0
    await Timer(1500, units="ns")
    await Timer(3000, units="ns")



# @cocotb.test()
# async def tb_seu_detector_no_fsm(dut):
#     print("Executing SEU Detector NO FSM")
#     cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    

#     # Init
#     dut.rst_n.value = 0
#     await Timer(50, units="ns")
#     # Write
#     dut.rst_n.value = 1
#     dut.w_mem_en.value = 1
#     await Timer(3000, units="ns")
#     # Reset = change of STATE in the state machine (Write -> Read)
#     dut.rst_n.value = 0
#     await Timer(10, units="ns")
#     # Read and Check Errors
#     dut.rst_n.value = 1
#     dut.w_mem_en.value = 0
#     await Timer(3000, units="ns")