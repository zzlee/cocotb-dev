TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = ./top.v ./axi_lite_slave.v
TOPLEVEL = top
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
