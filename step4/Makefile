TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = $(shell pwd)/top.v $(shell pwd)/arbiter.v $(shell pwd)/priority_encoder.v
TOPLEVEL = top1
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
