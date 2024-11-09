`resetall
`timescale 1ns / 1ps
`default_nettype none

module top #
(
    parameter PORTS = 4
)
(
    input  wire                     clk,
    input  wire                     rst
);

localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_STEP0 = 2'd1,
    STATE_STEP1 = 2'd2,
    STATE_STEP2 = 2'd3;

reg [1:0] state_reg = STATE_IDLE, state_next;

always @(posedge clk) begin
    state_reg <= state_next;

    if (rst) begin
        state_reg <= STATE_IDLE;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                state_next <= STATE_STEP0;
            end
            STATE_STEP0: begin
                state_next <= STATE_STEP1;
            end
            STATE_STEP1: begin
                state_next <= STATE_STEP2;
            end
        endcase
    end
end

endmodule
