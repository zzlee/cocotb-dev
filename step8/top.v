`resetall
`timescale 10ns / 1ps
`default_nettype none

module top #
(
	parameter PORTS = 4,
	parameter INTR_CYCLES = 1
)
(
	input wire              clk,
	input wire              rst,

	input wire[PORTS-1:0]   intr,

	output reg             intr_vec_req,
	output reg[31:0]       intr_num
);

parameter STATE_BITS = 3;
localparam [STATE_BITS-1:0]
	STATE_IDLE = STATE_BITS'('d0),
	STATE_STEP1 = STATE_BITS'('d1),
	STATE_STEP2 = STATE_BITS'('d2),
	STATE_STEP3 = STATE_BITS'('d3),
	STATE_STEP4 = STATE_BITS'('d4),
	STATE_STEP5 = STATE_BITS'('d5);

reg [STATE_BITS-1:0]    	state_cur = STATE_IDLE, state_next;
reg [PORTS-1:0]         	intr_cur, intr_last, intr_next;
reg            				prio_enc_valid;
reg [$clog2(PORTS)-1:0] 	prio_enc_encoded;
reg [PORTS-1:0]         	intr_mask;
reg [7:0]					cycles_cur;
reg [7:0]					cycles_next;

priority_encoder #(
	.WIDTH(PORTS),
	.LSB_HIGH_PRIORITY(1)
)
priority_encoder_inst (
	.input_unencoded(intr_cur),
	.output_valid(prio_enc_valid),
	.output_encoded(prio_enc_encoded),
	.output_unencoded(intr_mask)
);

always @(posedge clk) begin
	if (rst) begin
		intr_vec_req <= 0;
		intr_num <= PORTS'('h0);
		intr_cur <= PORTS'('h0);
		intr_last <= PORTS'('h0);
		cycles_cur <= INTR_CYCLES;
		cycles_next <= INTR_CYCLES;
		state_next <= STATE_IDLE;
		state_cur <= STATE_IDLE;
	end else begin
		state_cur <= state_next;
		cycles_cur <= cycles_next;
	end
end

// FSM
always @* begin
	state_next = state_cur;

	case (state_cur)
		STATE_IDLE: begin
			intr_cur = intr;

			if (intr_cur != intr_last) begin
				state_next = STATE_STEP1;
			end
		end

		STATE_STEP1: begin
			intr_last = intr_cur;
			state_next = STATE_STEP2;
		end

		STATE_STEP2: begin
			if(prio_enc_valid) begin
				intr_vec_req = 1;
				intr_num = intr_mask;
				intr_next = intr_cur & ~intr_mask;

				cycles_next = INTR_CYCLES;
				state_next = STATE_STEP3;
			end
			else begin
				state_next = STATE_IDLE;
			end
		end

		STATE_STEP3: begin
			if(cycles_cur == 1) begin
				state_next = STATE_STEP4;
			end
			else begin
				cycles_next = cycles_next - 1;
			end
		end

		STATE_STEP4: begin
			intr_vec_req = 0;
			intr_num = PORTS'('h0);
			intr_cur = intr_next;

			cycles_next = INTR_CYCLES;
			state_next = STATE_STEP5;
		end

		STATE_STEP5: begin
			if(cycles_cur == 1) begin
				state_next = STATE_STEP2;
			end
			else begin
				cycles_next = cycles_next - 1;
			end
		end
	endcase
end

endmodule
