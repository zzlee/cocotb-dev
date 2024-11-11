# test_dff.py

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

    dut.intr.value = LogicArray("1011");
    await Timer(300, 'ns');

    dut.intr.value = LogicArray("0101");
    await Timer(300, 'ns');
