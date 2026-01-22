`timescale 1ns / 1ps
module transmitter_d (
    input  wire        clock,
    input  wire        reset_n,
    input  wire        send,
    input  wire [7:0]  data_in,

    output wire        data_tx,
    output wire        active_flag,
    output wire        done_flag
);

    wire baud_tick;
    wire parity_bit;

    // Baud Generator
   BaudGenR_d baud_gen (
        .clock(clock),
        .reset_n(reset_n),
        .baud_tick(baud_tick)
    );

    // Parity Generator
    parity_d parity_gen (
        .data_in(data_in),
        .parity_bit(parity_bit)
    );

    // TX PISO
    piso_d tx_piso (
        .clock(clock),
        .reset_n(reset_n),
        .baud_tick(baud_tick),
        .send(send),
        .data_in(data_in),
        .data_tx(data_tx),
        .active_flag(active_flag),
        .done_flag(done_flag)
    );

endmodule
