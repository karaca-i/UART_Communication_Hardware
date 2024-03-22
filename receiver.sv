`timescale 1ns / 1ps


module uart_rx (
input logic CLK,
input logic RESET,
input logic RX,
output logic [7:0] RXBUFO[3:0]
);
typedef enum logic { IDLE, RECEIVE } StateType;
StateType state;
logic [9:0] RX_PACKAGE; // 8bit data, 2bit stop
logic [3:0] bitcntr;
logic [15:0] cntr;
parameter CLOCK_FREQ = 100000000;
parameter BAUD_RATE = 115200;
logic [15:0] ADJUSTED_RATE= CLOCK_FREQ / BAUD_RATE - 1;
logic [7:0] RXBUF[3:0];
assign RXBUFO = RXBUF;
always_ff @(posedge CLK) begin
if (RESET) begin
state <= IDLE;
cntr <= 0;
bitcntr <= 0;
RXBUF <= {8'b0,8'b0,8'b0,8'b0};
RX_PACKAGE <= 8'b0;
end else begin
case (state)
IDLE: begin
if (!RX) begin
cntr <= cntr + 1;
if (cntr == ADJUSTED_RATE[15:1]) begin
state <= RECEIVE;
bitcntr <= 0;
cntr <= 0;
end
end
end
RECEIVE: begin
cntr <= cntr + 1;
if (cntr == ADJUSTED_RATE) begin
cntr <= 0;
bitcntr <= bitcntr + 1;
RX_PACKAGE <= {RX, RX_PACKAGE[9:1]};
end
if (bitcntr >= 10) begin
RXBUF <= {RX_PACKAGE[7:0],RXBUF[3:1]};
state <= IDLE;
end
end
endcase
end
end
endmodule
