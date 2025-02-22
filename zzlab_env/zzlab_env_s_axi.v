`timescale 1ns/1ps

module zzlab_env_control_s_axi
#(parameter
	C_S_AXI_ADDR_WIDTH = 5,
	C_S_AXI_DATA_WIDTH = 32,
	C_VERSION = 32'h0,
	C_PLATFORM = "YYYY",
	C_BOARD_VERSION = 32'h0
)(
	input  wire                          ACLK,
	input  wire                          ARESET,
	input  wire                          ACLK_EN,
	input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
	input  wire                          AWVALID,
	output wire                          AWREADY,
	input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
	input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
	input  wire                          WVALID,
	output wire                          WREADY,
	output wire [1:0]                    BRESP,
	output wire                          BVALID,
	input  wire                          BREADY,
	input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
	input  wire                          ARVALID,
	output wire                          ARREADY,
	output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
	output wire [1:0]                    RRESP,
	output wire                          RVALID,
	input  wire                          RREADY
);
//------------------------Address Info-------------------

//------------------------Parameter----------------------
localparam
	ADDR_OUT_VERSION        = 5'h10,
	ADDR_OUT_PLATFORM       = 5'h14,
	ADDR_OUT_BOARD_VERSION  = 5'h18,
	ADDR_OUT_TICK_COUNTER   = 5'h1C,
	ADDR_OUT_VALUE0         = 5'h20,
	WRIDLE                  = 2'd0,
	WRDATA                  = 2'd1,
	WRRESP                  = 2'd2,
	WRRESET                 = 2'd3,
	RDIDLE                  = 2'd0,
	RDDATA                  = 2'd1,
	RDRESET                 = 2'd2,
	ADDR_BITS               = 5;

//------------------------Local signal-------------------
	reg  [1:0]                    wstate = WRRESET;
	reg  [1:0]                    wnext;
	reg  [ADDR_BITS-1:0]          waddr;
	wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
	wire                          aw_hs;
	wire                          w_hs;
	reg  [1:0]                    rstate = RDRESET;
	reg  [1:0]                    rnext;
	reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
	wire                          ar_hs;
	wire [ADDR_BITS-1:0]          raddr;
	// internal registers
    reg  [31:0]                   int_out_TickCounter = 'b0;
    reg  [31:0]                   int_out_Value0 = 'b0;

//------------------------Instantiation------------------


//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
	if (ARESET)
		wstate <= WRRESET;
	else if (ACLK_EN)
		wstate <= wnext;
end

// wnext
always @(*) begin
	case (wstate)
		WRIDLE:
			if (AWVALID)
				wnext = WRDATA;
			else
				wnext = WRIDLE;
		WRDATA:
			if (WVALID)
				wnext = WRRESP;
			else
				wnext = WRDATA;
		WRRESP:
			if (BREADY)
				wnext = WRIDLE;
			else
				wnext = WRRESP;
		default:
			wnext = WRIDLE;
	endcase
end

// waddr
always @(posedge ACLK) begin
	if (ACLK_EN) begin
		if (aw_hs)
			waddr <= AWADDR[ADDR_BITS-1:0];
	end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
	if (ARESET)
		rstate <= RDRESET;
	else if (ACLK_EN)
		rstate <= rnext;
end

// rnext
always @(*) begin
	case (rstate)
		RDIDLE:
			if (ARVALID)
				rnext = RDDATA;
			else
				rnext = RDIDLE;
		RDDATA:
			if (RREADY & RVALID)
				rnext = RDIDLE;
			else
				rnext = RDDATA;
		default:
			rnext = RDIDLE;
	endcase
end

// rdata
always @(posedge ACLK) begin
	if (ACLK_EN) begin
		if (ar_hs) begin
			rdata <= 'b0;
			case (raddr)
				ADDR_OUT_VERSION: begin
					rdata <= C_VERSION;
				end
				ADDR_OUT_PLATFORM: begin
					rdata <= C_PLATFORM;
				end
				ADDR_OUT_BOARD_VERSION: begin
					rdata <= C_BOARD_VERSION;
				end
				ADDR_OUT_TICK_COUNTER: begin
					rdata <= int_out_TickCounter;
				end
				ADDR_OUT_VALUE0: begin
					rdata <= int_out_Value0;
				end
			endcase
		end
	end
end


//------------------------Register logic-----------------
// int_out_TickCounter
always @(posedge ACLK) begin
    if (ARESET)
        int_out_TickCounter <= 0;
    else if (ACLK_EN) begin
        int_out_TickCounter <= int_out_TickCounter + 1;
    end
end

// int_out_Value0
always @(posedge ACLK) begin
    if (ARESET)
        int_out_Value0 <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_OUT_VALUE0)
            int_out_Value0 <= WDATA[31:0];
    end
end

//------------------------Memory logic-------------------

endmodule
