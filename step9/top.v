`resetall
`timescale 10ns / 1ps
`default_nettype none

module top #
(
	parameter PORTS = 32,
	parameter HIGH_CYCLES = 3,
	parameter LOW_CYCLES = 64
)
(
	input wire              			clk,
	input wire              			rst,

	input wire[PORTS-1:0]   			intr,

	output reg             				intr_vec_req,
	output reg[$clog2(PORTS)-1:0]       intr_num
);

parameter STATE_BITS = 3;
localparam [STATE_BITS-1:0]
	STATE_IDLE = 'd0,
	STATE_STEP1 = 'd1,
	STATE_STEP2 = 'd2,
	STATE_STEP3 = 'd3,
	STATE_STEP4 = 'd4,
	STATE_STEP5 = 'd5;

reg [STATE_BITS-1:0]    	state_cur;
reg [PORTS-1:0]         	intr_cur, intr_last, intr_next;
wire 		  				prio_enc_valid;
wire [$clog2(PORTS)-1:0] 	prio_enc_encoded;
wire [PORTS-1:0]         	prio_env_unencoded;
reg [7:0]					cycles_cur;

priority_encoder #(
	.WIDTH(PORTS),
	.LSB_HIGH_PRIORITY(1)
)
priority_encoder_inst (
	.input_unencoded(intr_cur),
	.output_valid(prio_enc_valid),
	.output_encoded(prio_enc_encoded),
	.output_unencoded(prio_env_unencoded)
);

always @(posedge clk) begin
	if (rst) begin
		intr_vec_req <= 0;
		intr_last <= 'h0;
		state_cur <= STATE_IDLE;
	end else begin
		case (state_cur)
			STATE_IDLE: begin
				if (intr != intr_last) begin
					intr_cur <= intr;
					state_cur <= STATE_STEP1;
				end
			end

			STATE_STEP1: begin
				intr_last <= intr_cur;
				state_cur <= STATE_STEP2;
			end

			STATE_STEP2: begin
				if(prio_enc_valid) begin
					intr_vec_req <= 1;
					intr_num <= prio_enc_encoded;
					intr_next <= intr_cur & ~prio_env_unencoded;

					cycles_cur <= HIGH_CYCLES;
					state_cur <= STATE_STEP3;
				end
				else begin
					state_cur <= STATE_IDLE;
				end
			end

			STATE_STEP3: begin
				if(cycles_cur == 1) begin
					state_cur <= STATE_STEP4;
				end
				else begin
					cycles_cur <= cycles_cur - 1;
				end
			end

			STATE_STEP4: begin
				intr_vec_req <= 0;
				intr_num <= 'h0;
				intr_cur <= intr_next;

				cycles_cur <= LOW_CYCLES;
				state_cur <= STATE_STEP5;
			end

			STATE_STEP5: begin
				if(cycles_cur == 1) begin
					state_cur <= STATE_STEP2;
				end
				else begin
					cycles_cur <= cycles_cur - 1;
				end
			end
		endcase
	end
end

endmodule
