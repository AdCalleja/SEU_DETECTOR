ghdl -r -fsynopsys -P=intel/ --std=08 tb_debayer --stop-time=5000ns --vcd=waveform.vcd
gtkwave waveform.vcd
