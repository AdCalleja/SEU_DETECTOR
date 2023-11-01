TOPLEVEL_LANG ?= vhdl

PWD=$(shell pwd)
SIM ?= ghdl

EXTRA_ARGS = -fsynopsys -P=../intel/ --std=08 -Whide # REMOVE -Whide to see all warnings, but here there are too much from for loops :)
# To set a generic to it as 
# EXTRA_ARGS=-p<top_level_module_name>.<parameter_name>=<parameter_value>
SIM_ARGS += --wave=waves/wv_$(TOPLEVEL).ghw
#export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
VHDL_SOURCES = $(PWD)/../src/*.vhd

DUT ?=seu_detector# DUTs: count_errors_pattern, mmu
TOPLEVEL ?= $(DUT)
MODULE ?= tb_$(DUT)

include $(shell cocotb-config --makefiles)/Makefile.sim	

.PHONY:waves
waves:
	gtkwave -a waves/signals_$(DUT).gtkw waves/wv_$(TOPLEVEL).ghw
	
