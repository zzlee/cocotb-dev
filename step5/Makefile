TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

TOPLEVEL = axil_ram
MODULE = tb
VERILOG_SOURCES = ../rtl/axil_ram.v

include $(shell cocotb-config --makefiles)/Makefile.sim
