`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: UART TX PISO
// Project: Parameterized Low-Latency UART IP Core
//////////////////////////////////////////////////////////////////////////////////

module tx_piso_tb;

    // -------------------------------------------------
    // Parameters (match DUT)
    // -------------------------------------------------
    parameter integer DATA_BITS  = 8;
    parameter integer PARITY_EN  = 1;
    parameter integer PARITY_TYP = 0;
    parameter integer STOP_BITS  = 1;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    reg                   clock;
    reg                   reset_n;
    reg                   baud_tick;
    reg                   send;
    reg  [DATA_BITS-1:0]  data_in;

    wire                  data_tx;
    wire                  active_flag;
    wire                  done_flag;

    // -------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------
    uart_tx_piso #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN),
        .PARITY_TYP(PARITY_TYP),
        .STOP_BITS(STOP_BITS)
    ) dut (
        .clock(clock),
        .reset_n(reset_n),
        .baud_tick(baud_tick),
        .send(send),
        .data_in(data_in),
        .data_tx(data_tx),
        .active_flag(active_flag),
        .done_flag(done_flag)
    );

    // -------------------------------------------------
    // System Clock (50 MHz → 20 ns)
    // -------------------------------------------------
    always #10 clock = ~clock;

    // -------------------------------------------------
    // Baud Tick Generation (Manual for Low Latency)
    // -------------------------------------------------
    initial begin
        baud_tick = 0;
        forever begin
            #3250;          // ~6.5 µs half-period
            baud_tick = 1;
            #20;            // single-cycle pulse
            baud_tick = 0;
        end
    end

    // -------------------------------------------------
    // Test Sequence
    // -------------------------------------------------
    initial begin
        // Initialize
        clock   = 0;
        reset_n = 0;
        send    = 0;
        data_in = 8'h00;

        // Monitor important signals
        $monitor("TIME=%0t | send=%b | data_tx=%b | active=%b | done=%b",
                  $time, send, data_tx, active_flag, done_flag);

        // Apply reset
        #100;
        reset_n = 1;

        // Wait a little
        #100;

        // Transmit a byte
        data_in = 8'hA5;   // 10100101
        send    = 1;
        #20;
        send    = 0;

        // Wait until transmission completes
        wait(done_flag == 1);

        // End simulation
        #2000;
        $finish;
    end

endmodule
