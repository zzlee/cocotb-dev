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

	wire [WIDTH-1:0] s_axis_tdata;
	wire s_axis_tvalid;
	wire s_axis_tlast;
	reg s_axis_tready;
	reg [31:0] data_gen_size;
	reg data_gen_ap_start;
	wire data_gen_ap_done;
	wire data_gen_ap_idle;
	wire data_gen_ap_ready;
	reg [31:0] data_gen_times;

	data_gen #(
		.WIDTH(WIDTH)
	)
	data_gen_U (
		.clk(ap_clk),
		.reset_n(ap_rst_n),

		.size(data_gen_size),

		.ap_start(data_gen_ap_start),
		.ap_done(data_gen_ap_done),
		.ap_idle(data_gen_ap_idle),
		.ap_ready(data_gen_ap_ready),

		.tdata(s_axis_tdata),
		.tvalid(s_axis_tvalid),
		.tlast(s_axis_tlast),
		.tready(s_axis_tready)
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

	// data_gen -> fifo
	always @(posedge ap_clk or negedge ap_rst_n) begin
		if(~ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;

			fifo_wr_en <= 0;
			fifo_wr_data <= 0;
			fifo_rd_en <= 0;
			s_axis_tready <= 0;
			data_gen_ap_start <= 0;
		end else begin
			if(ap_start && !ap_ready) begin
				fifo_wr_en <= 0;
				fifo_wr_data <= 0;
				fifo_rd_en <= 0;
				s_axis_tready <= 0;
				data_gen_size <= (size >> $clog2(WIDTH / 8));
				data_gen_ap_start <= 1;
				data_gen_times <= 0;

				ap_ready <= 1;
				ap_idle <= 0;
			end

			if(ap_ready) begin
				if(! data_gen_ap_start)
					data_gen_ap_start <= (fifo_empty && (data_gen_times < times));

				if(data_gen_ap_start) begin
					s_axis_tready <= !fifo_full;
					if (s_axis_tvalid && s_axis_tready) begin
						fifo_wr_data <= s_axis_tdata;
						fifo_wr_en <= 1;
					end else begin
						fifo_wr_data <= 0;
						fifo_wr_en <= 0;
					end
				end else begin
					s_axis_tready <= 0;
					fifo_wr_data <= 0;
					fifo_wr_en <= 0;
				end

				if(data_gen_ap_done) begin
					data_gen_ap_start <= 0;
					data_gen_times <= data_gen_times + 1;
				end

				if(data_gen_times == times && fifo_empty) begin
					ap_done <= 1;
				end
			end

			if(ap_done) begin
				ap_done <= 0;
				ap_ready <= 0;
				ap_idle <= 1;

				s_axis_tready <= 0;
			end
		end
	end

	// fifo -> drain
	always @(posedge ap_clk) begin
		if(ap_start && ap_ready) begin
			if(! fifo_empty) begin
				fifo_rd_en <= 1;
			end else begin
				fifo_rd_en <= 0;
			end
		end
	end

endmodule