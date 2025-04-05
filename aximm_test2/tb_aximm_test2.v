`timescale 1 ns / 1 ps

module tb_aximm_test2(
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
	// m_axi_mm_video_AWPROT,
	// m_axi_mm_video_AWQOS,
	// m_axi_mm_video_AWREGION,
	// m_axi_mm_video_AWUSER,
	m_axi_mm_video_WVALID,
	m_axi_mm_video_WREADY,
	m_axi_mm_video_WDATA,
	// m_axi_mm_video_WSTRB,
	m_axi_mm_video_WLAST,
	// m_axi_mm_video_WID,
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
	parameter    C_M_AXI_MM_VIDEO_ADDR_WIDTH = 64;
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
	// output  [2:0] m_axi_mm_video_AWPROT;
	// output  [3:0] m_axi_mm_video_AWQOS;
	// output  [3:0] m_axi_mm_video_AWREGION;
	// output  [C_M_AXI_MM_VIDEO_AWUSER_WIDTH - 1:0] m_axi_mm_video_AWUSER;
	output reg  m_axi_mm_video_WVALID;
	input  reg m_axi_mm_video_WREADY;
	output reg [C_M_AXI_MM_VIDEO_DATA_WIDTH - 1:0] m_axi_mm_video_WDATA;
	// output  [C_M_AXI_MM_VIDEO_WSTRB_WIDTH - 1:0] m_axi_mm_video_WSTRB;
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

	wire [C_M_AXI_MM_VIDEO_DATA_WIDTH-1:0] s_axis_tdata;
	wire s_axis_tvalid;
	wire s_axis_tlast;
	reg [31:0] data_gen_size;
	reg data_gen_ap_start, data_gen_ap_start_next;
	wire data_gen_ap_done;
	wire data_gen_ap_idle;
	wire data_gen_ap_ready;
	reg s_axis_tready, s_axis_tready_next;
	reg [31:0] data_gen_times, data_gen_times_next;

	assign data_gen_size = (nSize >> $clog2(C_M_AXI_MM_VIDEO_DATA_WIDTH / 8));

	data_gen #(
		.WIDTH(C_M_AXI_MM_VIDEO_DATA_WIDTH)
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
	reg [C_M_AXI_MM_VIDEO_DATA_WIDTH-1:0] fifo_wr_data, fifo_wr_data_next;
	reg fifo_rd_en;
	wire [C_M_AXI_MM_VIDEO_DATA_WIDTH-1:0] fifo_rd_data;
	wire fifo_empty;
	wire fifo_full;

	fifo #(
		.DEPTH(),
		.WIDTH(C_M_AXI_MM_VIDEO_DATA_WIDTH)
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

	always @ (*) begin
		ap_rst_n_inv = ~ap_rst_n;
	end

	localparam
		C_STATE_BITS = 2,
		C_MAX_AWLEN = 'd255,
		C_M_AXI_MM_VIDEO_DATA_BYTES = C_M_AXI_MM_VIDEO_DATA_WIDTH >> 3;

	localparam
		IDLE = 0,
		READY = 1,
		START = 2,
		DONE = 3;

	reg [C_STATE_BITS-1:0] state, state_next;

	always_comb begin
		state_next = state;
		s_axis_tready_next = s_axis_tready;
		data_gen_ap_start_next = data_gen_ap_start;
		data_gen_times_next = data_gen_times;
		fifo_wr_en = 0;
		fifo_wr_data = 0;
		ap_ready = 0;
		ap_done = 0;
		ap_idle = 1;

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
				data_gen_ap_start_next = 1;
				data_gen_times_next = 0;
				s_axis_tready_next = 1;
				state_next = START;
			end
			START: begin
				ap_idle = 0;
				data_gen_ap_start_next = 0;
				s_axis_tready_next = !fifo_full;

				if (s_axis_tvalid && s_axis_tready) begin
					fifo_wr_en = 1;
					fifo_wr_data = s_axis_tdata;
					$display(">>>> %0d", fifo_wr_data);
				end

				if(data_gen_ap_done) begin
					s_axis_tready_next = 0;
					data_gen_ap_start_next = 0;
					state_next = DONE;
				end

				if(data_gen_times == nTimes) begin
					s_axis_tready_next = 0;
					ap_done = 1;
					state_next = IDLE;
				end
			end
			DONE: begin
				ap_idle = 0;
				data_gen_ap_start_next = 1;
				data_gen_times_next = data_gen_times + 1;
				s_axis_tready_next = 1;
				state_next = START;
			end
		endcase
	end

	always_ff @(posedge ap_clk or negedge ap_rst_n) begin
		if (!ap_rst_n) begin
			ap_ready <= 0;
			ap_done <= 0;
			ap_idle <= 1;

			data_gen_times <= 0;
			data_gen_ap_start <= 0;
			s_axis_tready <= 0;
			fifo_wr_en <= 0;
			fifo_rd_en <= 0;
			state <= IDLE;
		end else begin
			data_gen_times <= data_gen_times_next;
			data_gen_ap_start <= data_gen_ap_start_next;
			s_axis_tready <= s_axis_tready_next;
			state <= state_next;
		end
	end

	reg [1:0] fifo_drain_state;

	localparam
		FIFO_READY = 0,
		FIFO_READ_0 = 1,
		FIFO_READ = 2;

	// fifo -> drain
	always @(posedge ap_clk or negedge ap_rst_n) begin
		if(! ap_rst_n) begin
			fifo_rd_en <= 0;
			fifo_drain_state <= FIFO_READY;
		end else begin
			case(fifo_drain_state)
				FIFO_READY: begin
					if(! fifo_empty) begin
						fifo_rd_en <= 1;
						fifo_drain_state <= FIFO_READ_0;
					end
				end
				FIFO_READ_0: begin
					$display("???? %0d", fifo_rd_data);

					fifo_drain_state <= FIFO_READ;
				end
				FIFO_READ: begin
					$display("---- %0d", fifo_rd_data);

					if(fifo_empty) begin
						fifo_rd_en <= 0;
						fifo_drain_state <= FIFO_READY;
					end
				end
			endcase
		end
	end

	// m_axi_mm_video_AWLEN
	// genvar i;
	// generate
	// 	for (i = 1; i <= C_MAX_AWLEN; i = i + 1) begin

	// always @(posedge ap_clk) begin
	// 	if (!ap_rst_n)
	// 		m_axi_mm_video_AWLEN <= 0;
	// 	else if (ap_ready_int && !fifo_empty && state == IDLE && nTimes_int > 0) begin
	// 		if (nSize_int <= C_M_AXI_MM_VIDEO_DATA_BYTES*i) begin
	// 			m_axi_mm_video_AWLEN <= i-1;
	// 			nBurstSize <= C_M_AXI_MM_VIDEO_DATA_BYTES*i;
	// 			nSize_int <= nSize_int - C_M_AXI_MM_VIDEO_DATA_BYTES*i;
	// 		end
	// 	end
	// end

	// 	end
	// endgenerate

endmodule