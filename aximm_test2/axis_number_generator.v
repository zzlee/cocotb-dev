/*
 * Module: axis_number_generator
 * Description: Generates a sequence of numbers from 1 to N on an AXI Stream interface.
 * Parameters:
 * DATA_WIDTH: Width of the tdata signal (should be large enough to hold N)
 */
module axis_number_generator #(
	parameter DATA_WIDTH = 32
) (
	// --- System Signals ---
	input wire aclk,         // Clock
	input wire aresetn,      // Asynchronous Reset, active low

	// --- Control Inputs ---
	input wire i_enable,     // Enable signal to start generation for a new sequence
	input wire [31:0] i_n_value, // The upper limit 'N' (generates 1, 2, ..., N)

	// --- AXI Stream Master Interface ---
	output reg  m_axis_tvalid, // Output valid signal
	output reg  [DATA_WIDTH-1:0] m_axis_tdata,  // Output data (the numbers)
	output reg  m_axis_tlast,  // Output last signal (high for the last number N)
	input wire  s_axis_tready  // Input ready signal from the downstream slave
);

// --- State Machine Definition ---
localparam STATE_IDLE = 2'b00;       // Waiting for enable
localparam STATE_GENERATING = 2'b01; // Generating numbers
localparam STATE_WAIT_LAST = 2'b10; // Special state to handle TLAST correctly if TREADY is low

reg [1:0] r_current_state;
reg [1:0] r_next_state;

// --- Internal Registers ---
reg [31:0] r_counter;    // Counts from 1 to N
reg [31:0] r_n_value;    // Stores the value of N for the current sequence
reg [31:0] r_tdata_start;
reg [DATA_WIDTH-1:0] r_tdata;

// tdata
genvar i;
generate
	for (i = 0; i < DATA_WIDTH / 8; i = i + 1) begin
		always_comb begin
			r_tdata[8*(i+1)-1:8*i] = r_tdata_start + i;
		end
	end
endgenerate

// --- Combinational Logic for State Transitions and Outputs ---
always @(*) begin
	// Default assignments (to avoid latches and define default behavior)
	r_next_state = r_current_state;
	m_axis_tvalid = 1'b0; // Default to not valid
	m_axis_tdata = r_tdata; // Output the current count by default when valid
	m_axis_tlast = 1'b0; // Default to not last

	case (r_current_state)
		STATE_IDLE: begin
			if (i_enable && (i_n_value > 0)) begin // Start condition: enabled and N is valid
				r_next_state = STATE_GENERATING;
				m_axis_tvalid = 1'b1; // First number (1) is ready
				m_axis_tdata = r_tdata;
				if (i_n_value == 1) begin // Check if N=1, special case
					 m_axis_tlast = 1'b1; // If N=1, it's also the last number
				end
			end else begin
				r_next_state = STATE_IDLE; // Stay idle
			end
		end // case STATE_IDLE

		STATE_GENERATING: begin
			m_axis_tvalid = 1'b1; // Data is valid in this state
			m_axis_tdata = r_tdata; // Output current count

			// Check if this is the last number
			if (r_counter == r_n_value) begin
				m_axis_tlast = 1'b1; // Assert TLAST if it's the last number
				if (s_axis_tready) begin // If downstream is ready for the last number
					r_next_state = STATE_IDLE; // Transaction complete, go back to IDLE
				end else begin
					// Downstream not ready for the last beat, stay here but keep TLAST asserted
					r_next_state = STATE_GENERATING;
				end
			end else begin
				// Not the last number
				m_axis_tlast = 1'b0;
				if (s_axis_tready) begin // If downstream accepts the current number
					r_next_state = STATE_GENERATING; // Stay generating, counter increments in sequential block
				end else begin
					// Downstream not ready, stay here, counter doesn't increment
					r_next_state = STATE_GENERATING;
				end
			end
		end // case STATE_GENERATING

		// Default case (should not be reached)
		default: begin
			r_next_state = STATE_IDLE;
		end
	endcase // case (r_current_state)
end

// --- Sequential Logic (Registers update on clock edge) ---
always @(posedge aclk or negedge aresetn) begin
	if (!aresetn) begin
		// Asynchronous reset
		r_current_state <= STATE_IDLE;
		r_counter       <= 0; // Reset counter
		r_n_value       <= 0; // Reset stored N
		r_tdata_start   <= 'h80;
	end else begin
		// Update state register
		r_current_state <= r_next_state;

		// Update counter and stored N based on state transitions
		if (r_current_state == STATE_IDLE && r_next_state == STATE_GENERATING) begin
			 // Transitioning from IDLE to GENERATING: Start sequence
			 r_counter <= 1; // Initialize counter to 1
			 r_n_value <= i_n_value; // Store N for this sequence
			 r_tdata_start <= 'h80;
		end else if (r_current_state == STATE_GENERATING && s_axis_tready) begin
			 // In GENERATING state and downstream accepted data (TREADY is high)
			 if (r_counter < r_n_value) begin // If not the last number yet
				 r_counter <= r_counter + 1; // Increment counter
				 r_tdata_start <= r_tdata_start + DATA_WIDTH / 8;
			 end
			 // Note: If r_counter == r_n_value and s_axis_tready is high,
			 // the state transitions to IDLE (handled by state update logic),
			 // counter value doesn't matter as it resets on the next start.
		end
		// Otherwise (e.g., staying in IDLE, or GENERATING but s_axis_tready is low),
		// keep the current r_counter and r_n_value.
	end // else: !if(!aresetn)
end // always @ (posedge aclk or negedge aresetn)

endmodule // axis_number_generator
