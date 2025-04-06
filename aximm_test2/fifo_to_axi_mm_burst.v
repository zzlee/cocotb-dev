`timescale 1ns / 1ps

module fifo_to_axi_mm_burst #(
    parameter FIFO_DATA_WIDTH = 32,           // FIFO 數據寬度 (位元)
    parameter AXI_DATA_WIDTH  = 32,           // AXI MM 數據寬度 (位元) - 假設與 FIFO 相同
    parameter AXI_ADDR_WIDTH  = 32,           // AXI MM 地址寬度 (位元)
    parameter MAX_BURST_LEN   = 16,           // 最大 AXI 突發長度 (beat count, e.g., 16, 64, 256)
    parameter LEN_WIDTH       = 32,           // TRANSFER_LEN 輸入端口的寬度
    // 計算 AWSIZE (log2(bytes))
    parameter C_AXI_SIZE      = $clog2(AXI_DATA_WIDTH/8),
    // 計算突發計數器寬度 (最大需要計數到 MAX_BURST_LEN - 1)
    parameter BURST_CNT_WIDTH = $clog2(MAX_BURST_LEN),
    // AXI AWLEN 最大值為 255 (對應 256 beats)
    parameter MAX_AXI_AWLEN   = (MAX_BURST_LEN > 256) ? 255 : MAX_BURST_LEN - 1
) (
    // Global Signals
    input wire ACLK,
    input wire ARESETn,

    // Configuration Input
    input wire [AXI_ADDR_WIDTH-1:0] BASE_ADDR,    // 目標內存起始地址
    input wire [LEN_WIDTH-1:0]      TRANSFER_LEN, // 要傳輸的總數據字數 (word count)
    input wire                      START,        // 啟動傳輸信號 (pulse or level)
    output wire                     BUSY,         // 模塊忙碌狀態
    output wire                     DONE,         // 傳輸完成信號 (pulse)
    // output wire ERROR,      // 可選：錯誤狀態 (e.g., from BRESP)

    // FIFO Read Interface (Input)
    input  wire [FIFO_DATA_WIDTH-1:0] fifo_rdata,   // 從 FIFO 讀取的數據
    input  wire                       fifo_empty,   // FIFO 空狀態信號
    output wire                       fifo_rden,    // FIFO 讀取啟用信號 (to FIFO)

    // AXI Master Interface (Output to Memory)
    // Write Address Channel
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
    output wire [2:0]                 m_axi_awprot,
    output wire                       m_axi_awvalid,
    input  wire                       m_axi_awready,
    output wire [7:0]                 m_axi_awlen,   // Actual burst length - 1 for this burst
    output wire [2:0]                 m_axi_awsize,  // Based on AXI_DATA_WIDTH
    output wire [1:0]                 m_axi_awburst, // INCR burst

    // Write Data Channel
    output wire [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
    output wire [AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,   // Assume full strobe
    output wire                       m_axi_wlast,
    output wire                       m_axi_wvalid,
    input  wire                       m_axi_wready,

    // Write Response Channel
    input  wire [1:0]                 m_axi_bresp,
    input  wire                       m_axi_bvalid,
    output wire                       m_axi_bready
);

    // --- Parameter Checks ---
    initial begin
        if (FIFO_DATA_WIDTH != AXI_DATA_WIDTH) begin
            $display("Error: FIFO_DATA_WIDTH (%0d) must match AXI_DATA_WIDTH (%0d) in this version.", FIFO_DATA_WIDTH, AXI_DATA_WIDTH);
            $finish;
        end
        if (MAX_BURST_LEN < 1) begin
             $display("Error: MAX_BURST_LEN (%0d) must be at least 1.", MAX_BURST_LEN);
            $finish;
        end
    end

    // --- State Machine Definition ---
    typedef enum logic [2:0] {
        IDLE              = 3'b000, // 等待啟動
        CALC_BURST_PARAMS = 3'b001, // 計算下一次突發參數
        SEND_AW           = 3'b010, // 發送寫地址
        WAIT_AWREADY      = 3'b011, // 等待地址接受
        WRITE_BURST       = 3'b100, // 寫入突發數據 (包含讀取 FIFO)
        WAIT_BRESP        = 3'b101, // 等待寫響應
        FINISH            = 3'b110  // 完成狀態
    } state_t;

    reg [2:0] state_reg, state_next;

    // --- Internal Registers ---
    reg [AXI_ADDR_WIDTH-1:0] current_addr_reg, current_addr_next;
    reg [LEN_WIDTH-1:0]      transfer_len_reg; // 鎖存的總傳輸長度
    reg [LEN_WIDTH-1:0]      total_beats_written_reg, total_beats_written_next; // 已成功寫入 AXI 的總 beat 數
    reg [LEN_WIDTH-1:0]      total_beats_read_reg, total_beats_read_next;    // 已成功從 FIFO 讀取的總 beat 數
    reg [BURST_CNT_WIDTH-1:0] beats_written_in_burst_reg, beats_written_in_burst_next; // 當前突發已寫入的 beat 數
    reg [7:0]                current_awlen_reg; // 當前突發實際的 AWLEN (length - 1)
    reg                       start_latch;

    // --- Skid Buffer Registers (1 deep) ---
    reg [FIFO_DATA_WIDTH-1:0] skid_data_reg;
    // reg                       skid_tlast_reg; // No TLAST from standard FIFO
    reg                       skid_valid_reg, skid_valid_next;

    // --- Internal Signals ---
    wire                      axi_w_fire; // m_axi_wvalid && m_axi_wready
    wire                      fifo_read_fire; // fifo_rden && !fifo_empty (Implicitly, as rden is only high when !empty)
    wire                      skid_ready_to_accept;
    wire                      data_consumed_from_skid;
    wire [FIFO_DATA_WIDTH-1:0] skid_data_out;
    wire                      skid_valid_out;
    wire [LEN_WIDTH-1:0]      beats_remaining_to_write;

    // =========================================================================
    // Skid Buffer Logic
    // =========================================================================

    assign data_consumed_from_skid = skid_valid_out && m_axi_wready && (state_reg == WRITE_BURST);
    assign skid_ready_to_accept = !skid_valid_reg || data_consumed_from_skid;

    // Control FIFO Read Enable
    // Read FIFO only when: in WRITE_BURST state, skid can accept, FIFO not empty, and haven't read total length yet.
    assign fifo_rden = (state_reg == WRITE_BURST) && skid_ready_to_accept && !fifo_empty && (total_beats_read_reg < transfer_len_reg);
    assign fifo_read_fire = fifo_rden; // Since fifo_rden is only high when !fifo_empty

    // Skid buffer output logic
    assign skid_data_out = skid_data_reg;
    assign skid_valid_out = skid_valid_reg;

    // Skid buffer state update (sequential)
    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            skid_valid_reg <= 1'b0;
        end else begin
            if (fifo_read_fire) begin // Data is read from FIFO
                skid_data_reg  <= fifo_rdata;
                skid_valid_reg <= 1'b1; // Data loaded
            end else if (data_consumed_from_skid) begin // Data is consumed by AXI
                skid_valid_reg <= 1'b0; // Data consumed
            end
            // else: skid_valid_reg retains its state
        end
    end

    // Combinational skid valid for next state logic
    assign skid_valid_next = (skid_valid_reg && !data_consumed_from_skid) || fifo_read_fire;

    // =========================================================================
    // State Machine Logic (Combinational)
    // =========================================================================
    assign beats_remaining_to_write = transfer_len_reg - total_beats_written_reg;
    assign axi_w_fire = m_axi_wvalid && m_axi_wready; // Handshake signal

    always_comb begin
        // Default assignments
        state_next = state_reg;
        current_addr_next = current_addr_reg;
        total_beats_written_next = total_beats_written_reg;
        total_beats_read_next = total_beats_read_reg;
        beats_written_in_burst_next = beats_written_in_burst_reg;
        current_awlen_reg = current_awlen_reg; // Keep current value unless changed

        m_axi_awvalid = 1'b0;
        m_axi_wvalid = 1'b0; // Default invalid
        m_axi_wlast = 1'b0;  // Default low
        m_axi_bready = 1'b0;

        BUSY = 1'b1; // Default busy
        DONE = 1'b0;

        // AXI W channel assignments (driven by skid buffer output)
        m_axi_wdata = skid_data_out;
        // WVALID only high if skid has data AND we are in the WRITE_BURST state
        m_axi_wvalid = skid_valid_out && (state_reg == WRITE_BURST);

        case (state_reg)
            IDLE: begin
                BUSY = 1'b0;
                total_beats_written_next = '0; // Reset counters
                total_beats_read_next = '0;
                beats_written_in_burst_next = '0;
                if (START && !start_latch) begin
                    if (TRANSFER_LEN > 0) begin // Only start if length > 0
                        state_next = CALC_BURST_PARAMS;
                        current_addr_next = BASE_ADDR;
                        transfer_len_reg = TRANSFER_LEN; // Latch transfer length
                        start_latch = 1'b1;
                    end else begin
                       // If TRANSFER_LEN is 0, signal DONE immediately?
                       state_next = FINISH; // Or stay IDLE? Let's go to FINISH.
                       start_latch = 1'b1;
                    end
                end else if (!START) begin
                    start_latch = 1'b0;
                end
            end

            CALC_BURST_PARAMS: begin
                // Calculate how many beats for the next burst
                logic [LEN_WIDTH-1:0] beats_for_this_burst;
                if (beats_remaining_to_write >= MAX_BURST_LEN) begin
                    beats_for_this_burst = MAX_BURST_LEN;
                end else begin
                    beats_for_this_burst = beats_remaining_to_write;
                end

                // Calculate AWLEN (length - 1), ensuring it doesn't exceed AXI limits if MAX_BURST_LEN > 256
                if (beats_for_this_burst > 0) begin
                     current_awlen_reg = (beats_for_this_burst > 256) ? 8'd255 : beats_for_this_burst - 1;
                     state_next = SEND_AW;
                     beats_written_in_burst_next = '0; // Reset burst counter
                end else begin
                    // Should not happen if logic is correct, but handle anyway
                    state_next = FINISH; // Already wrote everything
                end
            end

            SEND_AW: begin
                m_axi_awvalid = 1'b1; // Address is current_addr_reg
                // AWLEN is current_awlen_reg (calculated in previous state)
                if (m_axi_awready) begin
                    state_next = WAIT_AWREADY;
                end
            end

            WAIT_AWREADY: begin
                // Ensure AWVALID is low before starting W channel
                state_next = WRITE_BURST;
            end

            WRITE_BURST: begin
                // Control fifo_rden (assigned above)
                // Drive W channel based on skid buffer output (m_axi_wvalid assigned above)

                // Calculate WLAST for this specific beat being transferred
                m_axi_wlast = (beats_written_in_burst_reg == current_awlen_reg);

                // Check if data is consumed by AXI W channel
                if (axi_w_fire) begin // Data beat accepted
                    beats_written_in_burst_next = beats_written_in_burst_reg + 1;
                    total_beats_written_next = total_beats_written_reg + 1;

                    // Check if this is the last beat of the AXI burst
                    if (m_axi_wlast) begin // Last beat of burst is being accepted
                        state_next = WAIT_BRESP; // Go wait for response
                    end else begin
                        // Burst continues, stay in WRITE_BURST
                        state_next = WRITE_BURST;
                    end
                end
                 // else: Stay in WRITE_BURST, wait for AXI W channel or skid buffer
            end

            WAIT_BRESP: begin
                m_axi_bready = 1'b1; // Ready to accept response
                if (m_axi_bvalid) begin // Response received
                    // Update address for the *next* potential burst
                    // Bytes in last burst = (current_awlen_reg + 1) * bytes_per_beat
                    current_addr_next = current_addr_reg + ((current_awlen_reg + 1) * (AXI_DATA_WIDTH/8));

                    // Check if total transfer is complete
                    if (total_beats_written_reg == transfer_len_reg) begin // Compare against latched value
                        state_next = FINISH; // Transfer done
                    end else begin
                         // More data to write
                         state_next = CALC_BURST_PARAMS;
                    end
                end
            end

            FINISH: begin
                DONE = 1'b1; // Assert DONE for one cycle
                state_next = IDLE;
            end

            default: state_next = IDLE;
        endcase

        // Update total beats read counter combinatorially for immediate use in fifo_rden check
        if (fifo_read_fire && state_reg == WRITE_BURST) begin // Increment if read enable is high
            total_beats_read_next = total_beats_read_reg + 1;
        end else begin
            total_beats_read_next = total_beats_read_reg; // Keep current value if no read
        end
         if (state_next == IDLE) begin // Reset counter when going back to IDLE
              total_beats_read_next = '0;
         end

    end

    // =========================================================================
    // State Machine Logic (Sequential)
    // =========================================================================
    always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
            state_reg <= IDLE;
            current_addr_reg <= {AXI_ADDR_WIDTH{1'b0}};
            transfer_len_reg <= '0;
            total_beats_written_reg <= '0;
            total_beats_read_reg <= '0; // Reset read counter too
            beats_written_in_burst_reg <= '0;
            current_awlen_reg <= '0;
            start_latch <= 1'b0;
            // skid_valid_reg reset is handled in its own block
        end else begin
            state_reg <= state_next;
            current_addr_reg <= current_addr_next;
            transfer_len_reg <= transfer_len_reg; // Keep latched value unless reset
            if(state_reg == IDLE && state_next != IDLE) begin // Latch on first transition from IDLE
                 transfer_len_reg <= TRANSFER_LEN;
            end
            total_beats_written_reg <= total_beats_written_next;
            total_beats_read_reg <= total_beats_read_next; // Update read counter
            beats_written_in_burst_reg <= beats_written_in_burst_next;
            current_awlen_reg <= current_awlen_reg; // Latched in CALC_BURST_PARAMS state
            if (state_reg == CALC_BURST_PARAMS && state_next == SEND_AW) begin // Latch calculated awlen
                 current_awlen_reg <= (beats_remaining_to_write >= MAX_BURST_LEN) ? MAX_AXI_AWLEN : beats_remaining_to_write - 1;
                 if (beats_remaining_to_write == 0) current_awlen_reg <= '0; // Handle zero length case
            end

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
    assign m_axi_awlen   = current_awlen_reg;// Use the calculated and stored AWLEN for this burst
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