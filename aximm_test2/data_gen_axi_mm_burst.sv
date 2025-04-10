`timescale 1ns / 1ps

module data_gen_axi_mm_burst #(
	parameter AXI_DATA_WIDTH  = 32,           // AXI MM 數據寬度 (位元) - 假設與 AXIS 相同
	parameter AXI_ADDR_WIDTH  = 32,           // AXI MM 地址寬度 (位元)
	parameter MAX_BURST_LEN   = 16,           // 最大 AXI 突發長度 (beat count, e.g., 16, 64, 256)
											  // AXI4 支持最大 256 (AWLEN=255)
	// 計算 AWSIZE (log2(bytes))
	parameter C_AXI_SIZE      = $clog2(AXI_DATA_WIDTH/8),
	// 計算 AWLEN (burst length - 1)
	parameter C_AXI_AWLEN     = MAX_BURST_LEN - 1,
	// 計算突發計數器寬度
	parameter BURST_CNT_WIDTH = $clog2(MAX_BURST_LEN)
) (
	// Global Signals
	input wire ACLK,
	input wire ARESETn,

	// Configuration Input
	input wire [AXI_ADDR_WIDTH-1:0]   BASE_ADDR, // 目標內存起始地址
	input wire [15:0]                 BYTES,
	input wire [15:0]                 REPEAT,
	input wire                        START,       // 啟動傳輸信號 (pulse or level)
	output reg                        BUSY,        // 模塊忙碌狀態
	output reg                        DONE,        // 傳輸完成信號 (pulse)
	// output reg ERROR, // 可選：錯誤狀態

	// AXI Master Interface (Output to Memory)
	// Write Address Channel
	output reg [AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
	output reg [2:0]                  m_axi_awprot,
	output reg                        m_axi_awvalid,
	input  wire                       m_axi_awready,
	output reg [7:0]                  m_axi_awlen,   // Burst length - 1
	output reg [2:0]                  m_axi_awsize,  // Based on AXI_DATA_WIDTH
	output reg [1:0]                  m_axi_awburst, // INCR burst

	// Write Data Channel
	output reg [AXI_DATA_WIDTH-1:0]   m_axi_wdata,
	output reg [AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,   // Assume full strobe
	output reg                        m_axi_wlast,
	output reg                        m_axi_wvalid,
	input  wire                       m_axi_wready,

	// Write Response Channel
	input  wire [1:0]                 m_axi_bresp,
	input  wire                       m_axi_bvalid,
	output reg                        m_axi_bready
);

	// Check if widths match (for simplicity)
	initial begin
		if (MAX_BURST_LEN > 256 || MAX_BURST_LEN < 1) begin
			 $display("Error: MAX_BURST_LEN (%0d) must be between 1 and 256.", MAX_BURST_LEN);
			$finish;
		end
	end

	// State Machine Definition
	typedef enum logic [2:0] {
		IDLE          = 3'b000, // 等待啟動
		START_BURST   = 3'b001, // 發送寫地址 (開始新突發)
		WAIT_AWREADY  = 3'b010, // 等待地址接受
		WRITE_BURST   = 3'b011, // 寫入突發數據
		WAIT_BRESP    = 3'b100, // 等待寫響應
		FINISH        = 3'b101  // 完成狀態 (產生 DONE 信號)
		// Note: No explicit WAIT_WREADY state, handled within WRITE_BURST
	} state_t;

	reg [2:0] state_reg, state_next;

	// Internal Registers
	reg [AXI_ADDR_WIDTH-1:0]  current_addr_reg, current_addr_next;
	reg [BURST_CNT_WIDTH-1:0] beats_written_reg, beats_written_next; // 當前突發已寫入的 beat 數
	reg                       start_latch;
	reg [15:0]                bytes_written_reg, bytes_written_next;
	reg [15:0]                repeat_times_reg, repeat_times_next;

	// Internal Signals

	// =========================================================================
	// State Machine Logic (Combinational)
	// =========================================================================
	always_comb begin
		// Default assignments
		state_next = state_reg;
		current_addr_next = current_addr_reg;
		beats_written_next = beats_written_reg;
		bytes_written_next = bytes_written_reg;
		repeat_times_next = repeat_times_reg;

		m_axi_awvalid = 1'b0;
		m_axi_wvalid = 1'b0;
		m_axi_wlast = 1'b0; // Default wlast low
		m_axi_bready = 1'b0;

		BUSY = 1'b1; // Default busy
		DONE = 1'b0;

		// AXI W channel assignments (driven by skid buffer output)
		m_axi_wdata = 0;
		m_axi_wvalid = (state_reg == WRITE_BURST); // WVALID is skid_valid only in WRITE_BURST state

		case (state_reg)
			IDLE: begin
				BUSY = 1'b0;
				beats_written_next = '0; // Reset counter
				repeat_times_next = '0;
				if (START) begin
					state_next = START_BURST;
					current_addr_next = BASE_ADDR;
				end
			end

			START_BURST: begin
				beats_written_next = '0;
				state_next = WAIT_AWREADY;
			end

			WAIT_AWREADY: begin
				state_next = WRITE_BURST;
			end

			WRITE_BURST: begin
				beats_written_next = beats_written_reg + 1;
				bytes_written_next = bytes_written_reg + AXI_DATA_WIDTH/8;
				if(beats_written_reg == C_AXI_AWLEN) begin
					state_next = WAIT_BRESP;
				end
			end

			WAIT_BRESP: begin
				if(bytes_written_reg == BYTES) begin
					bytes_written_next = '0;
					repeat_times_next = repeat_times_reg + 1;
					if(repeat_times_reg == REPEAT - 1) begin
						state_next = FINISH;
					end else begin
						state_next = START_BURST;
					end
				end else begin
					state_next = START_BURST;
				end
			end

			FINISH: begin
				DONE = 1'b1; // Assert DONE for one cycle
				state_next = IDLE;
			end

			default: state_next = IDLE;
		endcase
	end

	// =========================================================================
	// State Machine Logic (Sequential)
	// =========================================================================
	always_ff @(posedge ACLK) begin
		if (!ARESETn) begin
			state_reg <= IDLE;
			current_addr_reg <= {AXI_ADDR_WIDTH{1'b0}};
			beats_written_reg <= '0;
			bytes_written_reg <= '0;
			repeat_times_reg <= '0;
			start_latch <= 1'b0;
		end else begin
			state_reg <= state_next;
			current_addr_reg <= current_addr_next;
			beats_written_reg <= beats_written_next;
			bytes_written_reg <= bytes_written_next;
			repeat_times_reg <= repeat_times_next;

			 // Latch logic for START signal
			if (state_reg == IDLE) begin
				start_latch <= state_next == IDLE ? 1'b0 : 1'b1;
			end else if (state_next == IDLE) begin
				start_latch <= 1'b0;
			end
		end
	end

	// =========================================================================
	// AXI Master Interface Signal Assignments
	// =========================================================================

	// --- Write Address Channel ---
	assign m_axi_awaddr  = current_addr_reg; // Address for the current/next burst
	assign m_axi_awprot  = 3'b000;           // Normal, Secure, Data access
	assign m_axi_awlen   = C_AXI_AWLEN;      // Fixed burst length - 1
	assign m_axi_awsize  = C_AXI_SIZE;       // Transfer size based on data width
	assign m_axi_awburst = 2'b01;            // INCR burst type
	// m_axi_awvalid assigned in state machine logic

	// --- Write Data Channel ---
	// m_axi_wdata assigned combinatorially from skid buffer output
	assign m_axi_wstrb = {(AXI_DATA_WIDTH/8){1'b1}}; // Assume writing all bytes
	// m_axi_wlast assigned in state machine logic
	// m_axi_wvalid assigned in state machine logic

	// --- Write Response Channel ---
	// m_axi_bready assigned in state machine logic

endmodule
