module tb_axis_to_axi_mm_burst (
	s_axi_control_AWVALID,
	s_axi_control_AWREADY,
	s_axi_control_AWADDR,
	s_axi_control_WVALID,
	s_axi_control_WREADY,
	s_axi_control_WDATA,
	s_axi_control_WSTRB,
	s_axi_control_ARVALID,
	s_axi_control_ARREADY,
	s_axi_control_ARADDR,
	s_axi_control_RVALID,
	s_axi_control_RREADY,
	s_axi_control_RDATA,
	s_axi_control_RRESP,
	s_axi_control_BVALID,
	s_axi_control_BREADY,
	s_axi_control_BRESP,
	ap_clk,
	ap_rst_n,
	interrupt,
	m_axi_mm_video_AWVALID,
	m_axi_mm_video_AWREADY,
	m_axi_mm_video_AWADDR,
	m_axi_mm_video_AWID,
	m_axi_mm_video_AWLEN,
	m_axi_mm_video_AWSIZE,
	m_axi_mm_video_AWBURST,
	// m_axi_mm_video_AWLOCK,
	// m_axi_mm_video_AWCACHE,
	m_axi_mm_video_AWPROT,
	// m_axi_mm_video_AWQOS,
	// m_axi_mm_video_AWREGION,
	// m_axi_mm_video_AWUSER,
	m_axi_mm_video_WVALID,
	m_axi_mm_video_WREADY,
	m_axi_mm_video_WDATA,
	m_axi_mm_video_WSTRB,
	m_axi_mm_video_WLAST,
	m_axi_mm_video_WID,
	// m_axi_mm_video_WUSER,
	m_axi_mm_video_ARVALID,
	m_axi_mm_video_ARREADY,
	m_axi_mm_video_ARADDR,
	m_axi_mm_video_ARID,
	m_axi_mm_video_ARLEN,
	m_axi_mm_video_ARSIZE,
	m_axi_mm_video_ARBURST,
	m_axi_mm_video_ARLOCK,
	m_axi_mm_video_ARCACHE,
	m_axi_mm_video_ARPROT,
	m_axi_mm_video_ARQOS,
	m_axi_mm_video_ARREGION,
	m_axi_mm_video_ARUSER,
	m_axi_mm_video_RVALID,
	m_axi_mm_video_RREADY,
	m_axi_mm_video_RDATA,
	m_axi_mm_video_RLAST,
	m_axi_mm_video_RID,
	m_axi_mm_video_RUSER,
	m_axi_mm_video_RRESP,
	m_axi_mm_video_BVALID,
	m_axi_mm_video_BREADY,
	m_axi_mm_video_BRESP,
	m_axi_mm_video_BID,
	m_axi_mm_video_BUSER
);

	parameter    C_S_AXI_CONTROL_DATA_WIDTH = 32;
	parameter    C_S_AXI_CONTROL_ADDR_WIDTH = 6;
	parameter    C_S_AXI_DATA_WIDTH = 32;
	parameter    C_M_AXI_MM_VIDEO_ID_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_ADDR_WIDTH = 32;
	parameter    C_M_AXI_MM_VIDEO_DATA_WIDTH = 8;
	parameter    C_M_AXI_MM_VIDEO_AWUSER_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_ARUSER_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_WUSER_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_RUSER_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_BUSER_WIDTH = 1;
	parameter    C_M_AXI_MM_VIDEO_USER_VALUE = 0;
	parameter    C_M_AXI_MM_VIDEO_PROT_VALUE = 0;
	parameter    C_M_AXI_MM_VIDEO_CACHE_VALUE = 3;
	parameter    C_M_AXI_DATA_WIDTH = 32;

	parameter C_S_AXI_CONTROL_WSTRB_WIDTH = (C_S_AXI_CONTROL_DATA_WIDTH / 8);
	// parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);
	parameter C_M_AXI_MM_VIDEO_WSTRB_WIDTH = (C_M_AXI_MM_VIDEO_DATA_WIDTH / 8);
	// parameter C_M_AXI_WSTRB_WIDTH = (32 / 8);

	input   s_axi_control_AWVALID;
	output   s_axi_control_AWREADY;
	input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
	input   s_axi_control_WVALID;
	output   s_axi_control_WREADY;
	input  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
	input  [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
	input   s_axi_control_ARVALID;
	output   s_axi_control_ARREADY;
	input  [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
	output   s_axi_control_RVALID;
	input   s_axi_control_RREADY;
	output  [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
	output  [1:0] s_axi_control_RRESP;
	output   s_axi_control_BVALID;
	input   s_axi_control_BREADY;
	output  [1:0] s_axi_control_BRESP;
	input   ap_clk;
	input   ap_rst_n;
	output   interrupt;
	output reg  m_axi_mm_video_AWVALID;
	input   m_axi_mm_video_AWREADY;
	output reg [C_M_AXI_MM_VIDEO_ADDR_WIDTH - 1:0] m_axi_mm_video_AWADDR;
	output reg [C_M_AXI_MM_VIDEO_ID_WIDTH - 1:0] m_axi_mm_video_AWID;
	output reg [7:0] m_axi_mm_video_AWLEN;
	output reg [2:0] m_axi_mm_video_AWSIZE;
	output reg [1:0] m_axi_mm_video_AWBURST;
	// output  [1:0] m_axi_mm_video_AWLOCK;
	// output  [3:0] m_axi_mm_video_AWCACHE;
	output  [2:0] m_axi_mm_video_AWPROT;
	// output  [3:0] m_axi_mm_video_AWQOS;
	// output  [3:0] m_axi_mm_video_AWREGION;
	// output  [C_M_AXI_MM_VIDEO_AWUSER_WIDTH - 1:0] m_axi_mm_video_AWUSER;
	output reg  m_axi_mm_video_WVALID;
	input  reg m_axi_mm_video_WREADY;
	output reg [C_M_AXI_MM_VIDEO_DATA_WIDTH - 1:0] m_axi_mm_video_WDATA;
	output  [C_M_AXI_MM_VIDEO_WSTRB_WIDTH - 1:0] m_axi_mm_video_WSTRB;
	output reg  m_axi_mm_video_WLAST;
	output reg [C_M_AXI_MM_VIDEO_ID_WIDTH - 1:0] m_axi_mm_video_WID;
	// output  [C_M_AXI_MM_VIDEO_WUSER_WIDTH - 1:0] m_axi_mm_video_WUSER;
	output   m_axi_mm_video_ARVALID;
	input   m_axi_mm_video_ARREADY;
	output  [C_M_AXI_MM_VIDEO_ADDR_WIDTH - 1:0] m_axi_mm_video_ARADDR;
	output  [C_M_AXI_MM_VIDEO_ID_WIDTH - 1:0] m_axi_mm_video_ARID;
	output  [7:0] m_axi_mm_video_ARLEN;
	output  [2:0] m_axi_mm_video_ARSIZE;
	output  [1:0] m_axi_mm_video_ARBURST;
	output  [1:0] m_axi_mm_video_ARLOCK;
	output  [3:0] m_axi_mm_video_ARCACHE;
	output  [2:0] m_axi_mm_video_ARPROT;
	output  [3:0] m_axi_mm_video_ARQOS;
	output  [3:0] m_axi_mm_video_ARREGION;
	output  [C_M_AXI_MM_VIDEO_ARUSER_WIDTH - 1:0] m_axi_mm_video_ARUSER;
	input   m_axi_mm_video_RVALID;
	output   m_axi_mm_video_RREADY;
	input  [C_M_AXI_MM_VIDEO_DATA_WIDTH - 1:0] m_axi_mm_video_RDATA;
	input   m_axi_mm_video_RLAST;
	input  [C_M_AXI_MM_VIDEO_ID_WIDTH - 1:0] m_axi_mm_video_RID;
	input  [C_M_AXI_MM_VIDEO_RUSER_WIDTH - 1:0] m_axi_mm_video_RUSER;
	input  [1:0] m_axi_mm_video_RRESP;
	input   m_axi_mm_video_BVALID;
	output reg  m_axi_mm_video_BREADY;
	input  [1:0] m_axi_mm_video_BRESP;
	input  [C_M_AXI_MM_VIDEO_ID_WIDTH - 1:0] m_axi_mm_video_BID;
	input  [C_M_AXI_MM_VIDEO_BUSER_WIDTH - 1:0] m_axi_mm_video_BUSER;

	reg    ap_rst_n_inv;
	reg   [63:0] pDstPxl;
	reg   [31:0] nSize;
	reg   [31:0] nTimes;
	wire    ap_start;
	reg    ap_ready;
	reg    ap_done;
	reg    ap_idle;

	assign ap_rst_n_inv = ~ap_rst_n;
	assign m_axi_mm_video_AWID = 0;
	assign m_axi_mm_video_WID = 0;

	aximm_test2_control_s_axi #(
		.C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
		.C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH )
	)
	control_s_axi_U(
		.AWVALID(s_axi_control_AWVALID),
		.AWREADY(s_axi_control_AWREADY),
		.AWADDR(s_axi_control_AWADDR),
		.WVALID(s_axi_control_WVALID),
		.WREADY(s_axi_control_WREADY),
		.WDATA(s_axi_control_WDATA),
		.WSTRB(s_axi_control_WSTRB),
		.ARVALID(s_axi_control_ARVALID),
		.ARREADY(s_axi_control_ARREADY),
		.ARADDR(s_axi_control_ARADDR),
		.RVALID(s_axi_control_RVALID),
		.RREADY(s_axi_control_RREADY),
		.RDATA(s_axi_control_RDATA),
		.RRESP(s_axi_control_RRESP),
		.BVALID(s_axi_control_BVALID),
		.BREADY(s_axi_control_BREADY),
		.BRESP(s_axi_control_BRESP),
		.ACLK(ap_clk),
		.ARESET(ap_rst_n_inv),
		.ACLK_EN(1'b1),
		.pDstPxl(pDstPxl),
		.nSize(nSize),
		.nTimes(nTimes),
		.interrupt(interrupt),
		.ap_start(ap_start),
		.ap_ready(ap_ready),
		.ap_done(ap_done),
		.ap_idle(ap_idle)
	);

	reg data_gen_ap_rst_n;
	reg data_gen_i_enable;
	reg [31:0] data_gen_i_n_value;
	wire m_axis_tvalid;
	wire [C_M_AXI_MM_VIDEO_DATA_WIDTH-1:0] m_axis_tdata;
	wire m_axis_tlast;
	wire m_axis_tready;

	axis_number_generator #(
		.DATA_WIDTH(C_M_AXI_MM_VIDEO_DATA_WIDTH)
	) axis_number_generator_U (
		// --- System Signals ---
		.aclk(ap_clk),         // Clock
		.aresetn(data_gen_ap_rst_n),      // Asynchronous Reset, active low

		// --- Control Inputs ---
		.i_enable(data_gen_i_enable),     // Enable signal to start generation for a new sequence
		.i_n_value(data_gen_i_n_value), // The upper limit 'N' (generates 1, 2, ..., N)

		// --- AXI Stream Master Interface ---
		.m_axis_tvalid(m_axis_tvalid), // Output valid signal
		.m_axis_tdata(m_axis_tdata),  // Output data (the numbers)
		.m_axis_tlast(m_axis_tlast),  // Output last signal (high for the last number N)
		.s_axis_tready(m_axis_tready)  // Input ready signal from the downstream slave
	);

	reg [C_M_AXI_MM_VIDEO_ADDR_WIDTH-1:0] aximm_BASE_ADDR;
	reg aximm_START;
	wire aximm_BUSY;
	wire aximm_DONE;

	axis_to_axi_mm_burst #(
		.AXIS_DATA_WIDTH(C_M_AXI_MM_VIDEO_DATA_WIDTH),           // AXI Stream 數據寬度 (位元)
		.AXI_DATA_WIDTH(C_M_AXI_MM_VIDEO_DATA_WIDTH),           // AXI MM 數據寬度 (位元) - 假設與 AXIS 相同
		.AXI_ADDR_WIDTH(C_M_AXI_MM_VIDEO_ADDR_WIDTH),           // AXI MM 地址寬度 (位元)
		.MAX_BURST_LEN(16)           // 最大 AXI 突發長度 (beat count, e.g., 16, 64, 256)
												  // AXI4 支持最大 256 (AWLEN=255)
	) axis_to_axi_mm_burst_U (
		// Global Signals
		.ACLK(ap_clk),
		.ARESETn(ap_rst_n),

		// Configuration Input
		.BASE_ADDR(aximm_BASE_ADDR), // 目標內存起始地址
		.START(aximm_START),       // 啟動傳輸信號 (pulse or level)
		.BUSY(aximm_BUSY),        // 模塊忙碌狀態
		.DONE(aximm_DONE),        // 傳輸完成信號 (pulse)
		// output wire ERROR, // 可選：錯誤狀態

		// AXI Stream Slave Interface (Input)
		.s_axis_tdata(m_axis_tdata),
		.s_axis_tlast(m_axis_tlast),
		.s_axis_tvalid(m_axis_tvalid),
		.s_axis_tready(m_axis_tready),

		// AXI Master Interface (Output to Memory)
		// Write Address Channel
		.m_axi_awaddr(m_axi_mm_video_AWADDR),
		.m_axi_awprot(m_axi_mm_video_AWPROT),
		.m_axi_awvalid(m_axi_mm_video_AWVALID),
		.m_axi_awready(m_axi_mm_video_AWREADY),
		.m_axi_awlen(m_axi_mm_video_AWLEN),   // Burst length - 1
		.m_axi_awsize(m_axi_mm_video_AWSIZE),  // Based on AXI_DATA_WIDTH
		.m_axi_awburst(m_axi_mm_video_AWBURST), // INCR burst

		// Write Data Channel
		.m_axi_wdata(m_axi_mm_video_WDATA),
		.m_axi_wstrb(m_axi_mm_video_WSTRB),   // Assume full strobe
		.m_axi_wlast(m_axi_mm_video_WLAST),
		.m_axi_wvalid(m_axi_mm_video_WVALID),
		.m_axi_wready(m_axi_mm_video_WREADY),

		// Write Response Channel
		.m_axi_bresp(m_axi_mm_video_BRESP),
		.m_axi_bvalid(m_axi_mm_video_BVALID),
		.m_axi_bready(m_axi_mm_video_BREADY)
	);

	// State Machine Definition
	localparam
		IDLE = 'b000,
		START = 'b001,
		START_DMA = 'b010,
		NEXT = 'b011,
		DONE = 'b100;

	reg [2:0] state, state_next;
	reg [31:0] times, times_next;

	always_comb begin
		state_next = state;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 0;
		data_gen_ap_rst_n = 1;
		data_gen_i_enable = 0;
		aximm_START = 0;
		times_next = times;

		case(state)
			IDLE: begin
				ap_idle = 1;

				if(ap_start) begin
					ap_ready = 1;
					data_gen_ap_rst_n = 0;
					times_next = 0;
					state_next = START;
				end
			end

			START: begin
				data_gen_i_n_value = (nSize >> $clog2(C_M_AXI_MM_VIDEO_DATA_WIDTH / 8));
				data_gen_i_enable = 1;
				aximm_BASE_ADDR = pDstPxl;
				aximm_START = 1;
				state_next = START_DMA;
			end

			START_DMA: begin
				if(aximm_DONE) begin
					times_next = times + 1;
					state_next = NEXT;
				end
			end

			NEXT: begin
				if(times == nTimes) begin
					state_next = DONE;
				end else begin
					data_gen_ap_rst_n = 0;
					state_next = START;
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

			state <= IDLE;
			times <= 0;
		end else begin
			state <= state_next;
			times <= times_next;
		end
	end
endmodule
