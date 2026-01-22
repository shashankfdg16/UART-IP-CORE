module RxUnit #(
    parameter DATA_BITS = 8,
    parameter PARITY_EN = 1,
    parameter STOP_BITS = 1
)(
    input  wire               reset_n,      // Active low reset
    input  wire               data_tx,      // Serial RX data
    input  wire               clock,        // System clock
    input  wire [1:0]         parity_type,  // 00:none 01:odd 10:even
    input  wire [1:0]         baud_rate,    // Baud select

    output wire               active_flag,  // RX busy
    output wire               done_flag,    // Frame received
    output wire [2:0]         error_flag,   // {stop,start,parity}
    output wire [DATA_BITS-1:0] data_out    // Received data
);

    // -------------------------------------------------
    // Local parameters
    // -------------------------------------------------
    localparam FRAME_W = 1 + DATA_BITS + PARITY_EN + STOP_BITS;

    // -------------------------------------------------
    // Internal wires
    // -------------------------------------------------
    wire                     baud_clk_w;
    wire [FRAME_W-1:0]       frame_parll_w;
    wire                     recieved_flag_w;
    wire                     def_par_bit_w;
    wire                     def_strt_bit_w;
    wire                     def_stp_bit_w;

    // -------------------------------------------------
    // Baud Rate Generator (low latency)
    // -------------------------------------------------
    BaudGenR_d Unit_BaudGen (
        .reset_n (reset_n),
        .clock   (clock),
        .baud_rate (baud_rate),
        .baud_clk (baud_clk_w)
    );

    // -------------------------------------------------
    // Serial-In Parallel-Out (Receiver)
    // -------------------------------------------------
    SIPO #(
        .DATA_BITS (DATA_BITS),
        .PARITY_EN (PARITY_EN),
        .STOP_BITS (STOP_BITS)
    ) Unit_SIPO (
        .reset_n        (reset_n),
        .data_tx        (data_tx),
        .baud_clk       (baud_clk_w),
        .active_flag    (active_flag),
        .recieved_flag  (recieved_flag_w),
        .data_parll     (frame_parll_w)
    );

    // -------------------------------------------------
    // De-Frame Unit
    // -------------------------------------------------
    DeFrame #(
        .DATA_BITS (DATA_BITS),
        .PARITY_EN (PARITY_EN),
        .STOP_BITS (STOP_BITS)
    ) Unit_DeFrame (
        .data_parll     (frame_parll_w),
        .recieved_flag  (recieved_flag_w),
        .parity_bit     (def_par_bit_w),
        .start_bit      (def_strt_bit_w),
        .stop_bit       (def_stp_bit_w),
        .done_flag      (done_flag),
        .raw_data       (data_out)
    );

    // -------------------------------------------------
    // Error Check Unit (no extra latency)
    // -------------------------------------------------
    ErrorCheck Unit_ErrorCheck (
        .reset_n        (reset_n),
        .recieved_flag  (done_flag),
        .parity_bit     (def_par_bit_w),
        .start_bit      (def_strt_bit_w),
        .stop_bit       (def_stp_bit_w),
        .parity_type    (parity_type),
        .raw_data       (data_out),
        .error_flag     (error_flag)
    );

endmodule
