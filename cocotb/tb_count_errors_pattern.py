import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

# THIS TEST DOESN'T WORK BECAUSE CAN NOT FORCE VALUE OF BUS_PKG (NESTED ARRAY)
@cocotb.test()
async def tb_count_errors_pattern(dut):
        print("THIS TEST DOES NOT WORK")
#     #
#     #cocotb.start_soon(Clock(dut.clk, 20, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz
#     count_errors_pattern = dut

#     await Timer(50, units="ns")

#     mem1 = []

#     addr1 = [["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101010"],
#             ["1010101010101010101010101010101010101011"],]
#     #count_errors_pattern.n_arrays.value = 2
#     # To set a generic to it as 
#     # EXTRA_ARGS=-p<top_level_module_name>.<parameter_name>=<parameter_value>
#     # for i in range(len(addr1)):
#     #     print(i)
#     #     count_errors_pattern.din.value[i] = addr1[i]
#     print(dir(count_errors_pattern.din))
#     print(count_errors_pattern.din.value)
#     count_errors_pattern.din[0].value[0].value = "1010101010101010101010101010101010101011"


#     print(f"SEUs detected: {count_errors_pattern.dout.value}")
    
#     assert 1==1