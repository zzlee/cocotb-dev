`timescale 1ns / 1ps

module axis_fifo #(
    parameter DATA_WIDTH = 32,          // AXI Stream 數據寬度 (位元)
    parameter DEPTH      = 16,          // FIFO 深度 (條目數)
    parameter ADDR_WIDTH = $clog2(DEPTH) // 計算地址寬度 (需要 Verilog-2001 或更高版本)
) (
    // 時脈與重置
    input wire ACLK,      // 全局時脈
    input wire ARESETn,   // 低電位有效同步重置

    // AXI Stream Slave Interface (寫入 FIFO)
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,   // 寫入數據
    input  wire                  s_axis_tlast,   // 寫入封包最後一筆數據標誌
    input  wire                  s_axis_tvalid,  // 寫入數據有效信號
    output wire                  s_axis_tready,  // FIFO 準備好接收寫入數據

    // AXI Stream Master Interface (從 FIFO 讀取)
    output wire [DATA_WIDTH-1:0] m_axis_tdata,   // 讀取數據
    output wire                  m_axis_tlast,   // 讀取封包最後一筆數據標誌
    output wire                  m_axis_tvalid,  // 讀取數據有效信號
    input  wire                  m_axis_tready   // 下游模塊準備好接收讀取數據
);

    // 內部信號宣告
    // FIFO 儲存陣列
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg                  mem_tlast [0:DEPTH-1]; // 儲存 TLAST 信號

    // 讀寫指針
    reg [ADDR_WIDTH-1:0] wptr_reg, wptr_next; // 寫指針
    reg [ADDR_WIDTH-1:0] rptr_reg, rptr_next; // 讀指針

    // FIFO 狀態計數器 (需要 ADDR_WIDTH + 1 位元來區分 0 和 DEPTH)
    reg [ADDR_WIDTH:0]   count_reg, count_next;

    // 內部 FIFO 控制信號
    wire fifo_write_en; // FIFO 寫入啟用
    wire fifo_read_en;  // FIFO 讀取啟用
    wire fifo_full;     // FIFO 滿標誌
    wire fifo_empty;    // FIFO 空標誌

    // =========================================================================
    // FIFO 狀態邏輯 (滿/空)
    // =========================================================================
    assign fifo_full = (count_reg == DEPTH);
    assign fifo_empty = (count_reg == 0);

    // =========================================================================
    // Slave Interface (寫入) 邏輯
    // =========================================================================
    // 只有在 s_axis_tvalid 為高且 FIFO 未滿時，才進行寫入
    assign fifo_write_en = s_axis_tvalid && s_axis_tready;
    // 只有在 FIFO 未滿時，才準備好接收數據
    assign s_axis_tready = !fifo_full;

    // 下一個寫指針的組合邏輯
    always @(*) begin
        wptr_next = wptr_reg;
        if (fifo_write_en) begin
            wptr_next = wptr_reg + 1; // 指針在寫入時遞增 (會自動 wrap)
        end
    end

    // FIFO 內存寫入 (時序邏輯)
    always @(posedge ACLK) begin
        if (fifo_write_en) begin
            mem[wptr_reg] <= s_axis_tdata;
            mem_tlast[wptr_reg] <= s_axis_tlast; // 同步儲存 TLAST
        end
    end

    // =========================================================================
    // Master Interface (讀取) 邏輯
    // =========================================================================
    // 只有在 m_axis_tvalid (FIFO非空) 且 m_axis_tready (下游準備好) 時，才進行讀取
    assign fifo_read_en = m_axis_tvalid && m_axis_tready;
    // 只有在 FIFO 非空時，輸出的數據才有效
    assign m_axis_tvalid = !fifo_empty;
    // 從當前讀指針位置讀取數據和 TLAST (組合邏輯)
    assign m_axis_tdata = mem[rptr_reg];
    assign m_axis_tlast = mem_tlast[rptr_reg];

    // 下一個讀指針的組合邏輯
    always @(*) begin
        rptr_next = rptr_reg;
        if (fifo_read_en) begin
            rptr_next = rptr_reg + 1; // 指針在讀取時遞增 (會自動 wrap)
        end
    end

    // =========================================================================
    // FIFO 計數器邏輯
    // =========================================================================
    always @(*) begin
        count_next = count_reg;
        // 根據讀寫啟用信號更新計數器
        if (fifo_write_en && !fifo_read_en) begin // 僅寫入
            count_next = count_reg + 1;
        end else if (!fifo_write_en && fifo_read_en) begin // 僅讀取
            count_next = count_reg - 1;
        end
        // 如果同時讀寫或都不讀寫，計數器不變
    end

    // =========================================================================
    // 指針和計數器寄存器更新 (時序邏輯)
    // =========================================================================
    always @(posedge ACLK) begin
        if (!ARESETn) begin // 同步重置 (低電位有效)
            wptr_reg  <= {ADDR_WIDTH{1'b0}};
            rptr_reg  <= {ADDR_WIDTH{1'b0}};
            count_reg <= {(ADDR_WIDTH+1){1'b0}};
        end else begin
            wptr_reg  <= wptr_next;
            rptr_reg  <= rptr_next;
            count_reg <= count_next;
        end
    end

endmodule

// Helper function $clog2 definition (if not supported by simulator/synthesizer)
// You might need this if using older tools
/*
function integer $clog2 (input integer value);
    integer i = 0;
    if (value <= 0) $clog2 = 0; // Or handle error
    else begin
        value = value - 1;
        while (value > 0) begin
            value = value >> 1;
            i = i + 1;
        end
        $clog2 = i;
    end
endfunction
*/
