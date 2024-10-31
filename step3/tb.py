# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

@cocotb.test()
async def testbench(dut):
    dut.c.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk);

    v = 1;
    for i in range(10):
        dut.c.value = v;
        v = not v;
        await Timer(100, units='ns');
