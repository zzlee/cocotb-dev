TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = \
./aximm_test0.v \
./aximm_test0_aximm_test0_Pipeline_loop_width_even.v \
./aximm_test0_aximm_test0_Pipeline_loop_width_odd.v \
./aximm_test0_control_s_axi.v \
./aximm_test0_flow_control_loop_pipe_sequential_init.v \
./aximm_test0_mm_video0_m_axi.v \
./top.v

TOPLEVEL = top
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
