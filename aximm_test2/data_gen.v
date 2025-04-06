`timescale 1 ns / 1 ps

module data_gen
#(
	parameter WIDTH = 32
)
(
	input ap_clk,
	input ap_rst_n,

	input [31:0] size,

	input ap_start,
	output reg ap_done,
	output reg ap_idle,
	output reg ap_ready,

	output reg [WIDTH-1:0] tdata,
	output reg tvalid,
	output reg tlast,
	input tready
);

	localparam
		IDLE = 'b000,
		START = 'b001,
		DONE = 'b010;

	reg [2:0] state, state_next;
	reg [31:0] count, count_next;
	reg [7:0] data_seed, data_seed_next;

	// tdata
	genvar i;
	generate
		for (i = 0; i < WIDTH / 8; i = i + 1) begin
			always_comb begin
				tdata[8*(i+1)-1:8*i] = data_seed + i;
			end
		end
	endgenerate

	always_comb begin
		state_next = state;
		count_next = count;
		data_seed_next = data_seed;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 1;
		tvalid = 0;
		tlast = 0;

		// $display("state=%0d, count=%0d, size=%0d", state, count, size);

		case(state)
			IDLE: begin
				if(ap_start) begin
					count_next = 0;
					data_seed_next = 'h80;

					ap_ready = 1;
					ap_idle = 0;
					state_next = START;
				end
			end
			START: begin
				ap_idle = 0;

				tvalid = (count < size);

				if (tvalid && tready) begin
					if(count == size - 1) begin
						tlast = 1;
						ap_done = 1;
						state_next = IDLE;
					end else begin
						count_next = count + 1;
						data_seed_next = data_seed + WIDTH / 8;
					end
				end
			end
		endcase
	end

	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;

			state <= IDLE;
			count <= 0;
			data_seed <= 0;
		end else begin
			state <= state_next;
			count <= count_next;
			data_seed <= data_seed_next;
		end
	end

endmodule
