module binary_to_7seg (
    input [3:0] data_in,
    output reg [6:0] data_out
);

    always @(*) begin
        case (data_in)
            4'd0: data_out = 7'b0111111;
            4'd1: data_out = 7'b0000110;
            4'd2: data_out = 7'b1011011;
            4'd3: data_out = 7'b1001111;
            4'd4: data_out = 7'b1100110;
            4'd5: data_out = 7'b1101101;
            4'd6: data_out = 7'b1111101;
            4'd7: data_out = 7'b0000111;
            4'd8: data_out = 7'b1111111;
            4'd9: data_out = 7'b1101111;
            default: data_out = 7'b1111111; // blank or off
        endcase
    end

endmodule
