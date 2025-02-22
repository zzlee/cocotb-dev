`timescale 1 ns / 1 ps

module zzlab_env (
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
		ap_clk,
		ap_rst_n
);

parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 6;
parameter    C_S_AXI_DATA_WIDTH = 32;

parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);

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
(* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi_control" *)
input   ap_clk;
input   ap_rst_n;

 reg    ap_rst_n_inv;

zzlab_env_control_s_axi #(
	.C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
	.C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH ),
    .C_VERSION(32'h25020401),
	.C_PLATFORM("VPRO"),
	.C_BOARD_VERSION(32'h00020101)
)
control_s_axi_U(
	.AWVALID(s_axi_control_AWVALID),
	.AWREADY(s_axi_control_AWREADY),
	.AWADDR(s_axi_control_AWADDR),
	.WVALID(s_axi_control_WVALID),
	.WREADY(s_axi_control_WREADY),
	.WDATA(s_axi_control_WDATA),
	.WSTRB(s_axi_control_WSTRB),
	.ARVALID(s_axi_control_ARVALID),
	.ARREADY(s_axi_control_ARREADY),
	.ARADDR(s_axi_control_ARADDR),
	.RVALID(s_axi_control_RVALID),
	.RREADY(s_axi_control_RREADY),
	.RDATA(s_axi_control_RDATA),
	.RRESP(s_axi_control_RRESP),
	.BVALID(s_axi_control_BVALID),
	.BREADY(s_axi_control_BREADY),
	.BRESP(s_axi_control_BRESP),
	.ACLK(ap_clk),
	.ARESET(ap_rst_n_inv),
	.ACLK_EN(1'b1)
);

always @ (*) begin
	ap_rst_n_inv = ~ap_rst_n;
end

endmodule //zzlab_env
