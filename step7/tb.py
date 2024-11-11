# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

@cocotb.test()
async def testbench0(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk);
    dut.rst.value = 1;
    await RisingEdge(dut.clk);
    dut.rst.value = 0;

    await Timer(500, 'ns');
