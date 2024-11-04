import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

from cocotbext.axi import AxiLiteBus, AxiLiteMaster

# @cocotb.test()
async def testbench0(dut):
    dut.rst.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    await RisingEdge(dut.clk);
    dut.rst.value = 1;
    await RisingEdge(dut.clk);
    dut.rst.value = 0;

    # input  wire [ADDR_WIDTH-1:0]  s_axil_awaddr,
    # input  wire [2:0]             s_axil_awprot,
    # input  wire                   s_axil_awvalid,
    # output wire                   s_axil_awready,
    # input  wire [DATA_WIDTH-1:0]  s_axil_wdata,
    # input  wire [STRB_WIDTH-1:0]  s_axil_wstrb,
    # input  wire                   s_axil_wvalid,
    # output wire                   s_axil_wready,
    # output wire [1:0]             s_axil_bresp,
    # output wire                   s_axil_bvalid,
    # input  wire                   s_axil_bready,

    await RisingEdge(dut.clk);

    dut.s_axil_awaddr.value = 0x10;
    dut.s_axil_awprot.value = 0x0;
    dut.s_axil_wdata.value = 0xABCD;
    dut.s_axil_wstrb.value = -1;

    dut.s_axil_awvalid.value = 1;
    dut.s_axil_wvalid.value = 1;
    dut.s_axil_bready.value = 1;
    await RisingEdge(dut.s_axil_awready);
    dut.s_axil_wvalid.value = 0;
    await RisingEdge(dut.s_axil_bvalid);
    dut.s_axil_bready.value = 0;

    await RisingEdge(dut.clk);

    # input  wire [ADDR_WIDTH-1:0]  s_axil_araddr,
    # input  wire [2:0]             s_axil_arprot,
    # input  wire                   s_axil_arvalid,
    # output wire                   s_axil_arready,
    # output wire [DATA_WIDTH-1:0]  s_axil_rdata,
    # output wire [1:0]             s_axil_rresp,
    # output wire                   s_axil_rvalid,
    # input  wire                   s_axil_rready

    dut.s_axil_araddr.value = 0x10;
    dut.s_axil_arprot.value = 0x0;

    dut.s_axil_arvalid.value = 1;
    dut.s_axil_rready.value = 1;
    await RisingEdge(dut.s_axil_arready);
    dut.s_axil_arvalid.value = 0;
    await RisingEdge(dut.s_axil_rvalid);
    dut.s_axil_rready.value = 0;

    await Timer(500, 'ns');

@cocotb.test()
async def testbench1(dut):
    dut.rst.value = 0;

    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start(start_high=False))

    axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axil"), dut.clk, dut.rst)

    addr = 0x10
    test_data = bytearray([0xAB, 0xCD, 0xEF, 0x12])

    await axil_master.write(addr, test_data)
    await axil_master.read(addr, 4);

    await Timer(500, 'ns');
