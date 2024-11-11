# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

# @cocotb.test()
async def testbench0(dut):
    dut.rst.value = 0;
    dut.request.value = 0;
    dut.acknowledge.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    await ClockCycles(dut.clk, 1);
    dut.rst.value = 1;
    await ClockCycles(dut.clk, 1);
    dut.rst.value = 0;

    v = (1 << 2);

    dut.request = v;
    dut.acknowledge = v;
    await ClockCycles(dut.clk, 1);

    dut.acknowledge = (1 << 2);
    dut.request = (1 << 2);
    await Timer(100, 'ns');

@cocotb.test()
async def testbench1(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    for i in range(16):
        dut.input_unencoded.value = i;
        await ClockCycles(dut.clk, 1);
