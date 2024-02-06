import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.handle import  Deposit, Force, Release, Freeze
from cocotb.binary import BinaryValue
from cocotb_bus.drivers.avalon import AvalonMaster


def printbf(value):
    print(f"Number of bitflips: {int(value)}")

async def serve_irq(dut, AvMaster):
    BITFLIPS = 4
    await RisingEdge(dut.INS_IRQ0)
    bitflips = int(await AvMaster.read(address = BITFLIPS))
    printbf(bitflips)
    return bitflips

@cocotb.test()
async def tb_top(dut):
    """Executing top"""
    cocotb.start_soon(Clock(dut.clk_src, 10, units="ns").start()) # == CLK <= not CLK after 10 ns; -- 50 MHz 
    
    #print(dir(dut.address))

    AvMaster = AvalonMaster(dut, "", dut.clk_src)
    print(AvMaster._signals)
    print(AvMaster._optional_signals)
     # Init
    dut.RESET_N.value = 0
    await Timer(50, units="ns")
    dut.RESET_N.value = 1
    await Timer(10, units="ns")

    # Addresses
    EN_SW = 0
    N_READS = 1
    T_WRITE = 2
    T_WRITE_RESOLUTION = 3
    BITFLIPS = 4

    # SET Config
    await AvMaster.write(address = N_READS, value = 2)
    await AvMaster.write(address = T_WRITE, value = 100)
    await AvMaster.write(address = T_WRITE_RESOLUTION, value = 0)

    # Get Config
    n_reads = int(await AvMaster.read(address = N_READS))
    t_write = int(await AvMaster.read(address = T_WRITE))
    t_write_resolution = int(await AvMaster.read(address = T_WRITE_RESOLUTION))
    print("\n---CONFIG---")
    print("Number of reads per write:" + str(n_reads))
    print("Time between writes: " + str(t_write))
    print("Resolution mode: " + str(t_write_resolution))
    resolution = " s" if t_write_resolution else " ms"
    print(f"Reading every {str(t_write/n_reads)}{resolution}. Writting every {str(t_write)}{resolution}\n")

    # Start EXP
    await Timer(50, units="ns")
    await AvMaster.write(address = EN_SW, value = 1)

    # Check that the interrupt is generated and a value is read
    assert 0 == await serve_irq(dut, AvMaster)
    assert 0 == await serve_irq(dut, AvMaster)

    # # Inject Errors
    #await Timer(1500, units="ns")
    # # Addr 148: Applied to all memories=10*39xClks/2 + 10*1*Clks/2
    # dut.seu_detector.data.value = BinaryValue("1110101010101010101010101010101010101010")

    # TODO Tests:
    # -Injectar errores y comprobar el número de errores con 10*39xClks/2 + 10*1*Clks/2
    # -Comprobar lo mismo para el siguiente ciclo de writes y reads, teniendo en cuenta que todo estará a petar de errores
    # -Pensar en otro patrón de errores que pueda generar un output diferente.