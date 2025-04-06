`timescale 1 ns / 1 ps

module fifo_drain # (
	parameter WIDTH = 8
)
(
	input ap_clk,
	input ap_rst_n,

	input [31:0] size,
	input [31:0] times,

	output reg fifo_rd_en,
	input [WIDTH-1:0] fifo_rd_data,
	input fifo_empty,

	input ap_start,
	output reg ap_idle,
	output reg ap_ready,
	output reg ap_done
);

	// ap control
	localparam
		IDLE = 'b000,
		READY = 'b001,
		START = 'b010,
		NEXT = 'b011;

	reg [2:0] state, state_next;
	reg [31:0] size_count, size_count_next;
	reg [31:0] times_count, times_count_next;

	always_comb begin
		state_next = state;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 1;
		fifo_rd_en = 0;
		size_count_next = size_count;
		times_count_next = times_count;

		case(state)
			IDLE: begin
				if(ap_start) begin
					ap_ready = 1;
					ap_idle = 0;
					state_next = READY;
				end
			end
			READY: begin
				ap_idle = 0;
				size_count_next = 1;
				times_count_next = 1;

				if(fifo_empty) begin
					state_next = NEXT;
				end else begin
					fifo_rd_en = 1;
					state_next = START;
				end

			end
			START: begin
				ap_idle = 0;

				if(size_count == size) begin
					if(times_count == times) begin
						ap_done = 1;
						state_next = IDLE;
					end else begin
						size_count_next = 1;
						times_count_next = times_count + 1;

						if(fifo_empty) begin
							state_next = NEXT;
						end else begin
							fifo_rd_en = 1;
						end
					end
				end else begin
					size_count_next = size_count + 1;

					if(fifo_empty) begin
						state_next = NEXT;
					end else begin
						fifo_rd_en = 1;
					end
				end
			end
			NEXT: begin
				ap_idle = 0;

				if(! fifo_empty) begin
					fifo_rd_en = 1;
					state_next = START;
				end
			end
		endcase
	end

	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;
			fifo_rd_en <= 0;
			size_count <= 0;
			times_count <= 0;
			state <= IDLE;
		end else begin
			state <= state_next;
			size_count <= size_count_next;
			times_count <= times_count_next;
		end
	end

// synthesis translate_off
	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
		end else begin
			case(state)
				START: begin
					$display("---- %0d", fifo_rd_data);
				end
				NEXT: begin
					$display("???? %0d", fifo_rd_data);
				end
			endcase
		end
	end
// synthesis translate_on

endmodule