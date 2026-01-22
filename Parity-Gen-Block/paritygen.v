`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: UART Parity Generator
// Design: Parameterized Low-Latency UART IP Core
//////////////////////////////////////////////////////////////////////////////////

module parity_d #(
    parameter integer DATA_BITS   = 8,
    parameter integer PARITY_EN   = 1,   // 1 = enable parity, 0 = disable
    parameter integer PARITY_TYPE = 0    // 0 = even, 1 = odd
)(
    input  wire [DATA_BITS-1:0] data_in,
    output wire                 parity_bit
);

    // -------------------------------------------------
    // Parity generation (pure combinational logic)
    // -------------------------------------------------
    assign parity_bit = (PARITY_EN) ?
                        (^data_in ^ PARITY_TYPE) :
                        1'b1;   // default mark when parity disabled

endmodule
