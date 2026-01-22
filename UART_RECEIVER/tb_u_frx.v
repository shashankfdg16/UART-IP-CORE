module RxTest;

    // -------------------------------------------------
    // Parameters (Project-Oriented)
    // -------------------------------------------------
    parameter DATA_BITS = 8;

    // -------------------------------------------------
    // Regs to drive inputs
    // -------------------------------------------------
    reg         reset_n;
    reg         data_tx;
    reg         clock;
    reg  [1:0]  parity_type;
    reg  [1:0]  baud_rate;

    // -------------------------------------------------
    // DUT outputs
    // -------------------------------------------------
    wire        done_flag;
    wire        active_flag;
    wire [2:0]  error_flag;
    wire [DATA_BITS-1:0] data_out;

    // -------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------
    RxUnit #(
        .DATA_BITS(DATA_BITS),
        .PARITY_EN(1),
        .STOP_BITS(1)
    ) DUT (
        .reset_n(reset_n),
        .data_tx(data_tx),
        .clock(clock),
        .parity_type(parity_type),
        .baud_rate(baud_rate),
        .active_flag(active_flag),
        .done_flag(done_flag),
        .error_flag(error_flag),
        .data_out(data_out)
    );

    // -------------------------------------------------
    // Clock generation (50 MHz system clock)
    // -------------------------------------------------
    initial begin
        clock = 1'b0;
        forever #10 clock = ~clock;
    end

    // -------------------------------------------------
    // Reset
    // -------------------------------------------------
    initial begin
        reset_n = 1'b0;
        data_tx = 1'b1;   // UART idle
        #100;
        reset_n = 1'b1;
    end

    // -------------------------------------------------
    // UART Frame Sender Task (LOW LATENCY)
    // -------------------------------------------------
    task send_uart_frame;
        input [DATA_BITS-1:0] data;
        input integer bit_time;
        integer i;
        reg parity;
        begin
            // Start bit
            data_tx = 1'b0;
            #(bit_time);

            // Data bits (LSB first)
            for (i = 0; i < DATA_BITS; i = i + 1) begin
                data_tx = data[i];
                #(bit_time);
            end

            // Parity bit
            parity = ^data;
            if (parity_type == 2'b01)      // ODD
                data_tx = ~parity;
            else if (parity_type == 2'b10) // EVEN
                data_tx = parity;

            #(bit_time);

            // Stop bit
            data_tx = 1'b1;
            #(bit_time);
        end
    endtask

    // -------------------------------------------------
    // Test Cases
    // -------------------------------------------------
    initial begin
        @(posedge reset_n);

        // ---------------- Test Case 1 ----------------
        // 9600 baud, ODD parity
        baud_rate   = 2'b10;
        parity_type = 2'b01;
        send_uart_frame(8'hA5, 104166);
        #200000;

        // ---------------- Test Case 2 ----------------
        // 9600 baud, EVEN parity
        baud_rate   = 2'b10;
        parity_type = 2'b10;
        send_uart_frame(8'h3C, 104166);
        #200000;

        // ---------------- Test Case 3 ----------------
        // 19200 baud, ODD parity
        baud_rate   = 2'b11;
        parity_type = 2'b01;
        send_uart_frame(8'hF0, 52083);
        #200000;

        // ---------------- Test Case 4 ----------------
        // Parity error injection
        baud_rate   = 2'b10;
        parity_type = 2'b01;
        send_uart_frame(8'hAA, 104166);
        data_tx = ~data_tx; // flip parity intentionally
        #200000;

        $stop;
    end

    // -------------------------------------------------
    // Monitor (IMPORTANT FOR VIVA)
    // -------------------------------------------------
    initial begin
        $monitor("TIME=%0t | RX=%b | DATA=%h | ACTIVE=%b | DONE=%b | ERROR=%b",
                  $time, data_tx, data_out, active_flag, done_flag, error_flag);
    end

endmodule
