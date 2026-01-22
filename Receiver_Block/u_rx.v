module SIPO #(
    parameter DATA_BITS = 8,
    parameter PARITY_EN = 1,
    parameter STOP_BITS = 1
)(
    input  wire                     reset_n,     // Active low reset
    input  wire                     data_tx,     // Serial RX data
    input  wire                     baud_clk,    // Baud clock (sampling clock)

    output reg                      active_flag, // High while receiving
    output reg                      recieved_flag,
    output reg [FRAME_W-1:0]        data_parll
);

    // -------------------------------------------------
    // Local parameters
    // -------------------------------------------------
    localparam FRAME_W = 1 + DATA_BITS + PARITY_EN + STOP_BITS;

    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    // -------------------------------------------------
    // Internal registers
    // -------------------------------------------------
    reg [1:0]  state;
    reg [$clog2(FRAME_W):0] bit_cnt;
    reg [FRAME_W-1:0] shift_reg;

    // -------------------------------------------------
    // FSM + Shift Register (Low Latency)
    // -------------------------------------------------
    always @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= IDLE;
            bit_cnt       <= 0;
            shift_reg     <= {FRAME_W{1'b1}};
            data_parll    <= {FRAME_W{1'b1}};
            recieved_flag <= 1'b0;
            active_flag   <= 1'b0;
        end
        else begin
            recieved_flag <= 1'b0;

            case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    active_flag <= 1'b0;
                    bit_cnt     <= 0;
                    if (data_tx == 1'b0) begin   // Start bit detected
                        state       <= START;
                        active_flag <= 1'b1;
                    end
                end

                // ---------------- START ----------------
                START: begin
                    shift_reg[0] <= data_tx;     // Capture start bit
                    state        <= DATA;
                    bit_cnt      <= 1;
                end

                // ---------------- DATA ----------------
                DATA: begin
                    shift_reg[bit_cnt] <= data_tx;
                    bit_cnt <= bit_cnt + 1;

                    if (bit_cnt == FRAME_W-2) begin
                        state <= STOP;
                    end
                end

                // ---------------- STOP ----------------
                STOP: begin
                    shift_reg[FRAME_W-1] <= data_tx; // Stop bit
                    data_parll           <= shift_reg;
                    recieved_flag        <= 1'b1;
                    active_flag          <= 1'b0;
                    state                <= IDLE;
                end

            endcase
        end
    end

endmodule
