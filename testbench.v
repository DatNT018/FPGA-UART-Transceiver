`timescale 1ns/1ps

module testbench();

  localparam CLOCKS_PER_PULSE = 4;
  reg [7:0] data_in = 8'b00000001;  // Đảm bảo data_in là 8 bit
  reg clk = 0;
  reg rstn = 0;
  reg enable = 1;

  wire tx_busy;
  wire ready;
  wire [7:0] data_out;
  wire [7:0] display_out;

  reg loopback;
  reg ready_clr = 1;

  uart #(.CLOCKS_PER_PULSE(CLOCKS_PER_PULSE)) 
    dut (
      .data_in(data_in),
      .data_en(enable),
      .clk(clk),
      .tx(loopback),
      .tx_busy(tx_busy),
      .rx(loopback),
      .ready(ready),
      .ready_clr(ready_clr),
      .led_out(data_out),
      .display_out(display_out),
      .rstn(rstn)
    );

  // Tạo tín hiệu clock
  always begin
    #1 clk = ~clk;
  end

  // Khởi tạo
  initial begin
    $dumpfile("testbench.vcd");
    $dumpvars(0, testbench);
    rstn <= 1;
    enable <= 1'b0;
    #2 rstn <= 0;
    #2 rstn <= 1;
    #5 enable <= 1'b1;
  end
  
  // Kiểm tra khi ready được kích hoạt
  always @(posedge ready) begin
    if (data_out != data_in) begin
      $display("FAIL: rx data %x does not match tx %x", data_out, data_in);
      $finish();
    end else begin
      if (data_out == 8'b11111111) begin  // Kiểm tra dữ liệu đã nhận là 11111111
        $display("SUCCESS: all bytes verified");
        $finish();
      end

      // Gửi dữ liệu mới
      #10 rstn <= 0;
      #2 rstn <= 1;
      data_in <= data_in + 1'b1;
      enable <= 1'b0;
      #2 enable <= 1'b1;
    end
  end
endmodule
