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
VERILOG_SOURCES = ./tb_data_gen_fifo.v \
./data_gen.v ./fifo.v ./data_gen_fifo.v ./fifo_drain.v
TOPLEVEL = tb_data_gen_fifo
MODULE = tb_data_gen_fifo
endif

ifeq (${TARGET},tb_aximm_test2)
VERILOG_SOURCES = ./tb_aximm_test2.v ./aximm_test2_control_s_axi.v \
./data_gen.v ./fifo.v ./data_gen_fifo.v ./fifo_drain.v ./fifo_to_axi_mm_burst.v
TOPLEVEL = tb_aximm_test2
MODULE = tb_aximm_test2
endif

ifeq (${TARGET},tb_axis_number_generator)
VERILOG_SOURCES = ./tb_axis_number_generator.v ./axis_number_generator.v
TOPLEVEL = tb_axis_number_generator
MODULE = tb_axis_number_generator
endif

ifeq (${TARGET},tb_axis_to_axi_mm_burst)
VERILOG_SOURCES = ./tb_axis_to_axi_mm_burst.v ./aximm_test2_control_s_axi.v \
./axis_number_generator.v ./axis_to_axi_mm_burst.v
TOPLEVEL = tb_axis_to_axi_mm_burst
MODULE = tb_axis_to_axi_mm_burst
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
