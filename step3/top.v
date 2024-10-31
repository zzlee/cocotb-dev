`timescale 1ns/10ps

module top (
    clk,
    a,
    b,
    c
);

input clk;
output reg a;
output reg b;
input c;

reg t1;
reg t2;
reg t3;
reg t4;

always @(posedge clk) begin
    t1 <= c;
    t2 <= t1;
    a <= t2;
end

always @(posedge clk) begin
    t3 = c;
    t4 = t3;
    b = t4;
end

endmodule
