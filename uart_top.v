module uart #(parameter CLOCKS_PER_PULSE = 5208)(
    input [3:0] data_in,
    input data_en,
    input clk,
    input rstn,
    output tx,
    output tx_busy,
    input ready_clr,
    input rx,
    input [17:0] SW,
    input [3:0] KEY,
    output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
	output [17:0] LEDR,
	output [7:0] LEDG,
    output ready,
    output [7:0] led_out,
    output [6:0] display_out
);

    wire data_en = ~KEY[0];
    wire ready_clr = ~KEY[1];

    wire [7:0] data_input;
    wire [7:0] data_output;

    transmitter #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) uart_tx (
        .data_in(data_input),
        .data_en(data_en),
        .clk(clk),
        .rstn(rstn),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    receiver #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) uart_rx (
        .clk(clk),
        .rstn(rstn),
        .ready_clr(ready_clr),
        .rx(rx),
        .ready(ready),
        .data_out(data_output)
    );

    binary_to_7seg converter (
        .data_in(data_output[3:0]),
        .data_out(display_out)
    );

    assign data_input = {4'b0000, SW[3:0]};  // hoặc dùng data_in
    assign led_out = data_output;
    assign LEDG = data_output;
    assign HEX0 = display_out;

endmodule