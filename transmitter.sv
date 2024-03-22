`timescale 1ns / 1ps

module uart_tx (
input logic AUTO,
input logic load,
input logic CLK,
input logic RESET,
input logic [7:0] TX_IN,
input logic TX_SEND_DATA,
output logic TX,
output logic [7:0] TXBUF_OUT[3:0]
);
typedef enum logic [1:0] { IDLE, TRANSFER , AUTOMATIC_TRANSFER ,
LOAD_NEXT_BYTE} StateType;
StateType state;
parameter CLOCK_FREQ = 100000000; // 100mhz
parameter BAUD_RATE = 115200;
parameter start_bit = 1'b0;
parameter stop_bit = 1'b1;
logic [7:0] TXBUF[3:0] = {8'b0,8'b0,8'b0,8'b0};
logic prevload=0;
logic prevena=0;
logic [15:0] cntr;
logic [3:0] bitcntr;
logic [10:0] TX_PACKAGE;
logic [1:0] auto_count=2'b00;
logic [15:0] ADJUSTED_RATE = (CLOCK_FREQ / BAUD_RATE) - 1;
assign TXBUF_OUT = TXBUF;
always_ff @(posedge CLK) begin
if (RESET) begin
state <= IDLE;
TX <= stop_bit;
end else begin
case (state)
IDLE: begin
TX <= stop_bit;
if (load && !prevload) begin
prevload <= 1;
TXBUF <= {TX_IN,TXBUF[3:1]};
end
else if (!load && prevload)begin
prevload <= 0;
end
if (AUTO && TX_SEND_DATA && !prevena)begin
prevena <= 1;
state <= AUTOMATIC_TRANSFER;
cntr <= 0;
auto_count <= 2'b00;
TX_PACKAGE <= {stop_bit,stop_bit, TXBUF[0] ,start_bit}; // 2 stop bit
bitcntr <= 0;
end else if (AUTO && !TX_SEND_DATA && prevena) begin
prevena <= 0;
end
else if (TX_SEND_DATA && !prevena) begin
prevena <= 1;
state <= TRANSFER;
cntr <= 0;
bitcntr <= 0;
auto_count <= 2'b00;
TX_PACKAGE <= {stop_bit, stop_bit, TXBUF[0] , start_bit};
end else if (!TX_SEND_DATA && prevena) begin
prevena <= 0;
end
end
TRANSFER: begin
TX <= TX_PACKAGE[0];
cntr <= cntr + 1;
if (cntr == ADJUSTED_RATE) begin
cntr <= 0;
bitcntr <= bitcntr + 1;
TX_PACKAGE[9:0] <= TX_PACKAGE[10:1];
if (bitcntr >= 10) begin
state <= IDLE;
end
end
end
AUTOMATIC_TRANSFER: begin
TX <= TX_PACKAGE[0];
cntr <= cntr + 1;
if (cntr == ADJUSTED_RATE) begin
cntr <= 0;
bitcntr <= bitcntr + 1;
TX_PACKAGE[9:0] <= TX_PACKAGE[10:1];
if (bitcntr >= 10 && auto_count == 3)begin
state <= IDLE;
end
else if (bitcntr >= 10) begin
auto_count <= auto_count + 1;
state <= LOAD_NEXT_BYTE;
end
end
end
LOAD_NEXT_BYTE: begin
TX <= stop_bit;
state <= AUTOMATIC_TRANSFER ;
cntr <= 0;
bitcntr <= 0;
TX_PACKAGE <= {stop_bit,stop_bit, TXBUF[auto_count] , start_bit};
end
endcase
end
end
endmodule
