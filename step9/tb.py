# tb.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

@cocotb.test()
async def testbench0(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    dut.intr = 0;

    await ClockCycles(dut.clk, 1);
    dut.rst.value = 1;
    await ClockCycles(dut.clk, 1);
    dut.rst.value = 0;
    await ClockCycles(dut.clk, 1);

    dut.intr.value = LogicArray("00000000000000000000000000010101");
    await Timer(10000, 'ns');
    await ClockCycles(dut.clk, 2);

    dut.intr.value = LogicArray("10000000000000000000000000000101");
    await Timer(10000, 'ns');
