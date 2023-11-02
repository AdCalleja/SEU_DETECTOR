import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.handle import  Deposit, Force, Release, Freeze
from cocotb.binary import BinaryValue

@cocotb.test()
async def tb_top(dut):
    print("Executing top")
    cocotb.start_soon(Clock(dut.clk_src, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    

    # Init
    dut.RESET_N.value = 0
    await Timer(50, units="ns")
    dut.RESET_N.value = 1
    await Timer(10, units="ns")

    # Configure Exp
    # n_reads
    dut.OFFSET_ADDRESS.value = 1
    dut.write_en.value = 1
    dut.DATA_IN.value = 2
    await Timer(10, units="ns")
    dut.write_en.value = 0
    await Timer(50, units="ns")

    # t_write
    dut.OFFSET_ADDRESS.value = 2
    dut.write_en.value = 1
    dut.DATA_IN.value = 100
    await Timer(10, units="ns")
    dut.write_en.value = 0
    await Timer(50, units="ns")

    # t_write_resolution
    dut.OFFSET_ADDRESS.value = 3
    dut.write_en.value = 1
    dut.DATA_IN.value = 0
    await Timer(10, units="ns")
    dut.write_en.value = 0
    await Timer(50, units="ns")


    # Start Exp
    dut.OFFSET_ADDRESS.value = 0
    dut.write_en.value = 1
    dut.DATA_IN.value = 1
    await Timer(10, units="ns")
    dut.write_en.value = 0
    await Timer(50, units="ns")

    # Inject Errors
    await Timer(1500, units="ns")
    # Addr 148: Applied to all memories=10*39xClks/2 + 10*1*Clks/2
    dut.seu_detector.data.value = BinaryValue("1110101010101010101010101010101010101010")




    # Handle IRQ and Disable it
    await Timer(4200, units="ns") # Markers calculated 4180 (Wait 2 clocks to read it)
    dut.OFFSET_ADDRESS.value = 0
    dut.read_en.value = 1
    await Timer(10, units="ns")
    bitflips = dut.DATA_OUT.value
    print(bitflips)
    await Timer(10, units="ns")
    dut.read_en.value = 0
    bitflips = dut.DATA_OUT.value
    print(bitflips)
    await Timer(20, units="ns")
    bitflips = dut.DATA_OUT.value
    print(bitflips)


    # Reset back



    #Tests:
    # -Contar ciclos en read mem con errores, y comprobar el número de errores con 10*39xClks/2 + 10*1*Clks/2
    # -Comprobar lo mismo para el siguiente ciclo de writes y reads, teniendo en cuenta que todo estará a petar de errores
    # -Pensar en otro patrón de errores que pueda generar un output diferente.
    await Timer(1500, units="ns")
    await Timer(10000, units="ns")




    assert 1==1