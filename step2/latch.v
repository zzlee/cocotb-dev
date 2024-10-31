// File: latch.v
// Generated by MyHDL 0.11.49
// Date: Thu Oct 31 09:09:21 2024


`timescale 1ns/10ps

module latch (
    q,
    d,
    g
);


output q;
reg q;
input d;
input g;




always @(g, d) begin: LATCH_LOGIC
    if ((g == 1)) begin
        q <= d;
    end
end

endmodule
