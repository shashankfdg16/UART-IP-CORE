`timescale 1ns/1ps
module CheckTest;

    // -------------------------------------------------
    // Parameters (match DUT)
    // -------------------------------------------------
    parameter DATA_BITS = 8;
    parameter PARITY_EN = 1;

    // -------------------------------------------------
    // Regs to drive inputs
    // -------------------------------------------------
    reg                     reset_n;
    reg                     recieved_flag;
    reg                     parity_bit;
    reg                     start_bit;
    reg                     stop_bit;
    reg [1:0]               parity_type;
    reg [DATA_BITS-1:0]     raw_data;

    // -------------------------------------------------
    // Wire to show output
    // -------------------------------------------------
    wire [2:0] error_flag;

    // -------------------------------------------------
    // DUT Instance (Parameterized)
    // -------------------------------------------------
    ErrorCheck #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN)
    ) DUT (
        .reset_n(reset_n),
        .recieved_flag(recieved_flag),
        .parity_bit(parity_bit),
        .start_bit(start_bit),
        .stop_bit(stop_bit),
        .parity_type(parity_type),
        .raw_data(raw_data),
        .error_flag(error_flag)
    );

    // -------------------------------------------------
    // Dump for waveform
    // -------------------------------------------------
    initial begin
        $dumpfile("CheckTest.vcd");
        $dumpvars(0, CheckTest);
    end

    // -------------------------------------------------
    // Monitor (Viva-friendly)
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t | ERR=%b | PT=%b | DATA=%b | S=%b P=%b T=%b",
                 $time, error_flag, parity_type, raw_data,
                 start_bit, parity_bit, stop_bit);
    end

    // -------------------------------------------------
    // Reset
    // -------------------------------------------------
    initial begin
        reset_n = 0;
        recieved_flag = 0;
        #20;
        reset_n = 1;
        recieved_flag = 1;
    end

    // -------------------------------------------------
    // Test vectors (single block, multiple cases)
    // -------------------------------------------------
    initial begin
        @(posedge reset_n);

        // ---------------------------
        // Case 1: No error (EVEN)
        // ---------------------------
        parity_type = 2'b10;
        raw_data    = 8'h55;
        parity_bit  = ^raw_data;
        start_bit   = 0;
        stop_bit    = 1;
        #50;

        // ---------------------------
        // Case 2: Parity error
        // ---------------------------
        parity_bit  = ~parity_bit;
        #50;

        // ---------------------------
        // Case 3: Start bit error
        // ---------------------------
        start_bit = 1;
        #50;

        // ---------------------------
        // Case 4: Stop bit error
        // ---------------------------
        start_bit = 0;
        stop_bit  = 0;
        #50;

        // ---------------------------
        // Case 5: All errors
        // ---------------------------
        start_bit  = 1;
        stop_bit   = 0;
        parity_bit = ~parity_bit;
        #50;

        // ---------------------------
        // Case 6-9: Random stress test
        // ---------------------------
        repeat (4) begin
            parity_type = $random % 3;
            raw_data    = $random;
            start_bit   = $random % 2;
            stop_bit    = $random % 2;
            parity_bit  = $random % 2;
            #50;
        end

        $stop;
    end

endmodule
