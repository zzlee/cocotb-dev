# test_dff.py

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

@cocotb.coroutine
def rand_value(sig, half_period, half_period_units):
    sig.value = 0
    timer = Timer(half_period, half_period_units)
    while True:
        yield timer
        sig.value = random.randint(0, 1)

@cocotb.test()
async def testbench(dut):
    dut.d.value = 0;
    dut.g.value = 0;

    cocotb.start_soon(rand_value(dut.d, 7, 'ns'))
    cocotb.start_soon(rand_value(dut.g, 41, 'ns'))
    await Timer(2000, units='ns');
