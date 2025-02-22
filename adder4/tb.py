# tb.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

@cocotb.test()
async def testbench0(dut):
	clock = Clock(dut.ap_clk, 10, units="ns")
	cocotb.start_soon(clock.start(start_high=False))

	dut.ap_ce.value = 1;
	dut.ap_start.value = 0;
	dut.ap_continue.value = 0;

	await ClockCycles(dut.ap_clk, 1);
	dut.ap_rst.value = 1;
	await ClockCycles(dut.ap_clk, 1);
	dut.ap_rst.value = 0;
	await ClockCycles(dut.ap_clk, 1);

	dut.a1.value = 0x06;
	dut.a2.value = 0x07;
	dut.a3.value = 0x08;
	dut.a4.value = 0x09;

	dut.b1.value = 0x11;
	dut.b2.value = 0x22;
	dut.b3.value = 0x33;
	dut.b4.value = 0x44;

	dut.ap_start.value = 1;

	await RisingEdge(dut.ap_done);

	await Timer(500, 'ns');
