`timescale 1ns / 1ps

module axis_to_axi_mm_burst #(
    parameter AXIS_DATA_WIDTH = 32,           // AXI Stream 數據寬度 (位元)
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
    input wire [AXI_ADDR_WIDTH-1:0] BASE_ADDR, // 目標內存起始地址
    input wire                      START,       // 啟動傳輸信號 (pulse or level)
    output reg                     BUSY,        // 模塊忙碌狀態
    output reg                     DONE,        // 傳輸完成信號 (pulse)
    // output reg ERROR, // 可選：錯誤狀態

    // AXI Stream Slave Interface (Input)
    input  wire [AXIS_DATA_WIDTH-1:0] s_axis_tdata,
    input  wire                       s_axis_tlast,
    input  wire                       s_axis_tvalid,
    output reg                       s_axis_tready,

    // AXI Master Interface (Output to Memory)
    // Write Address Channel
    output reg [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
    output reg [2:0]                 m_axi_awprot,
    output reg                       m_axi_awvalid,
    input  wire                       m_axi_awready,
    output reg [7:0]                 m_axi_awlen,   // Burst length - 1
    output reg [2:0]                 m_axi_awsize,  // Based on AXI_DATA_WIDTH
    output reg [1:0]                 m_axi_awburst, // INCR burst

    // Write Data Channel
    output reg [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
    output reg [AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,   // Assume full strobe
    output reg                       m_axi_wlast,
    output reg                       m_axi_wvalid,
    input  wire                       m_axi_wready,

    // Write Response Channel
    input  wire [1:0]                 m_axi_bresp,
    input  wire                       m_axi_bvalid,
    output reg                       m_axi_bready
);

    // Check if widths match (for simplicity)
    initial begin
        if (AXIS_DATA_WIDTH != AXI_DATA_WIDTH) begin
            $display("Error: AXIS_DATA_WIDTH (%0d) must match AXI_DATA_WIDTH (%0d) in this simple version.", AXIS_DATA_WIDTH, AXI_DATA_WIDTH);
            $finish;
        end
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
    reg [AXI_ADDR_WIDTH-1:0] current_addr_reg, current_addr_next;
    reg [BURST_CNT_WIDTH-1:0] beats_written_reg, beats_written_next; // 當前突發已寫入的 beat 數
    reg                       tlast_seen_reg, tlast_seen_next;       // 是否已看到 TLAST
    reg                       start_latch;

    // Skid Buffer Registers (1 deep)
    reg [AXIS_DATA_WIDTH-1:0] skid_data_reg;
    reg                       skid_tlast_reg;
    reg                       skid_valid_reg, skid_valid_next;

    // Internal Signals
    wire                      axi_aw_fire;
    wire                      axi_w_fire;
    wire                      axi_b_fire;
    wire                      stream_accepted_into_skid;
    wire                      data_consumed_from_skid;
    wire                      skid_ready_to_accept; // Skid buffer 是否可以接收數據
    wire [AXIS_DATA_WIDTH-1:0] skid_data_out;
    wire                      skid_tlast_out;
    wire                      skid_valid_out;

    // =========================================================================
    // Skid Buffer Logic
    // =========================================================================

    // Skid buffer is ready to accept if it's empty OR if the data inside is being consumed this cycle
    assign skid_ready_to_accept = !skid_valid_reg || data_consumed_from_skid;
    // We are ready to accept stream data if the skid buffer can accept it
    assign s_axis_tready = skid_ready_to_accept && (state_reg == WRITE_BURST); // 只在寫數據狀態接收

    // Data is accepted into the skid buffer if stream is valid and skid can accept
    assign stream_accepted_into_skid = s_axis_tvalid && s_axis_tready;

    // Data is consumed from the skid buffer if it's valid and AXI W channel accepts it
    assign data_consumed_from_skid = skid_valid_out && m_axi_wready && (state_reg == WRITE_BURST);

    // Skid buffer output logic (combinational assignment for m_axi_wdata)
    assign skid_data_out = skid_data_reg;
    assign skid_tlast_out = skid_tlast_reg;
    assign skid_valid_out = skid_valid_reg; // Output valid is directly the skid valid signal

    // Skid buffer state update (sequential)
    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            skid_valid_reg <= 1'b0;
        end else begin
            if (stream_accepted_into_skid) begin
                skid_data_reg  <= s_axis_tdata;
                skid_tlast_reg <= s_axis_tlast;
                skid_valid_reg <= 1'b1; // Data loaded
            end else if (data_consumed_from_skid) begin
                skid_valid_reg <= 1'b0; // Data consumed
            end
            // else: skid_valid_reg retains its state
        end
    end

     // Skid buffer valid logic (combinational for next state calculation)
     // This is needed because the FF updates one cycle later
     // If data is consumed this cycle, the skid will be empty next cycle
     // If data is accepted this cycle, the skid will be full next cycle (unless also consumed)
    assign skid_valid_next = (skid_valid_reg && !data_consumed_from_skid) || stream_accepted_into_skid;


    // =========================================================================
    // State Machine Logic (Combinational)
    // =========================================================================
    always_comb begin
        // Default assignments
        state_next = state_reg;
        current_addr_next = current_addr_reg;
        beats_written_next = beats_written_reg;
        tlast_seen_next = tlast_seen_reg;

        m_axi_awvalid = 1'b0;
        m_axi_wvalid = 1'b0;
        m_axi_wlast = 1'b0; // Default wlast low
        m_axi_bready = 1'b0;

        BUSY = 1'b1; // Default busy
        DONE = 1'b0;

        // AXI W channel assignments (driven by skid buffer output)
        m_axi_wdata = skid_data_out;
        m_axi_wvalid = skid_valid_out && (state_reg == WRITE_BURST); // WVALID is skid_valid only in WRITE_BURST state

        case (state_reg)
            IDLE: begin
                BUSY = 1'b0;
                tlast_seen_next = 1'b0; // Clear flag
                beats_written_next = '0; // Reset counter
                if (START) begin
                    // Need first piece of data to start burst
                    if (s_axis_tvalid) begin // Make sure there's data ready
                        state_next = START_BURST;
                        current_addr_next = BASE_ADDR;
                        // Note: The first piece of data isn't consumed here,
                        // skid buffer logic handles accepting it later.
                    end
                end
            end

            START_BURST: begin
                m_axi_awvalid = 1'b1;
                beats_written_next = '0; // Reset burst counter for this burst
                 // Address is current_addr_reg
                if (m_axi_awready) begin
                    state_next = WAIT_AWREADY;
                end
            end

             WAIT_AWREADY: begin
                // Ensure AWVALID is low before starting W channel
                state_next = WRITE_BURST;
             end

            WRITE_BURST: begin
                // Drive W channel based on skid buffer output validity (assigned above)
                // m_axi_wvalid = skid_valid_out; // Only drive valid when skid has data

                // Calculate WLAST for this beat
                m_axi_wlast = (beats_written_reg == C_AXI_AWLEN);

                // Check if data is consumed by AXI W channel
                if (m_axi_wvalid && m_axi_wready) begin // AXI Data beat accepted (axi_w_fire)
                    beats_written_next = beats_written_reg + 1;

                    // Check if TLAST is present on the consumed beat
                    if (skid_tlast_out) begin
                        tlast_seen_next = 1'b1;
                    end

                    // Check if this is the last beat of the AXI burst
                    if (m_axi_wlast) begin // Last beat of burst is being accepted
                        // Update address for the *next* potential burst
                        current_addr_next = current_addr_reg + (MAX_BURST_LEN * (AXI_DATA_WIDTH/8));
                        state_next = WAIT_BRESP; // Go wait for response
                    end else begin
                        // Burst continues, stay in WRITE_BURST
                        state_next = WRITE_BURST;
                    end
                end
                // else: Stay in WRITE_BURST, wait for m_axi_wready or skid_valid_out
            end

            WAIT_BRESP: begin
                m_axi_bready = 1'b1; // Ready to accept response
                if (m_axi_bvalid) begin // Response received (axi_b_fire)
                    // Optionally check m_axi_bresp here
                    if (tlast_seen_reg) begin // If TLAST was seen during the last burst
                        state_next = FINISH; // Transfer done
                    end else begin
                        // Need to start the next burst
                         // Check if skid buffer has data ready for next burst to avoid glitches
                         // If skid is empty, we might need an intermediate state or check s_axis_tvalid here
                        if (skid_valid_next || s_axis_tvalid) begin // Check if data is available or incoming
                            state_next = START_BURST;
                        end else begin
                             // Potential issue: If stream ends exactly at burst boundary and no new data comes
                             // We might get stuck waiting for data. Assuming stream continues or ends with TLAST.
                             // A more robust design might need to handle this edge case.
                             // For now, assume data will eventually arrive if TLAST wasn't seen.
                             state_next = START_BURST; // Optimistically start next burst prep
                        end
                    end
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
            tlast_seen_reg <= 1'b0;
            start_latch <= 1'b0;
            // skid_valid_reg reset is handled in its own block
        end else begin
            state_reg <= state_next;
            current_addr_reg <= current_addr_next;
            beats_written_reg <= beats_written_next;
            tlast_seen_reg <= tlast_seen_next;

             // Latch logic for START signal
            if (state_reg == IDLE) begin
                start_latch <= state_next == IDLE ? 1'b0 : 1'b1;
            end else if (state_next == IDLE) begin
                start_latch <= 1'b0;
            end
             // Reset tlast flag when going back to IDLE
            if (state_next == IDLE) begin
                 tlast_seen_reg <= 1'b0;
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
