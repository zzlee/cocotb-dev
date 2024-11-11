`resetall
`timescale 1ns / 1ps
`default_nettype none

module top0 #
(
    parameter PORTS = 4
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [PORTS-1:0]         request,
    input  wire [PORTS-1:0]         acknowledge,

    output wire [PORTS-1:0]         grant,
    output wire                     grant_valid,
    output wire [$clog2(PORTS)-1:0] grant_encoded
);

arbiter #(
    .PORTS(PORTS),
    .ARB_TYPE_ROUND_ROBIN(1),
    .ARB_BLOCK(1),
    .ARB_BLOCK_ACK(1),
    .ARB_LSB_HIGH_PRIORITY(1)
)
arbiter_inst (
    .clk(clk),
    .rst(rst),
    .request(request),
    .acknowledge(acknowledge),
    .grant(grant),
    .grant_valid(grant_valid),
    .grant_encoded(grant_encoded)
);

endmodule

module top1 #
(
    parameter WIDTH = 32
)
(
    input  wire                     clk,
    input  wire                     rst,

    input  wire [WIDTH-1:0]         input_unencoded,
    output wire                     output_valid,
    output wire [$clog2(WIDTH)-1:0] output_encoded,
    output wire [WIDTH-1:0]         output_unencoded
);

priority_encoder #(
    .WIDTH(WIDTH),
    .LSB_HIGH_PRIORITY(1)
)
priority_encoder_inst (
    .input_unencoded(input_unencoded),
    .output_valid(output_valid),
    .output_encoded(output_encoded),
    .output_unencoded(output_unencoded)
);

endmodule
