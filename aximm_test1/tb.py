import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotbext.axi import AxiBus, AxiRam, AxiMaster

@cocotb.test()
async def testbench1(dut):
    byteorder = "little";

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    axi_master = AxiMaster(AxiBus.from_prefix(dut, ""), dut.clk, dut.reset_n, reset_active_level=False)

    await ClockCycles(dut.clk, 1);
    dut.reset_n.value = 0;
    await ClockCycles(dut.clk, 1);
    dut.reset_n.value = 1;
    await ClockCycles(dut.clk, 1);

    await axi_master.read(0, 1024);
