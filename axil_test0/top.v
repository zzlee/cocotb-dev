`resetall
`timescale 10ns / 1ps
`default_nettype none

module top
(
    input clk,
    input reset_n,
    // AXI-Lite 寫通道
    input [31:0] awaddr,
    input awvalid,
    output reg awready,
    input [31:0] wdata,
    input wvalid,
    output reg wready,
    output reg [1:0] bresp,
    output reg bvalid,
    input bready,
    // AXI-Lite 讀通道
    input [31:0] araddr,
    input arvalid,
    output reg arready,
    output reg [31:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input rready
);

axi_lite_slave axi_lite_slave_inst (
	.clk(clk),
	.reset_n(reset_n),
    .awaddr(awaddr),
    .awvalid(awvalid),
    .awready(awready),
    .wdata(wdata),
    .wvalid(wvalid),
    .wready(wready),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready),
    // AXI-Lite 讀通道
    .araddr(araddr),
    .arvalid(arvalid),
    .arready(arready),
    .rdata(rdata),
    .rresp(rresp),
    .rvalid(rvalid),
    .rready(rready)
);

endmodule
