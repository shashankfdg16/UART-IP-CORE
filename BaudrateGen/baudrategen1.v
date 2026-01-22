`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design: Parameterized Low-Latency Baud Rate Generator
//////////////////////////////////////////////////////////////////////////////////

module BaudGenR_d #(
    parameter integer SYS_CLK_FREQ = 50_000_000,  // System clock frequency (Hz)
    parameter integer BAUD_RATE    = 9600,        // Baud rate
    parameter integer OVERSAMPLE   = 16           // Oversampling factor
)(
    input  wire reset_n,      // Active low reset
    input  wire clock,        // System clock
    output reg  baud_tick     // Single-cycle baud tick (low latency)
);

    // Baud divider calculation
    localparam integer BAUD_DIV =
        SYS_CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

    // Counter width protection
    reg [$clog2(BAUD_DIV):0] clock_ticks;

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            clock_ticks <= 0;
            baud_tick   <= 1'b0;
        end
        else begin
            if (clock_ticks == BAUD_DIV-1) begin
                clock_ticks <= 0;
                baud_tick   <= 1'b1;   // 1-clock pulse
            end
            else begin
                clock_ticks <= clock_ticks + 1'b1;
                baud_tick   <= 1'b0;
            end
        end
    end

endmodule
