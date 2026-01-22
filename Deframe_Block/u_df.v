module DeFrame #(
    parameter DATA_BITS = 8,      // Number of data bits
    parameter PARITY_EN = 1,      // 1 = parity enabled, 0 = no parity
    parameter STOP_BITS = 1       // Number of stop bits
)(
    input  wire [FRAME_W-1:0] data_parll,   // Complete UART frame
    input  wire               recieved_flag,

    output reg                parity_bit,   // Extracted parity bit
    output reg                start_bit,    // Extracted start bit
    output reg                stop_bit,     // Extracted stop bit
    output reg                done_flag,    // Frame received indication
    output reg [DATA_BITS-1:0] raw_data     // Extracted data
);

    // -------------------------------------------------
    // Local parameter for frame width
    // -------------------------------------------------
    localparam FRAME_W = 1 + DATA_BITS + PARITY_EN + STOP_BITS;

    // -------------------------------------------------
    // Deframing logic (pure combinational → low latency)
    // -------------------------------------------------
    always @(*) begin
        start_bit = data_parll[0];

        raw_data  = data_parll[DATA_BITS:1];

        if (PARITY_EN)
            parity_bit = data_parll[DATA_BITS + 1];
        else
            parity_bit = 1'b0;

        stop_bit  = data_parll[FRAME_W-1];

        done_flag = recieved_flag;
    end

endmodule
