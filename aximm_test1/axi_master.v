module axi_master (
    input clk,
    input reset_n,
    // 寫地址通道
    output reg [31:0] awaddr,
    output reg awvalid,
    input awready,
    output reg [3:0] awlen,  // 突發長度 (0-15)
    output reg [2:0] awsize, // 每次傳輸大小 (0=1B, 1=2B, 2=4B)
    output reg [1:0] awburst, // 突發類型 (INCR)
    // 寫數據通道
    output reg [31:0] wdata,
    output reg wvalid,
    output reg wlast,        // 表示最後一個數據
    input wready,
    // 寫回應通道
    input [1:0] bresp,
    input bvalid,
    output reg bready
);
    reg [10:0] byte_count;   // 計數 1024 bytes
    reg [3:0] burst_count;   // 每個突發的計數器

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            awaddr <= 32'h00000000;
            awvalid <= 0;
            awlen <= 4'd15;      // 每次突發 16 次傳輸
            awsize <= 3'b010;    // 每次傳輸 4 bytes
            awburst <= 2'b01;    // INCR 模式
            wdata <= 0;
            wvalid <= 0;
            wlast <= 0;
            bready <= 0;
            byte_count <= 0;
            burst_count <= 0;
        end else begin
            // 寫地址通道
            if (!awvalid && byte_count < 1024) begin
                awaddr <= byte_count; // 從地址 0 開始
                awvalid <= 1;
            end
            if (awvalid && awready) begin
                awvalid <= 0;
            end

            // 寫數據通道
            if (awvalid && awready && !wvalid) begin
                wvalid <= 1;
                wdata <= byte_count; // 數據從 0 遞增
                burst_count <= 0;
            end
            if (wvalid && wready) begin
                burst_count <= burst_count + 1;
                byte_count <= byte_count + 4; // 每次 4 bytes
                wdata <= byte_count + 4;
                if (burst_count == awlen) begin
                    wlast <= 1; // 最後一次傳輸
                end
                if (wlast && wready) begin
                    wvalid <= 0;
                    wlast <= 0;
                end
            end

            // 寫回應通道
            if (bvalid && !bready) begin
                bready <= 1;
            end
            if (bready && bvalid) begin
                bready <= 0;
            end
        end
    end
endmodule