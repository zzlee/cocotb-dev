TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = \
./zzlab_env.v \
./zzlab_env_s_axi.v \
./top.v

TOPLEVEL = top
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
