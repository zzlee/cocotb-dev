TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

VERILOG_SOURCES = $(shell pwd)/top.v
TOPLEVEL = top
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
