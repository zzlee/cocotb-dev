import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import AxiLiteBus, AxiLiteMaster

@cocotb.test()
async def testbench1(dut):
    clock = Clock(dut.clk, 10, units="ns")
    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi_control"), dut.clk, dut.rst)

    cocotb.start_soon(clock.start(start_high=False))

    await axil_master.read(0x0010, 4);
    await axil_master.read(0x0014, 4);
    await axil_master.read(0x0018, 4);

    await axil_master.read(0x001C, 4);
    await axil_master.read(0x001C, 4);
    await axil_master.read(0x001C, 4);
    await axil_master.read(0x001C, 4);

    value = 0x1234;
    await axil_master.write(0x0020, value.to_bytes(4, "little"));
    await axil_master.read(0x0020, 4);

    await Timer(1000, 'ns');
