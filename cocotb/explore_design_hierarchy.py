import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
from cocotb.handle import Release, Force, Freeze

@cocotb.test()
def explore_design_hierarchy(dut):
    print(dir(dut))
    for design_element in dut:
        dut._log.info("Found %s: python type = %s" % (design_element, type (design_element))) 
        dut._log.info(" : _name = %s" % design_element._name)
        dut._log.info(": _path =%s" % design_element._path)
        if design_element._name == "clk":
            dut._log.warning("Found the clk - twiddling it") 
            design_handle = design_element._handle 
            design_handle <= 0
            yield Timer(1)
            design_handle <= 1 
            yield Timer(1) 
            design_handle <= 0
    assert 1