TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = ./top.v ./priority_encoder.v
TOPLEVEL = top
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
