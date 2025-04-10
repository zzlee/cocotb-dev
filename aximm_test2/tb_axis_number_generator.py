import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import (AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor)

@cocotb.test()
async def testbench0(dut):
	byteorder = "little";

	clock = Clock(dut.ap_clk, 10, units="ns")
	cocotb.start_soon(clock.start(start_high=False))

	dut.ap_rst_n.value = 0;
	await ClockCycles(dut.ap_clk, 3);
	dut.ap_rst_n.value = 1;
	await ClockCycles(dut.ap_clk, 3);

	axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.ap_clk, dut.ap_rst_n, reset_active_level=False)

	dut.i_n_value.value = 16;
	dut.i_enable.value = 1;
	await ClockCycles(dut.ap_clk, 1);
	dut.i_enable.value = 0;
	data = await axis_sink.recv();
	print(data);

	await ClockCycles(dut.ap_clk, 20);
