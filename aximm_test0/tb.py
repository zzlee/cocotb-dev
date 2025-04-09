import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.types import LogicArray

from cocotbext.axi import (AxiLiteBus, AxiLiteMaster)
from cocotbext.axi import (AxiBus, AxiSlave, MemoryRegion)
from cocotbext.axi import (AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor)

@cocotb.test()
async def testbench0(dut):
    byteorder = "little";

    clock = Clock(dut.ap_clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi_control"), dut.ap_clk, dut.ap_rst_n, reset_active_level=False);
    axi_slave = AxiSlave(AxiBus.from_prefix(dut, "m_axi_mm_video"), dut.ap_clk, dut.ap_rst_n,
        reset_active_level=False, target=MemoryRegion(2**32));

    dut.ap_rst_n.value = 0;
    await ClockCycles(dut.ap_clk, 2);
    dut.ap_rst_n.value = 1;
    await ClockCycles(dut.ap_clk, 2);

    nSize = 4096;
    await axil_master.write(0x1C, nSize.to_bytes(4, byteorder));

    nTimes = 2160 * 2;
    await axil_master.write(0x24, nTimes.to_bytes(4, byteorder));

    pDstPxl = 0x0000A000;
    await axil_master.write(0x10, pDstPxl.to_bytes(4, byteorder));

    gie = 0x1; # Global Interrupt Enable
    ie = 0x1; # enable ap_done interrupt
    await axil_master.write(0x04, gie.to_bytes(4, byteorder));
    await axil_master.write(0x08, ie.to_bytes(4, byteorder));

    # ap_start
    ap_ctrl_val = await axil_master.read(0x00, 4);
    ap_ctrl = int.from_bytes(ap_ctrl_val.data, byteorder) | 0x1;
    await axil_master.write(0x00, ap_ctrl.to_bytes(4, byteorder));

    # await ClockCycles(dut.ap_clk, 40);
    await RisingEdge(dut.interrupt);
    # await ClockCycles(dut.ap_clk, 20);
