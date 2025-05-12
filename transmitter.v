module transmitter #(
    parameter CLOCKS_PER_PULSE = 16
)(
    input [7:0] data_in,
    input data_en,
    input clk,
    input rstn,
    output reg tx,
    output tx_busy
);

    // State encoding
    parameter TX_IDLE  = 2'b00,
              TX_START = 2'b01,
              TX_DATA  = 2'b10,
              TX_END   = 2'b11;

    reg [1:0] state;

    reg [7:0] data;
    reg [2:0] c_bits;
    reg [3:0] c_clocks;  // Enough for up to CLOCKS_PER_PULSE = 16

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_clocks <= 0;
            c_bits <= 0;
            data <= 8'b0;
            tx <= 1'b1;
            state <= TX_IDLE;
        end else begin
            case (state)
                TX_IDLE: begin
                    tx <= 1'b1;
                    if (~data_en) begin
                        data <= data_in;
                        c_bits <= 3'b0;
                        c_clocks <= 0;
                        state <= TX_START;
                    end
                end

                TX_START: begin
                    tx <= 1'b0;  // Start bit
                    if (c_clocks == (CLOCKS_PER_PULSE - 1)) begin
                        c_clocks <= 0;
                        state <= TX_DATA;
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                TX_DATA: begin
                    tx <= data[c_bits];
                    if (c_clocks == (CLOCKS_PER_PULSE - 1)) begin
                        c_clocks <= 0;
                        if (c_bits == 3'd7) begin
                            state <= TX_END;
                        end else begin
                            c_bits <= c_bits + 1;
                        end
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                TX_END: begin
                    tx <= 1'b1;  // Stop bit
                    if (c_clocks == (CLOCKS_PER_PULSE - 1)) begin
                        c_clocks <= 0;
                        state <= TX_IDLE;
                    end else begin
                        c_clocks <= c_clocks + 1;
                    end
                end

                default: begin
                    state <= TX_IDLE;
                end
            endcase
        end
    end

    assign tx_busy = (state != TX_IDLE);

endmodule
