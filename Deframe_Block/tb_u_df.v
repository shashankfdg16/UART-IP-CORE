`timescale 1ns/1ps
module DeFrameTest;

    // -------------------------------------------------
    // Parameters (same as DUT)
    // -------------------------------------------------
    parameter DATA_BITS = 8;
    parameter PARITY_EN = 1;
    parameter STOP_BITS = 1;
    localparam FRAME_W  = 1 + DATA_BITS + PARITY_EN + STOP_BITS;

    // -------------------------------------------------
    // Regs to drive the inputs
    // -------------------------------------------------
    reg  [FRAME_W-1:0] data_parll;
    reg                recieved_flag;

    // -------------------------------------------------
    // Wires to observe outputs
    // -------------------------------------------------
    wire               parity_bit;
    wire               start_bit;
    wire               stop_bit;
    wire               done_flag;
    wire [DATA_BITS-1:0] raw_data;

    // -------------------------------------------------
    // DUT Instance
    // -------------------------------------------------
    DeFrame #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(PARITY_EN),
        .STOP_BITS(STOP_BITS)
    ) DUT (
        .data_parll(data_parll),
        .recieved_flag(recieved_flag),

        .parity_bit(parity_bit),
        .start_bit(start_bit),
        .stop_bit(stop_bit),
        .done_flag(done_flag),
        .raw_data(raw_data)
    );

    // -------------------------------------------------
    // Dump for waveform
    // -------------------------------------------------
    initial begin
        $dumpfile("DeFrameTest.vcd");
        $dumpvars(0, DeFrameTest);
    end

    // -------------------------------------------------
    // Monitor
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t | FRAME=%b | DATA=%b | START=%b | PARITY=%b | STOP=%b | DONE=%b",
                  $time, data_parll, raw_data, start_bit, parity_bit, stop_bit, done_flag);
    end

    // -------------------------------------------------
    // Test Stimulus
    // -------------------------------------------------
    initial begin
        recieved_flag = 1'b0;
        data_parll    = {FRAME_W{1'b1}};
        #20;

        // -------------------------------
        // Test Case 1: Valid frame
        // Start=0, Data=8'hA5, Parity=even, Stop=1
        // -------------------------------
        recieved_flag = 1'b1;
        data_parll = {1'b1, ^8'hA5, 8'hA5, 1'b0};
        #20;

        // -------------------------------
        // Test Case 2: Parity error frame
        // -------------------------------
        data_parll = {1'b1, ~(^8'h3C), 8'h3C, 1'b0};
        #20;

        // -------------------------------
        // Test Case 3: All zeros data
        // -------------------------------
        data_parll = {1'b1, ^8'h00, 8'h00, 1'b0};
        #20;

        // -------------------------------
        // Test Case 4: All ones data
        // -------------------------------
        data_parll = {1'b1, ^8'hFF, 8'hFF, 1'b0};
        #20;

        // -------------------------------
        // Test Case 5: Random frames
        // -------------------------------
        repeat (5) begin
            data_parll = $random;
            #20;
        end

        $stop;
    end

endmodule
