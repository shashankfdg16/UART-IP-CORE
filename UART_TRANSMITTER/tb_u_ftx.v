`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Parameterized Low-Latency UART Transmitter
// Project: Design of a Parameterized Low-Latency UART IP Core
//////////////////////////////////////////////////////////////////////////////////

module transmitter_tb;

    // -------------------------------------------------
    // Signals
    // -------------------------------------------------
    reg         clock;
    reg         reset_n;
    reg         send;
    reg [7:0]   data_in;

    wire        data_tx;
    wire        active_flag;
    wire        done_flag;

    // -------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------
    transmitter_d dut (
        .clock(clock),
        .reset_n(reset_n),
        .send(send),
        .data_in(data_in),
        .data_tx(data_tx),
        .active_flag(active_flag),
        .done_flag(done_flag)
    );

    // -------------------------------------------------
    // 50 MHz Clock Generation (20 ns period)
    // -------------------------------------------------
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    // -------------------------------------------------
    // Monitor Statement (MANDATORY FOR VIVA)
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t | SEND=%b | DATA=%h | TX=%b | ACTIVE=%b | DONE=%b",
                  $time, send, data_in, data_tx, active_flag, done_flag);
    end

    // -------------------------------------------------
    // Test Sequence
    // -------------------------------------------------
    initial begin
        // Initial values
        reset_n = 1'b0;
        send    = 1'b0;
        data_in = 8'h00;

        // Apply reset
        #100;
        reset_n = 1'b1;

        // Send first byte
        #50;
        data_in = 8'hA5;
        send    = 1'b1;
        #20;
        send    = 1'b0;

        // Wait until transmission completes
        wait(done_flag);

        // Send second byte
        #100;
        data_in = 8'h3C;
        send    = 1'b1;
        #20;
        send    = 1'b0;

        // Wait for completion
        wait(done_flag);

        // End simulation
        #500;
        $finish;
    end

endmodule
