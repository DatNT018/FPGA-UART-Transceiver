module receiver #(
    parameter CLOCKS_PER_PULSE = 16
)(
    input clk,
    input rstn,
    input ready_clr,
    input rx,
    output reg ready,
    output [7:0] data_out
);

    parameter RX_IDLE = 2'b00,
              RX_START = 2'b01,
              RX_DATA = 2'b10,
              RX_END = 2'b11;

    reg [1:0] state;

    reg [2:0] c_bits;
    reg [3:0] c_clocks; // 2^4 =16

    reg [7:0] temp_data;
    reg rx_sync;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_clocks <= 0;
            c_bits <= 0;
            temp_data <= 8'b0;
            ready <= 0;
            state <= RX_IDLE;
            rx_sync <= 1'b1;
        end else begin
            rx_sync <= rx; 

            case (state)
                RX_IDLE: begin
                    ready <= 0;
                    if (rx_sync == 0) begin
                        state <= RX_START;
                        c_clocks <= 0;
                    end
                end

                RX_START: begin
                    if (c_clocks == (CLOCKS_PER_PULSE/2 - 1)) begin
                        c_clocks <= 0;
                        state <= RX_DATA;
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                RX_DATA: begin
                    if (c_clocks == (CLOCKS_PER_PULSE - 1)) begin
                        c_clocks <= 0;
                        temp_data[c_bits] <= rx_sync;
                        if (c_bits == 3'd7) begin
                            c_bits <= 0;
                            state <= RX_END;
                        end else begin
                            c_bits <= c_bits + 1;
                        end
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                RX_END: begin
                    if (c_clocks == (CLOCKS_PER_PULSE - 1)) begin
                        c_clocks <= 0;
                        ready <= 1;
                        state <= RX_IDLE;
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                default: state <= RX_IDLE;
            endcase
        end
    end

    assign data_out = temp_data;

endmodule
