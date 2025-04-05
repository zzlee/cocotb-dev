module axi_lite_slave (
    input clk,
    input reset_n,
    // AXI-Lite 寫通道
    input [31:0] awaddr,
    input awvalid,
    output reg awready,
    input [31:0] wdata,
    input wvalid,
    output reg wready,
    output reg [1:0] bresp,
    output reg bvalid,
    input bready,
    // AXI-Lite 讀通道
    input [31:0] araddr,
    input arvalid,
    output reg arready,
    output reg [31:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input rready
);
    reg [31:0] memory [0:3]; // 簡單的 4 個 32-bit 寄存器

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            awready <= 0;
            wready <= 0;
            bvalid <= 0;
            bresp <= 2'b00; // OKAY
            arready <= 0;
            rvalid <= 0;
            rresp <= 2'b00; // OKAY
            rdata <= 0;
            memory[0] <= 0;
            memory[1] <= 0;
            memory[2] <= 0;
            memory[3] <= 0;
        end else begin
            // 寫地址通道
            if (awvalid && !awready) begin
                awready <= 1;
            end
            if (awvalid && awready) begin
                awready <= 0;
            end

            // 寫數據通道
            if (wvalid && !wready) begin
                wready <= 1;
            end
            if (wvalid && wready) begin
                memory[awaddr[3:2]] <= wdata; // 根據地址寫入
                wready <= 0;
                bvalid <= 1;
            end

            // 寫回應通道
            if (bvalid && bready) begin
                bvalid <= 0;
            end

            // 讀地址通道
            if (arvalid && !arready) begin
                arready <= 1;
            end
            if (arvalid && arready) begin
                arready <= 0;
                rdata <= memory[araddr[3:2]]; // 根據地址讀取
                rvalid <= 1;
            end

            // 讀數據通道
            if (rvalid && rready) begin
                rvalid <= 0;
            end
        end
    end
endmodule