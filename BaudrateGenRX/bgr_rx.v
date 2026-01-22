module BaudGenR_d #(
    parameter CLK_FREQ = 50_000_000
)(
    input  wire        reset_n,
    input  wire        clock,
    input  wire [1:0]  baud_rate,
    output reg         baud_clk
);

    reg [15:0] count;
    reg [15:0] final_value;

    always @(*) begin
        case (baud_rate)
            2'b00: final_value = CLK_FREQ / (2400  * 16);
            2'b01: final_value = CLK_FREQ / (4800  * 16);
            2'b10: final_value = CLK_FREQ / (9600  * 16);
            2'b11: final_value = CLK_FREQ / (19200 * 16);
            default: final_value = CLK_FREQ / (9600 * 16);
        endcase
    end

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            count    <= 0;
            baud_clk <= 0;
        end else if (count == final_value) begin
            baud_clk <= ~baud_clk;
            count    <= 0;
        end else begin
            count <= count + 1;
        end
    end

endmodule
