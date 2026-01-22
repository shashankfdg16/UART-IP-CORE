module ErrorCheck #(
    parameter DATA_BITS  = 8,   // Number of data bits (UART configurable)
    parameter PARITY_EN  = 1    // 1 = Enable parity, 0 = Disable parity
)(
    input  wire         reset_n,        // Active low reset
    input  wire         recieved_flag,   // Frame valid from RX path
    input  wire         parity_bit,      // Received parity bit
    input  wire         start_bit,       // Received start bit
    input  wire         stop_bit,        // Received stop bit
    input  wire  [1:0]  parity_type,     // 01 = ODD, 10 = EVEN
    input  wire  [DATA_BITS-1:0] raw_data,

    output wire [2:0]   error_flag       // {STOP_ERR, START_ERR, PARITY_ERR}
);

    // -------------------------------------------------
    // Internal signals
    // -------------------------------------------------
    reg parity_err;
    reg start_err;
    reg stop_err;

    // Parity encoding
    localparam ODD  = 2'b01;
    localparam EVEN = 2'b10;

    // -------------------------------------------------
    // Parity check (Low latency – combinational)
    // -------------------------------------------------
    always @(*) begin
        if (PARITY_EN) begin
            case (parity_type)
                ODD  : parity_err = ~( ^raw_data ) ^ parity_bit;
                EVEN : parity_err = (  ^raw_data ) ^ parity_bit;
                default: parity_err = 1'b1; // Invalid parity type
            endcase
        end else begin
            parity_err = 1'b0; // Parity disabled
        end
    end

    // -------------------------------------------------
    // Start & Stop bit check
    // -------------------------------------------------
    always @(*) begin
        start_err = (start_bit != 1'b0); // Start bit must be 0
        stop_err  = (stop_bit  != 1'b1); // Stop bit must be 1
    end

    // -------------------------------------------------
    // Output error flags (no extra clock latency)
    // -------------------------------------------------
    assign error_flag = (reset_n && recieved_flag) ?
                        {stop_err, start_err, parity_err} :
                        3'b000;

endmodule
