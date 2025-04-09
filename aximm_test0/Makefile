TOPLEVEL_LANG = verilog
SIM ?= icarus
WAVES ?= 1

VERILOG_SOURCES = \
./aximm_test0_control_s_axi.v \
./aximm_test0_data_gen_Pipeline_loop_times_loop_burst.v \
./aximm_test0_data_gen.v \
./aximm_test0_entry_proc.v \
./aximm_test0_fifo_w128_d2_S.v \
./aximm_test0_fifo_w32_d2_S.v \
./aximm_test0_fifo_w64_d3_S.v \
./aximm_test0_fill_data_times_v2_Pipeline_loop_preload_loop_burst.v \
./aximm_test0_fill_data_times_v2.v \
./aximm_test0_flow_control_loop_pipe_sequential_init.v \
./aximm_test0_hls_deadlock_detection_unit.v \
./aximm_test0_mm_video_m_axi.v \
./aximm_test0_mul_32ns_28ns_60_2_1.v \
./aximm_test0_start_for_fill_data_times_v2_U0.v \
./aximm_test0.v \

TOPLEVEL = aximm_test0
MODULE = tb

include $(shell cocotb-config --makefiles)/Makefile.sim
