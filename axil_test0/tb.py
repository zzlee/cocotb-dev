# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotbext.axi import AxiBus, AxiRam

@cocotb.test()
async def testbench0(dut):
	byteorder = "little";

	clock = Clock(dut.clk, 10, units="ns")
	cocotb.start_soon(clock.start(start_high=False))

	axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, ""), dut.clk, dut.reset_n, reset_active_level=False);

	await ClockCycles(dut.clk, 1);
	dut.reset_n.value = 0;
	await ClockCycles(dut.clk, 1);
	dut.reset_n.value = 1;
	await ClockCycles(dut.clk, 1);

	value = 0xABCD;
	await axil_master.write(0x0004, value.to_bytes(4, byteorder));

	value = await axil_master.read(0x0004, 4);
