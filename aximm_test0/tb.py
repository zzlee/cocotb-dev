import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotbext.axi import AxiBus, AxiRam

@cocotb.test()
async def testbench1(dut):
    byteorder = "little";

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi_control"), dut.clk, dut.rst)
    axi_ram = AxiRam(AxiBus.from_prefix(dut, "m_axi_mm_video0"), dut.clk, dut.rst, size=2**32)

    await ClockCycles(dut.clk, 1);
    dut.rst.value = 1;
    await ClockCycles(dut.clk, 1);
    dut.rst.value = 0;
    await ClockCycles(dut.clk, 1);

    ap_ctrl_resp = await axil_master.read(0x0000, 4);
    print(ap_ctrl_resp)

    width = 64;
    height = 16;
    stride = width + 32;
    control = 1;
    await axil_master.write(0x0050, width.to_bytes(4, byteorder));
    await axil_master.read(0x0050, 4);
    await axil_master.write(0x0058, height.to_bytes(4, byteorder));
    await axil_master.read(0x0058, 4);
    await axil_master.write(0x0040, stride.to_bytes(4, byteorder));
    await axil_master.read(0x0040, 4);
    await axil_master.write(0x0048, stride.to_bytes(4, byteorder));
    await axil_master.read(0x0048, 4);
    await axil_master.write(0x0060, control.to_bytes(4, byteorder));
    await axil_master.read(0x0060, 4);

    pDstY0 = 0xA000000;
    pDstUV0 = pDstY0 + stride * height;
    pDstY1 = pDstY0 + (stride * height) >> 1;
    pDstUV1 = pDstUV0 + (stride * height) >> 1;
    await axil_master.write(0x0010, pDstY0.to_bytes(4, byteorder));
    await axil_master.read(0x0010, 4);
    await axil_master.write(0x001C, pDstUV0.to_bytes(4, byteorder));
    await axil_master.read(0x001C, 4);
    await axil_master.write(0x0028, pDstY1.to_bytes(4, byteorder));
    await axil_master.read(0x0028, 4);
    await axil_master.write(0x0034, pDstUV1.to_bytes(4, byteorder));
    await axil_master.read(0x0034, 4);

    gie = 0x1;
    ie = 0x1;
    await axil_master.write(0x0004, gie.to_bytes(4, byteorder));
    await axil_master.read(0x0004, 4);
    await axil_master.write(0x0008, ie.to_bytes(4, byteorder));
    await axil_master.read(0x0008, 4);

    ap_ctrl = int.from_bytes(ap_ctrl_resp.data, byteorder) | 0x1;
    ap_ctrl_resp = await axil_master.write(0x0000, ap_ctrl.to_bytes(4, byteorder));
    print(ap_ctrl_resp)

    await RisingEdge(dut.interrupt);

    ap_isr_resp = await axil_master.read(0x000C, 4);
    print(ap_isr_resp)

    ap_isr = int.from_bytes(ap_isr_resp.data, byteorder) & 0x3;
    await axil_master.write(0x000C, ap_isr.to_bytes(4, byteorder));

    ap_ctrl_resp = await axil_master.read(0x0000, 4);
    print(ap_ctrl_resp)

    ap_ctrl_resp = await axil_master.read(0x0000, 4);
    print(ap_ctrl_resp)

    data = axi_ram.read(pDstY0, stride * height * 2)
    print(data);
