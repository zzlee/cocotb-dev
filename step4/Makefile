# Makefile

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/top.v $(shell pwd)/arbiter.v $(shell pwd)/priority_encoder.v
TOPLEVEL = top0
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
