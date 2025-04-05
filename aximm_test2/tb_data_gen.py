import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import (AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor)

@cocotb.test()
async def testbench0(dut):
	byteorder = "little";

	clock = Clock(dut.clk, 10, units="ns")
	cocotb.start_soon(clock.start(start_high=False))

	axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.reset_n, reset_active_level=False)

	dut.reset_n.value = 0;
	await ClockCycles(dut.clk, 1);
	dut.reset_n.value = 1;
	await ClockCycles(dut.clk, 1);

	dut.size.value = 8;
	dut.ap_start.value = 1;
	data = await axis_sink.recv();
	print(data);
	dut.ap_start.value = 0;

	await ClockCycles(dut.clk, 40);
