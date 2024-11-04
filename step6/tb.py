import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

from cocotbext.axi import AxiBus, AxiMaster

@cocotb.test()
async def testbench1(dut):
    dut.rst.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    axi_master = AxiMaster(AxiBus.from_prefix(dut, "s_axi"), dut.clk, dut.rst)

    addr = 0x10
    test_data = bytearray([x % 256 for x in range(4096)])

    await axi_master.write(addr, test_data)
    await axi_master.read(addr, len(test_data));

    await Timer(4000, 'ns');
