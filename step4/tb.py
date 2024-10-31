# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

@cocotb.test()
async def testbench0(dut):
    dut.rst.value = 0;
    dut.request.value = 0;
    dut.acknowledge.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk);
    dut.rst.value = 1;
    await RisingEdge(dut.clk);
    dut.rst.value = 0;

    for i in range(100):
        v = random.randint(0, 3);

        dut.request.value = 1 << v;
        await RisingEdge(dut.clk);

        dut.acknowledge = dut.grant.value;
        await RisingEdge(dut.clk);

# @cocotb.test()
async def testbench1(dut):
    for i in range(16):
        dut.input_unencoded.value = i;
        await Timer(10, 'ns');
