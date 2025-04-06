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
	await ClockCycles(dut.ap_clk, 5);
	dut.ap_rst_n.value = 1;
	await ClockCycles(dut.ap_clk, 1);

	dut.size.value = 8;
	dut.times.value = 2;

	# ap_start pulse
	dut.ap_start.value = 1;
	await ClockCycles(dut.ap_clk, 1);
	dut.ap_start.value = 0;

	# await ClockCycles(dut.ap_clk, 40);
	await RisingEdge(dut.ap_done);
	await ClockCycles(dut.ap_clk, 20);
