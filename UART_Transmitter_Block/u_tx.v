`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: UART Transmitter (PISO)
// Design: Parameterized Low-Latency UART IP Core
//////////////////////////////////////////////////////////////////////////////////

module piso_d #(
    parameter integer DATA_BITS  = 8,
    parameter integer PARITY_EN  = 1,
    parameter integer PARITY_TYP = 0,  // 0 = even, 1 = odd
    parameter integer STOP_BITS  = 1
)(
    input  wire                   clock,
    input  wire                   reset_n,
    input  wire                   baud_tick,   // single-cycle tick
    input  wire                   send,
    input  wire [DATA_BITS-1:0]   data_in,

    output reg                    data_tx,
    output reg                    active_flag,
    output reg                    done_flag
);

    // -------------------------------------------------
    // Internal registers
    // -------------------------------------------------
    reg [DATA_BITS+PARITY_EN+STOP_BITS:0] shift_reg;
    reg [$clog2(DATA_BITS+PARITY_EN+STOP_BITS+2)-1:0] bit_cnt;
    reg parity_bit;

    // -------------------------------------------------
    // Parity generation
    // -------------------------------------------------
    always @(*) begin
        if (PARITY_EN)
            parity_bit = ^data_in ^ PARITY_TYP;
        else
            parity_bit = 1'b0;
    end

    // -------------------------------------------------
    // TX FSM + PISO logic (LOW LATENCY)
    // -------------------------------------------------
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg  <= {DATA_BITS+PARITY_EN+STOP_BITS+1{1'b1}};
            bit_cnt    <= 0;
            data_tx    <= 1'b1;
            active_flag<= 1'b0;
            done_flag  <= 1'b1;
        end
        else begin
            done_flag <= 1'b0;

            // Start transmission immediately
            if (send && !active_flag) begin
                shift_reg <= { {STOP_BITS{1'b1}},
                               (PARITY_EN ? parity_bit : 1'b1),
                               data_in,
                               1'b0 }; // start bit
                bit_cnt     <= 0;
                active_flag <= 1'b1;
            end
            // Shift on each baud tick
            else if (baud_tick && active_flag) begin
                data_tx   <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                bit_cnt   <= bit_cnt + 1'b1;

                if (bit_cnt ==
                    DATA_BITS + PARITY_EN + STOP_BITS) begin
                    active_flag <= 1'b0;
                    done_flag   <= 1'b1;
                    data_tx     <= 1'b1;
                end
            end
        end
    end

endmodule
