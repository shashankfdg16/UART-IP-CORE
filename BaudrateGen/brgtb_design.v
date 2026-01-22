`timescale 1ns / 1ps

module tb_BaudGen;

    // -------------------------------------------------
    // Parameters (same as DUT)
    // -------------------------------------------------
    parameter integer SYS_CLK_FREQ = 50_000_000;  // 50 MHz
    parameter integer BAUD_RATE    = 9600;
    parameter integer OVERSAMPLE   = 16;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    reg  clock;
    reg  reset_n;
    wire baud_tick;

    // -------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------
    BaudGenR_d #(
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(OVERSAMPLE)
    ) dut (
        .clock(clock),
        .reset_n(reset_n),
        .baud_tick(baud_tick)
    );

    // -------------------------------------------------
    // Clock Generation (50 MHz → 20 ns period)
    // -------------------------------------------------
    always #10 clock = ~clock;

    // -------------------------------------------------
    // Test Procedure
    // -------------------------------------------------
    initial begin
        // Initialize signals
        clock   = 0;
        reset_n = 0;

        // Monitor important signals
        $monitor("TIME=%0t ns | reset_n=%b | baud_tick=%b",
                  $time, reset_n, baud_tick);

        // Apply reset
        #100;
        reset_n = 1;

        // Run simulation long enough to observe baud ticks
        #50000;

        // End simulation
        $finish;
    end

endmodule
