module tb_axis_number_generator #(
	parameter DATA_WIDTH = 16
) (
	// --- System Signals ---
	input wire ap_clk,         // Clock
	input wire ap_rst_n,      // Asynchronous Reset, active low

	// --- Control Inputs ---
	input wire i_enable,     // Enable signal to start generation for a new sequence
	input wire [31:0] i_n_value, // The upper limit 'N' (generates 1, 2, ..., N)

	// --- AXI Stream Master Interface ---
	output reg  m_axis_tvalid, // Output valid signal
	output reg  [DATA_WIDTH-1:0] m_axis_tdata,  // Output data (the numbers)
	output reg  m_axis_tlast,  // Output last signal (high for the last number N)
	input wire  m_axis_tready  // Input ready signal from the downstream slave
);

axis_number_generator #(
	.DATA_WIDTH(DATA_WIDTH)
) axis_number_generator_U (
	// --- System Signals ---
	.aclk(ap_clk),         // Clock
	.aresetn(ap_rst_n),      // Asynchronous Reset, active low

	// --- Control Inputs ---
	.i_enable(i_enable),     // Enable signal to start generation for a new sequence
	.i_n_value(i_n_value), // The upper limit 'N' (generates 1, 2, ..., N)

	// --- AXI Stream Master Interface ---
	.m_axis_tvalid(m_axis_tvalid), // Output valid signal
	.m_axis_tdata(m_axis_tdata),  // Output data (the numbers)
	.m_axis_tlast(m_axis_tlast),  // Output last signal (high for the last number N)
	.s_axis_tready(m_axis_tready)  // Input ready signal from the downstream slave
);

endmodule
