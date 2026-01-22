`timescale 1ns / 1ps

module parity_tb;

    parameter integer DATA_BITS   = 8;
    parameter integer PARITY_EN   = 1;
    parameter integer PARITY_TYPE = 0;

    reg  [DATA_BITS-1:0] data_in;
    wire parity_bit;

    parity_d #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN),
        .PARITY_TYPE(PARITY_TYPE)
    ) dut (
        .data_in(data_in),
        .parity_bit(parity_bit)
    );

    initial begin
        $monitor("TIME=%0t | DATA=%b | PARITY_BIT=%b",
                  $time, data_in, parity_bit);

        data_in = 8'b00010111;
        #10 data_in = 8'b00001111;
        #10 data_in = 8'b10101111;
        #10 data_in = 8'b10101001;
        #10 data_in = 8'b10111101;

        #20 $finish;
    end

endmodule
