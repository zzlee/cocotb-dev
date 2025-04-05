TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1
TARGET ?= tb_data_gen

ifeq (${TARGET},tb_data_gen)
VERILOG_SOURCES = ./tb_data_gen.v ./data_gen.v
TOPLEVEL = tb_data_gen
MODULE = tb_data_gen
endif

ifeq (${TARGET},tb_data_gen_fifo)
VERILOG_SOURCES = ./tb_data_gen_fifo.v ./data_gen.v ./fifo.v
TOPLEVEL = tb_data_gen_fifo
MODULE = tb_data_gen_fifo
endif

ifeq (${TARGET},tb_aximm_test2)
VERILOG_SOURCES = ./tb_aximm_test2.v ./aximm_test2_control_s_axi.v ./data_gen.v ./fifo.v
TOPLEVEL = tb_aximm_test2
MODULE = tb_aximm_test2
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
