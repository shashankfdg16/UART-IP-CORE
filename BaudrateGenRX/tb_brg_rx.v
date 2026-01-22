`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Parameterized Low-Latency Baud Generator
// Project: Design of a Parameterized Low-Latency UART IP Core
//////////////////////////////////////////////////////////////////////////////////

module tb_BaudGenR_d;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    reg  reset_n;
    reg  clock;
    wire baud_tick;

    // -------------------------------------------------
    // DUT Instantiation (Parameterized)
    // -------------------------------------------------
    BaudGenR_d #(
        .SYS_CLK_FREQ(50_000_000),  // 50 MHz system clock
        .BAUD_RATE(9600),           // UART baud rate
        .OVERSAMPLE(16)
    ) dut (
        .reset_n(reset_n),
        .clock(clock),
        .baud_tick(baud_tick)
    );

    // -------------------------------------------------
    // 50 MHz Clock Generation (20 ns period)
    // -------------------------------------------------
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    // -------------------------------------------------
    // Reset Sequence
    // -------------------------------------------------
    initial begin
        reset_n = 1'b0;
        #100;
        reset_n = 1'b1;
    end

    // -------------------------------------------------
    // Monitor Statement (IMPORTANT FOR VIVA)
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t ns | baud_tick=%b", $time, baud_tick);
    end

    // -------------------------------------------------
    // Simulation Control
    // -------------------------------------------------
    initial begin
        // Run long enough to observe multiple baud ticks
        #2_000_000;   // 2 ms
        $finish;
    end

endmodule
