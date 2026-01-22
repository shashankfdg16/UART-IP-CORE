`timescale 1ns/1ps
module SipoTest;

    // -------------------------------------------------
    // Parameters (match DUT)
    // -------------------------------------------------
    parameter DATA_BITS = 8;
    parameter PARITY_EN = 1;
    parameter STOP_BITS = 1;
    localparam FRAME_W  = 1 + DATA_BITS + PARITY_EN + STOP_BITS;

    // -------------------------------------------------
    // Regs to drive inputs
    // -------------------------------------------------
    reg           reset_n;
    reg           data_tx;
    reg           baud_clk;

    // -------------------------------------------------
    // Wires to observe outputs
    // -------------------------------------------------
    wire          active_flag;
    wire          recieved_flag;
    wire [FRAME_W-1:0] data_parll;

    // -------------------------------------------------
    // DUT instance
    // -------------------------------------------------
    SIPO #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN),
        .STOP_BITS(STOP_BITS)
    ) ForTest (
        .reset_n(reset_n),
        .data_tx(data_tx),
        .baud_clk(baud_clk),
        .active_flag(active_flag),
        .recieved_flag(recieved_flag),
        .data_parll(data_parll)
    );

    // -------------------------------------------------
    // Dump for waveform
    // -------------------------------------------------
    initial begin
        $dumpfile("SipoTest.vcd");
        $dumpvars(0, SipoTest);
    end

    // -------------------------------------------------
    // Monitor (important for Viva)
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t | RX=%b | ACTIVE=%b | RECEIVED=%b | FRAME=%b",
                  $time, data_tx, active_flag, recieved_flag, data_parll);
    end

    // -------------------------------------------------
    // Baud clock (9600 baud)
    // -------------------------------------------------
    initial begin
        baud_clk = 1'b0;
        forever #52083 baud_clk = ~baud_clk; // ~104.166 µs period
    end

    // -------------------------------------------------
    // Reset
    // -------------------------------------------------
    initial begin
        reset_n = 1'b0;
        data_tx = 1'b1;   // Idle state
        #200;
        reset_n = 1'b1;
    end

    // -------------------------------------------------
    // UART frame transmit task (low latency)
    // -------------------------------------------------
    task send_uart_frame;
        input [DATA_BITS-1:0] data;
        integer i;
        begin
            // Start bit
            data_tx = 1'b0;
            @(posedge baud_clk);

            // Data bits (LSB first)
            for (i = 0; i < DATA_BITS; i = i + 1) begin
                data_tx = data[i];
                @(posedge baud_clk);
            end

            // Parity bit (even parity)
            if (PARITY_EN) begin
                data_tx = ^data;
                @(posedge baud_clk);
            end

            // Stop bit
            data_tx = 1'b1;
            @(posedge baud_clk);
        end
    endtask

    // -------------------------------------------------
    // Test vectors (MULTIPLE CASES)
    // -------------------------------------------------
    initial begin
        @(posedge reset_n);

        // Case 1: Alternating bits
        send_uart_frame(8'b10101010);
        #200000;

        // Case 2: All zeros
        send_uart_frame(8'b00000000);
        #200000;

        // Case 3: All ones
        send_uart_frame(8'b11111111);
        #200000;

        // Case 4: Random data
        send_uart_frame($random);
        #200000;

        // Case 5: Another random frame
        send_uart_frame($random);
        #200000;

        $stop;
    end

endmodule
