`timescale 1 ns / 1 ps

module fifo
#(
	parameter DEPTH = 8,    // FIFO 深度
	parameter WIDTH = 32   // 數據寬度
)
(
	input clk,              // 時鐘
	input rst_n,          // 低電平有效復位

	// 寫接口
	input                       wr_en,
	input      [WIDTH-1:0] wr_data,

	// 讀接口
	input                       rd_en,
	output reg [WIDTH-1:0] rd_data,

	// 狀態信號
	output reg                  full,
	output reg                  empty
);

	localparam ADDR_WIDTH = $clog2(DEPTH);

	reg [WIDTH-1:0] mem [0:DEPTH-1]; // 記憶體陣列
	reg [ADDR_WIDTH-1:0] wr_ptr;       // 寫指針
	reg [ADDR_WIDTH-1:0] rd_ptr;       // 讀指針
	reg [ADDR_WIDTH:0] count;        // 計數器，記錄 FIFO 中數據數量

	// 寫操作邏輯
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// 復位時不執行寫操作
		end else if (wr_en && !full) begin // 只有在使能且 FIFO 未滿時才寫入
			mem[wr_ptr] <= wr_data;
			wr_ptr <= (wr_ptr == DEPTH - 1) ? 0 : wr_ptr + 1; // 指針回繞
		end
	end

	// 讀操作邏輯
	// 注意: rd_data 通常希望是寄存器輸出，以避免組合邏輯路徑過長
	// 這裡我們讓 rd_data 在讀使能的下一個週期有效
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			rd_data <= {WIDTH{1'b0}}; // 復位時讀數據清零
		end else if (rd_en && !empty) begin // 只有在使能且 FIFO 非空時才讀出
			rd_data <= mem[rd_ptr];         // 讀取當前讀指針指向的數據
			rd_ptr <= (rd_ptr == DEPTH - 1) ? 0 : rd_ptr + 1; // 指針回繞
		end
		// 如果沒有讀使能或者 FIFO 為空，rd_data 保持不變 (由 reg 的特性決定)
		// 如果需要，可以添加 else 語句明確行為
		// else begin
		//     rd_data <= rd_data; // 或者賦予一個默認值
		// end
	end

	// 計數器和狀態標誌邏輯
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wr_ptr <= 0;
			rd_ptr <= 0;
			count  <= 0;
			full   <= 1'b0;
			empty  <= 1'b1; // 復位時 FIFO 為空
		end else begin
			case ({wr_en && !full, rd_en && !empty}) // 根據讀寫操作更新計數器
				2'b00: count <= count;             // 無操作
				2'b01: count <= count - 1;         // 僅讀操作
				2'b10: count <= count + 1;         // 僅寫操作
				2'b11: count <= count;             // 同時讀寫，計數不變
				default: count <= count;
			endcase

			// 更新滿/空標誌 (在計數器更新後)
			// 使用 next_count 判斷會更精確，但這裡為了簡化，直接用更新後的 count
			// 注意：這種方式會在操作發生的 *同一個* 週期更新標誌
			// empty 標誌在計數器變為 0 時立即變為高電平
			empty <= (count == 0) && !(wr_en && !full && !(rd_en && !empty)); // 如果是寫操作使count從0變1，則empty要變低
			if (rd_en && !empty && !(wr_en && !full) && count == 1) begin // 如果是讀操作使count從1變0，則empty要變高
				 empty <= 1'b1;
			end

			// full 標誌在計數器達到 DEPTH 時立即變為高電平
			full <= (count == DEPTH) && !(rd_en && !empty && !(wr_en && !full)); // 如果是讀操作使count從DEPTH變DEPTH-1，則full要變低
			if (wr_en && !full && !(rd_en && !empty) && count == DEPTH - 1) begin // 如果是寫操作使count從DEPTH-1變DEPTH，則full要變高
				full <= 1'b1;
			end

			 // 更簡單的滿空判斷（在下一個週期生效）
			 // empty <= (next_count == 0);
			 // full  <= (next_count == DEPTH);
			 // 需要計算 next_count
		end
	end

	// (可選) 更精確的滿空標誌計算 (考慮當前週期的操作)
	// assign empty = (count == 0);
	// assign full  = (count == DEPTH);
endmodule