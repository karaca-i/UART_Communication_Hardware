`timescale 1ns / 1ps

module displayer2(
input RIGHT_PAGE,
input LEFT_PAGE,
input CLK,
input RESET,
input [7:0] MEM[3:0],
output logic [3:0] ANODE,
output logic [6:0] SEGMENT_PATTERN,
output logic [1:0] page_out
);

logic [3:0] LED;
logic [19:0] refresh_counter = 20'b0;
logic [1:0] LED_Activation;
logic shlprev = 0;
logic shrprev = 0;
logic position = 0;
assign page_out = (position == 0) ? 2'b10 : 2'b01;
always_ff @(posedge CLK)begin
if (RIGHT_PAGE & !shrprev) begin
shrprev <= 1;
position <= ~position;
end else if (!RIGHT_PAGE & shrprev)begin
shrprev <= 0;
end
if (LEFT_PAGE & !shlprev) begin
shlprev <= 1;
position <= ~position;
end else if (!LEFT_PAGE & shlprev) begin
shlprev <= 0;
end
end
always @(posedge CLK or posedge RESET)
begin
if(RESET==1)
refresh_counter <= 0;
else
refresh_counter <= refresh_counter + 1;
end
assign LED_Activation = refresh_counter[19:18];
always @(*)
begin
case(LED_Activation)
2'b00: begin
ANODE = 4'b0111;
LED = MEM[3-position-position][7:4];
end
2'b01: begin
ANODE = 4'b1011;
LED = MEM[3-position-position][3:0];
end
2'b10: begin
ANODE = 4'b1101;
LED = MEM[2-position-position][7:4];
end
2'b11: begin
ANODE = 4'b1110;
LED = MEM[2-position-position][3:0];
end
endcase
end
always @(*)
begin
case(LED)
4'b0000: SEGMENT_PATTERN = 7'b0000001; // "0"
4'b0001: SEGMENT_PATTERN = 7'b1001111; // "1"
4'b0010: SEGMENT_PATTERN = 7'b0010010; // "2"
4'b0011: SEGMENT_PATTERN = 7'b0000110; // "3"
4'b0100: SEGMENT_PATTERN = 7'b1001100; // "4"
4'b0101: SEGMENT_PATTERN = 7'b0100100; // "5"
4'b0110: SEGMENT_PATTERN = 7'b0100000; // "6"
4'b0111: SEGMENT_PATTERN = 7'b0001111; // "7"
4'b1000: SEGMENT_PATTERN = 7'b0000000; // "8"
4'b1001: SEGMENT_PATTERN = 7'b0000100; // "9"
4'b1010: SEGMENT_PATTERN = 7'b0001000; // "A"
4'b1011: SEGMENT_PATTERN = 7'b1100000; // "B"
4'b1100: SEGMENT_PATTERN = 7'b0110001; // "C"
4'b1101: SEGMENT_PATTERN = 7'b1000010; // "D"
4'b1110: SEGMENT_PATTERN = 7'b0110000; // "E"
4'b1111: SEGMENT_PATTERN = 7'b0111000; // "F"
default: SEGMENT_PATTERN = 7'b0000001; // "0"
endcase
end
endmodule


module uart_module(
input logic RX,
input logic AUTO,
input logic up,
input logic RIGHT_PAGE,
input logic LEFT_PAGE,
input logic load,
input logic CLK,
input logic RESET,
input logic [7:0] TX_IN,
input logic TX_SEND_DATA,
output logic [6:0] SEGMENT_PATTERN,
output logic [3:0] ANODE,
output logic [7:0] TXBUF_OUT,
output logic posout,
output logic [1:0] pageout,
output logic TX
);
logic upprev = 0;
logic pos = 0;
logic [7:0] DISPLAY[3:0];
logic [7:0] TXBUF[3:0];
logic [7:0] RXBUFO [3:0];
assign posout = pos;
assign DISPLAY = (pos == 0)? TXBUF : RXBUFO;
assign TXBUF_OUT = TXBUF[3];
always_ff @(posedge CLK)begin
if (up & !upprev) begin
upprev <= 1;
pos <= ~pos;
end
else if (!up & upprev)begin
upprev<=0;
end
end
uart_tx tx(AUTO,load,CLK,RESET,TX_IN,TX_SEND_DATA,TX,TXBUF);
uart_rx rx(CLK,RESET,RX,RXBUFO);
displayer2
sm(RIGHT_PAGE,LEFT_PAGE,CLK,RESET,DISPLAY,ANODE,SEGMENT_PATTERN,
pageout);
endmodule




