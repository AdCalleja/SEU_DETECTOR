import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.handle import  Deposit, Force, Release, Freeze
from cocotb.binary import BinaryValue

@cocotb.test()
async def tb_seu_detetor(dut):
    print("Executing seu_detetor")
    cocotb.start_soon(Clock(dut.clk_src, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    

    # Init
    dut.rst_n.value = 0
    dut.t_write_resolution.value = 0
    await Timer(50, units="ns")
    # Set Config Params from SW
    dut.n_reads.value = 2 # Read 1 time every 0.5 seconds. 2 times to write
    dut.t_write.value = 100
    dut.rst_n.value = 1
    await Timer(50, units="ns")
    # Get out of standby
    dut.en_sw.value = 1
    # Inject error
    await Timer(1500, units="ns")
    # Addr 148: Applied to all memories=10*39xClks/2 + 10*1*Clks/2
    dut.data.value = BinaryValue("1110101010101010101010101010101010101010")

    #Tests:
    # -Contar ciclos en read mem con errores, y comprobar el número de errores con 10*39xClks/2 + 10*1*Clks/2
    # -Comprobar lo mismo para el siguiente ciclo de writes y reads, teniendo en cuenta que todo estará a petar de errores
    # -Pensar en otro patrón de errores que pueda generar un output diferente.
    await Timer(1500, units="ns")
    await Timer(10000, units="ns")




    assert 1==1

# # Code that WORKS to READ MEM:
    # # Sadly, it also locks the value
    # print(dir(dut))
    # print(dir(dut._id("gen_m10k(0)", extended=False)))
    # mem0 = dut._id("gen_m10k(0)", extended=False)
    # print(dir(mem0.ram_m10k_inst))
    # mem0_data = mem0.ram_m10k_inst._id("data", extended=False)
    # print(mem0_data.value)
    # mem0_data.value = BinaryValue("1111111111101010101010101010101010101010")




# @cocotb.test()
# async def tb_count_bitflips(dut):
#     print("Executing count_bitflips")
#     cocotb.start_soon(Clock(dut.clk, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    

#     # Init
#     dut.rst_n.value = 0
#     await Timer(50, units="ns")
#     # Write
#     dut.rst_n.value = 1
#     dut.w_mem_en.value = 1
#     # Force errors
#     await Timer(1500, units="ns")
#     dut.data.value = 0xFFFFFFFFFF
#     #await Timer(10, units="ns")
#     #dut.data.value = Release()
#     await Timer(1500, units="ns")
#     # Reset = change of STATE in the state machine (Write -> Read)
#     dut.rst_n.value = 0
#     await Timer(10, units="ns")
#     # Read and Check Errors
#     dut.rst_n.value = 1
#     dut.w_mem_en.value = 0
#     await Timer(1500, units="ns")
#     await Timer(3000, units="ns")



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