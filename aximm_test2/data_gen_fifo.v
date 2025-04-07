`timescale 1 ns / 1 ps

module data_gen_fifo
#(
	parameter WIDTH = 32
)
(
	input ap_clk,
	input ap_rst_n,

	input [31:0] size,
	input [31:0] times,

	output reg fifo_wr_en,
	output reg [WIDTH-1:0] fifo_wr_data,
	input fifo_full,

	input ap_start,
	output reg ap_done,
	output reg ap_idle,
	output reg ap_ready
);

	wire [WIDTH-1:0] s_axis_tdata;
	wire s_axis_tvalid;
	wire s_axis_tlast;
	reg data_gen_ap_start;
	wire data_gen_ap_done;
	wire data_gen_ap_idle;
	wire data_gen_ap_ready;
	reg s_axis_tready;

	data_gen #(
		.WIDTH(WIDTH)
	)
	data_gen_U (
		.ap_clk(ap_clk),
		.ap_rst_n(ap_rst_n),

		.size(size),

		.ap_start(data_gen_ap_start),
		.ap_done(data_gen_ap_done),
		.ap_idle(data_gen_ap_idle),
		.ap_ready(data_gen_ap_ready),

		.tdata(s_axis_tdata),
		.tvalid(s_axis_tvalid),
		.tlast(s_axis_tlast),
		.tready(s_axis_tready)
	);

	localparam
		IDLE = 'b000,
		WRITE = 'b001,
		DONE = 'b010;

	reg [2:0] state, state_next;
	reg [31:0] count, count_next;

	always_comb begin
		state_next = state;
		count_next = count;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 0;
		fifo_wr_en = 0;
		fifo_wr_data = 0;
		s_axis_tready = 0;
		data_gen_ap_start = 0;

		case(state)
			IDLE: begin
				ap_idle = 1;

				if(ap_start) begin
					ap_ready = 1;
					count_next = 1;
					data_gen_ap_start = 1;
					state_next = WRITE;
				end
			end
			WRITE: begin
				s_axis_tready = !fifo_full;
				fifo_wr_en = (s_axis_tvalid && s_axis_tready);
				fifo_wr_data = s_axis_tdata;

				if (data_gen_ap_done) begin
					count_next = count + 1;
				end

				if(count == times) begin
					state_next = DONE;
				end
			end
			DONE: begin
				ap_done = 1;
				state_next = IDLE;
			end
		endcase
	end

	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;

			data_gen_ap_start <= 0;
			count <= 0;
			fifo_wr_en <= 0;
			fifo_wr_data <= 0;
			s_axis_tready <= 0;
			state <= IDLE;
		end else begin
			state <= state_next;
			count <= count_next;
		end
	end

// synthesis translate_off
	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
		end else begin
			if(state == WRITE && fifo_wr_en) begin
				$display(">>>> %0d", fifo_wr_data);
			end
		end
	end
// synthesis translate_on

endmodule
