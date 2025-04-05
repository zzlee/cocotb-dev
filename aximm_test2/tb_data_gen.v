`timescale 1 ns / 1 ps

module tb_data_gen # (
	parameter WIDTH = 8
)
(
	input wire clk,
	input wire reset_n,

	input [31:0] size,

	input ap_start,
	output reg ap_done,
	output reg ap_idle,
	output reg ap_ready,

	output reg [WIDTH-1:0] m_axis_tdata,
	output reg m_axis_tvalid,
	output reg m_axis_tlast,
	input m_axis_tready
);

data_gen #(
	.WIDTH(WIDTH)
)
data_gen_U (
	.clk(clk),
	.reset_n(reset_n),

	.size(size),
	.ap_start(ap_start),
	.ap_done(ap_done),
	.ap_idle(ap_idle),
	.ap_ready(ap_ready),

	.tdata(m_axis_tdata),
	.tvalid(m_axis_tvalid),
	.tlast(m_axis_tlast),
	.tready(m_axis_tready)
);

endmodule