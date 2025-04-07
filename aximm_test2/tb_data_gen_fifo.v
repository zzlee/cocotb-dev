`timescale 1 ns / 1 ps

module tb_data_gen_fifo # (
	parameter WIDTH = 8
)
(
	input ap_clk,
	input ap_rst_n,

	input [31:0] size,
	input [31:0] times,

	input ap_start,
	output reg ap_idle,
	output reg ap_ready,
	output reg ap_done
);

	reg fifo_wr_en;
	reg [WIDTH-1:0] fifo_wr_data;
	reg fifo_rd_en;
	wire [WIDTH-1:0] fifo_rd_data;
	wire fifo_empty;
	wire fifo_full;

	fifo #(
		.DEPTH(4),
		.WIDTH(WIDTH)
	)
	fifo_U (
		.clk(ap_clk),
		.rst_n(ap_rst_n),

		.wr_en(fifo_wr_en),
		.wr_data(fifo_wr_data),

		.rd_en(fifo_rd_en),
		.rd_data(fifo_rd_data),

		.empty(fifo_empty),
		.full(fifo_full)
	);

	reg data_gen_fifo_ap_start;
	wire data_gen_fifo_ap_done;
	wire data_gen_fifo_ap_idle;
	wire data_gen_fifo_ap_ready;

	data_gen_fifo #(
		.WIDTH(WIDTH)
	)
	data_gen_fifo_U (
		.ap_clk(ap_clk),
		.ap_rst_n(ap_rst_n),

		.size(size),
		.times(times),

		.fifo_wr_en(fifo_wr_en),
		.fifo_wr_data(fifo_wr_data),
		.fifo_full(fifo_full),

		.ap_start(data_gen_fifo_ap_start),
		.ap_done(data_gen_fifo_ap_done),
		.ap_idle(data_gen_fifo_ap_idle),
		.ap_ready(data_gen_fifo_ap_ready)
	);

	reg fifo_drain_ap_start;
	wire fifo_drain_ap_done;
	wire fifo_drain_ap_idle;
	wire fifo_drain_ap_ready;

	fifo_drain #(
		.WIDTH(WIDTH)
	)
	fifo_drain_U (
		.ap_clk(ap_clk),
		.ap_rst_n(ap_rst_n),

		.size(size),
		.times(times),

		.fifo_rd_en(fifo_rd_en),
		.fifo_rd_data(fifo_rd_data),
		.fifo_empty(fifo_empty),

		.ap_start(fifo_drain_ap_start),
		.ap_done(fifo_drain_ap_done),
		.ap_idle(fifo_drain_ap_idle),
		.ap_ready(fifo_drain_ap_ready)
	);

	// ap control
	localparam
		IDLE = 'b000,
		START = 'b001;

	reg [2:0] state, state_next;
	reg data_gen_fifo_ap_done_int;
	reg fifo_drain_ap_done_int;

	always_comb begin
		state_next = state;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 0;
		data_gen_fifo_ap_start = 0;
		fifo_drain_ap_start = 0;
		data_gen_fifo_ap_done_int = data_gen_fifo_ap_done_int;
		fifo_drain_ap_done_int = fifo_drain_ap_done_int;

		case(state)
			IDLE: begin
				ap_idle = 1;

				if(ap_start) begin
					ap_ready = 1;
					data_gen_fifo_ap_start = 1;
					fifo_drain_ap_start = 1;
					state_next = START;
				end
			end
			START: begin
				data_gen_fifo_ap_done_int = data_gen_fifo_ap_done_int || data_gen_fifo_ap_done;
				fifo_drain_ap_done_int = fifo_drain_ap_done_int || fifo_drain_ap_done;

				if(data_gen_fifo_ap_done_int && fifo_drain_ap_done_int) begin
					ap_done = 1;
					state_next = IDLE;
				end
			end
		endcase
	end

	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;
			data_gen_fifo_ap_start <= 0;
			fifo_drain_ap_start <= 0;
			data_gen_fifo_ap_done_int <= 0;
			fifo_drain_ap_done_int <= 0;
			state <= IDLE;
		end else begin
			state <= state_next;
		end
	end
endmodule