`resetall
`timescale 10ns / 1ps
`default_nettype none

module top
(
        clk,
        rst,
        m_axi_mm_video0_AWVALID,
        m_axi_mm_video0_AWREADY,
        m_axi_mm_video0_AWADDR,
        m_axi_mm_video0_AWID,
        m_axi_mm_video0_AWLEN,
        m_axi_mm_video0_AWSIZE,
        m_axi_mm_video0_AWBURST,
        m_axi_mm_video0_AWLOCK,
        m_axi_mm_video0_AWCACHE,
        m_axi_mm_video0_AWPROT,
        m_axi_mm_video0_AWQOS,
        m_axi_mm_video0_AWREGION,
        m_axi_mm_video0_AWUSER,
        m_axi_mm_video0_WVALID,
        m_axi_mm_video0_WREADY,
        m_axi_mm_video0_WDATA,
        m_axi_mm_video0_WSTRB,
        m_axi_mm_video0_WLAST,
        m_axi_mm_video0_WID,
        m_axi_mm_video0_WUSER,
        m_axi_mm_video0_ARVALID,
        m_axi_mm_video0_ARREADY,
        m_axi_mm_video0_ARADDR,
        m_axi_mm_video0_ARID,
        m_axi_mm_video0_ARLEN,
        m_axi_mm_video0_ARSIZE,
        m_axi_mm_video0_ARBURST,
        m_axi_mm_video0_ARLOCK,
        m_axi_mm_video0_ARCACHE,
        m_axi_mm_video0_ARPROT,
        m_axi_mm_video0_ARQOS,
        m_axi_mm_video0_ARREGION,
        m_axi_mm_video0_ARUSER,
        m_axi_mm_video0_RVALID,
        m_axi_mm_video0_RREADY,
        m_axi_mm_video0_RDATA,
        m_axi_mm_video0_RLAST,
        m_axi_mm_video0_RID,
        m_axi_mm_video0_RUSER,
        m_axi_mm_video0_RRESP,
        m_axi_mm_video0_BVALID,
        m_axi_mm_video0_BREADY,
        m_axi_mm_video0_BRESP,
        m_axi_mm_video0_BID,
        m_axi_mm_video0_BUSER,
        s_axi_control_AWVALID,
        s_axi_control_AWREADY,
        s_axi_control_AWADDR,
        s_axi_control_WVALID,
        s_axi_control_WREADY,
        s_axi_control_WDATA,
        s_axi_control_WSTRB,
        s_axi_control_ARVALID,
        s_axi_control_ARREADY,
        s_axi_control_ARADDR,
        s_axi_control_RVALID,
        s_axi_control_RREADY,
        s_axi_control_RDATA,
        s_axi_control_RRESP,
        s_axi_control_BVALID,
        s_axi_control_BREADY,
        s_axi_control_BRESP,
        interrupt
);

parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 7;
parameter    C_S_AXI_DATA_WIDTH = 32;
parameter    C_M_AXI_MM_VIDEO0_ID_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_ADDR_WIDTH = 64;
parameter    C_M_AXI_MM_VIDEO0_DATA_WIDTH = 128;
parameter    C_M_AXI_MM_VIDEO0_AWUSER_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_ARUSER_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_WUSER_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_RUSER_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_BUSER_WIDTH = 1;
parameter    C_M_AXI_MM_VIDEO0_USER_VALUE = 0;
parameter    C_M_AXI_MM_VIDEO0_PROT_VALUE = 0;
parameter    C_M_AXI_MM_VIDEO0_CACHE_VALUE = 3;
parameter    C_M_AXI_DATA_WIDTH = 32;

parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);
parameter C_M_AXI_MM_VIDEO0_WSTRB_WIDTH = (128 / 8);
parameter C_M_AXI_WSTRB_WIDTH = (32 / 8);

input   clk;
input   rst;
output   m_axi_mm_video0_AWVALID;
input   m_axi_mm_video0_AWREADY;
output  [C_M_AXI_MM_VIDEO0_ADDR_WIDTH - 1:0] m_axi_mm_video0_AWADDR;
output  [C_M_AXI_MM_VIDEO0_ID_WIDTH - 1:0] m_axi_mm_video0_AWID;
output  [7:0] m_axi_mm_video0_AWLEN;
output  [2:0] m_axi_mm_video0_AWSIZE;
output  [1:0] m_axi_mm_video0_AWBURST;
output  [1:0] m_axi_mm_video0_AWLOCK;
output  [3:0] m_axi_mm_video0_AWCACHE;
output  [2:0] m_axi_mm_video0_AWPROT;
output  [3:0] m_axi_mm_video0_AWQOS;
output  [3:0] m_axi_mm_video0_AWREGION;
output  [C_M_AXI_MM_VIDEO0_AWUSER_WIDTH - 1:0] m_axi_mm_video0_AWUSER;
output   m_axi_mm_video0_WVALID;
input   m_axi_mm_video0_WREADY;
output  [C_M_AXI_MM_VIDEO0_DATA_WIDTH - 1:0] m_axi_mm_video0_WDATA;
output  [C_M_AXI_MM_VIDEO0_WSTRB_WIDTH - 1:0] m_axi_mm_video0_WSTRB;
output   m_axi_mm_video0_WLAST;
output  [C_M_AXI_MM_VIDEO0_ID_WIDTH - 1:0] m_axi_mm_video0_WID;
output  [C_M_AXI_MM_VIDEO0_WUSER_WIDTH - 1:0] m_axi_mm_video0_WUSER;
output   m_axi_mm_video0_ARVALID;
input   m_axi_mm_video0_ARREADY;
output  [C_M_AXI_MM_VIDEO0_ADDR_WIDTH - 1:0] m_axi_mm_video0_ARADDR;
output  [C_M_AXI_MM_VIDEO0_ID_WIDTH - 1:0] m_axi_mm_video0_ARID;
output  [7:0] m_axi_mm_video0_ARLEN;
output  [2:0] m_axi_mm_video0_ARSIZE;
output  [1:0] m_axi_mm_video0_ARBURST;
output  [1:0] m_axi_mm_video0_ARLOCK;
output  [3:0] m_axi_mm_video0_ARCACHE;
output  [2:0] m_axi_mm_video0_ARPROT;
output  [3:0] m_axi_mm_video0_ARQOS;
output  [3:0] m_axi_mm_video0_ARREGION;
output  [C_M_AXI_MM_VIDEO0_ARUSER_WIDTH - 1:0] m_axi_mm_video0_ARUSER;
input   m_axi_mm_video0_RVALID;
output   m_axi_mm_video0_RREADY;
input  [C_M_AXI_MM_VIDEO0_DATA_WIDTH - 1:0] m_axi_mm_video0_RDATA;
input   m_axi_mm_video0_RLAST;
input  [C_M_AXI_MM_VIDEO0_ID_WIDTH - 1:0] m_axi_mm_video0_RID;
input  [C_M_AXI_MM_VIDEO0_RUSER_WIDTH - 1:0] m_axi_mm_video0_RUSER;
input  [1:0] m_axi_mm_video0_RRESP;
input   m_axi_mm_video0_BVALID;
output   m_axi_mm_video0_BREADY;
input  [1:0] m_axi_mm_video0_BRESP;
input  [C_M_AXI_MM_VIDEO0_ID_WIDTH - 1:0] m_axi_mm_video0_BID;
input  [C_M_AXI_MM_VIDEO0_BUSER_WIDTH - 1:0] m_axi_mm_video0_BUSER;
input   s_axi_control_AWVALID;
output   s_axi_control_AWREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
input   s_axi_control_WVALID;
output   s_axi_control_WREADY;
input  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
input  [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
input   s_axi_control_ARVALID;
output   s_axi_control_ARREADY;
input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
output   s_axi_control_RVALID;
input   s_axi_control_RREADY;
output  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
output  [1:0] s_axi_control_RRESP;
output   s_axi_control_BVALID;
input   s_axi_control_BREADY;
output  [1:0] s_axi_control_BRESP;
output   interrupt;

 reg    rst_n;

always @ (*) begin
    rst_n = ~rst;
end

aximm_test0 aximm_test0_U(
    .ap_clk(clk),
    .ap_rst_n(rst_n),
    .m_axi_mm_video0_AWVALID(m_axi_mm_video0_AWVALID),
    .m_axi_mm_video0_AWREADY(m_axi_mm_video0_AWREADY),
    .m_axi_mm_video0_AWADDR(m_axi_mm_video0_AWADDR),
    .m_axi_mm_video0_AWID(m_axi_mm_video0_AWID),
    .m_axi_mm_video0_AWLEN(m_axi_mm_video0_AWLEN),
    .m_axi_mm_video0_AWSIZE(m_axi_mm_video0_AWSIZE),
    .m_axi_mm_video0_AWBURST(m_axi_mm_video0_AWBURST),
    .m_axi_mm_video0_AWLOCK(m_axi_mm_video0_AWLOCK),
    .m_axi_mm_video0_AWCACHE(m_axi_mm_video0_AWCACHE),
    .m_axi_mm_video0_AWPROT(m_axi_mm_video0_AWPROT),
    .m_axi_mm_video0_AWQOS(m_axi_mm_video0_AWQOS),
    .m_axi_mm_video0_AWREGION(m_axi_mm_video0_AWREGION),
    .m_axi_mm_video0_AWUSER(m_axi_mm_video0_AWUSER),
    .m_axi_mm_video0_WVALID(m_axi_mm_video0_WVALID),
    .m_axi_mm_video0_WREADY(m_axi_mm_video0_WREADY),
    .m_axi_mm_video0_WDATA(m_axi_mm_video0_WDATA),
    .m_axi_mm_video0_WSTRB(m_axi_mm_video0_WSTRB),
    .m_axi_mm_video0_WLAST(m_axi_mm_video0_WLAST),
    .m_axi_mm_video0_WID(m_axi_mm_video0_WID),
    .m_axi_mm_video0_WUSER(m_axi_mm_video0_WUSER),
    .m_axi_mm_video0_ARVALID(m_axi_mm_video0_ARVALID),
    .m_axi_mm_video0_ARREADY(m_axi_mm_video0_ARREADY),
    .m_axi_mm_video0_ARADDR(m_axi_mm_video0_ARADDR),
    .m_axi_mm_video0_ARID(m_axi_mm_video0_ARID),
    .m_axi_mm_video0_ARLEN(m_axi_mm_video0_ARLEN),
    .m_axi_mm_video0_ARSIZE(m_axi_mm_video0_ARSIZE),
    .m_axi_mm_video0_ARBURST(m_axi_mm_video0_ARBURST),
    .m_axi_mm_video0_ARLOCK(m_axi_mm_video0_ARLOCK),
    .m_axi_mm_video0_ARCACHE(m_axi_mm_video0_ARCACHE),
    .m_axi_mm_video0_ARPROT(m_axi_mm_video0_ARPROT),
    .m_axi_mm_video0_ARQOS(m_axi_mm_video0_ARQOS),
    .m_axi_mm_video0_ARREGION(m_axi_mm_video0_ARREGION),
    .m_axi_mm_video0_ARUSER(m_axi_mm_video0_ARUSER),
    .m_axi_mm_video0_RVALID(m_axi_mm_video0_RVALID),
    .m_axi_mm_video0_RREADY(m_axi_mm_video0_RREADY),
    .m_axi_mm_video0_RDATA(m_axi_mm_video0_RDATA),
    .m_axi_mm_video0_RLAST(m_axi_mm_video0_RLAST),
    .m_axi_mm_video0_RID(m_axi_mm_video0_RID),
    .m_axi_mm_video0_RUSER(m_axi_mm_video0_RUSER),
    .m_axi_mm_video0_RRESP(m_axi_mm_video0_RRESP),
    .m_axi_mm_video0_BVALID(m_axi_mm_video0_BVALID),
    .m_axi_mm_video0_BREADY(m_axi_mm_video0_BREADY),
    .m_axi_mm_video0_BRESP(m_axi_mm_video0_BRESP),
    .m_axi_mm_video0_BID(m_axi_mm_video0_BID),
    .m_axi_mm_video0_BUSER(m_axi_mm_video0_BUSER),
    .s_axi_control_AWVALID(s_axi_control_AWVALID),
    .s_axi_control_AWREADY(s_axi_control_AWREADY),
    .s_axi_control_AWADDR(s_axi_control_AWADDR),
    .s_axi_control_WVALID(s_axi_control_WVALID),
    .s_axi_control_WREADY(s_axi_control_WREADY),
    .s_axi_control_WDATA(s_axi_control_WDATA),
    .s_axi_control_WSTRB(s_axi_control_WSTRB),
    .s_axi_control_ARVALID(s_axi_control_ARVALID),
    .s_axi_control_ARREADY(s_axi_control_ARREADY),
    .s_axi_control_ARADDR(s_axi_control_ARADDR),
    .s_axi_control_RVALID(s_axi_control_RVALID),
    .s_axi_control_RREADY(s_axi_control_RREADY),
    .s_axi_control_RDATA(s_axi_control_RDATA),
    .s_axi_control_RRESP(s_axi_control_RRESP),
    .s_axi_control_BVALID(s_axi_control_BVALID),
    .s_axi_control_BREADY(s_axi_control_BREADY),
    .s_axi_control_BRESP(s_axi_control_BRESP),
    .interrupt(interrupt)
);

endmodule
