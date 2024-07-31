`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 04:52:04 PM
// Design Name: Ganap Tewary
// Module Name: 
// Project Name: Fitness Tacker Analyzer
// Target Devices: XC7A100T-1CSG324C
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FitBit_Tracker(input PULSE,CLK,RESET, output reg[13:0] STEPS, reg OFLOW,wire [4:0] DISTANCE);


reg [15:0] steps_counter = 0;

assign DISTANCE = steps_counter[9:5];

always @(posedge CLK) begin
    STEPS<= steps_counter[13:0];
    
    if(RESET) begin
        steps_counter <=0;
        STEPS <=0;
        OFLOW <=0;
        end
    else begin 
        if(steps_counter >= 16'd9999) begin
            STEPS <= 16'd9999;
            OFLOW <= 1;
        end
        if(PULSE==1)begin
            steps_counter <= steps_counter+1;
            end
            end

end
endmodule

module PULSE_Generator(input [1:0] MODE,STOP,START,CLK,RST, output PULSE);

reg PULSE;
reg generation;
reg[27:0] counter =0;
    always@(posedge CLK)begin
        if(RST)begin
            generation<=0;
            counter<=0;
        end
        else if(START) begin
            generation <=1;
        end
        else if(STOP) begin
            generation <=0;
        end
        
        else if(generation)
            counter = counter+1;
                case(MODE)
                    2'b00: begin
                        if(counter>= 32)begin
                            counter <= 0;
                            PULSE <=0;
                            end
                        else 
                            PULSE <=0;
                        end
                    2'b01:  begin
                        if(counter>= 64)begin
                            counter <= 0;
                            PULSE <=1;
                            end
                        else 
                            PULSE <=0;
                        end
                    2'b10: begin
                        if(counter>= 128)begin
                            counter <= 0;
                            PULSE <=1;
                            end
                        else 
                            PULSE <=0;
                        end      
                    2'b11: PULSE <= 0;
                    endcase
                    end                                       
endmodule


module seg_driver(bcd, dot, clk, cathode, anode);

input clk;

input dot;

output [7:0] cathode;

input [15:0] bcd;

output reg[3:0] anode;

reg [1:0] refresh_counter = 0;

reg refresh_clk = 0;

reg [3:0] bcd_digit;

reg dp;

wire [7:0] digit;

assign cathode = ~digit;

bcd_seven bcd2seven(bcd_digit, dp, digit);

reg[16:0] counter = 0;

always @ (posedge clk)

begin

if(counter == 100000) begin //100000

counter <= 1;

refresh_clk <= refresh_clk;

end begin

counter <= counter + 1;

end

end


always @(posedge refresh_clk) begin refresh_counter <= refresh_counter + 1;

case(refresh_counter)

2'd0: begin
anode <= 4'b1110;
bcd_digit <= bcd[3:0];
dp <= 0;
end

2'd1: begin
anode <= 4'b1101;
bcd_digit <= bcd[7:4];
dp <= 0;
end

2'd2: begin
anode <= 4'b1011;
bcd_digit <= bcd[11:8];
dp <= 0;
end

2'd3: begin
anode <= 4'b0111;
bcd_digit <= bcd[15:12];
dp <= 0;
end
endcase
end 
endmodule


module bcd_seven (bcd, dot, segs_with_dp);

output [7:0] segs_with_dp;
input [3:0] bcd;
input dot;

reg [6:0] seven;


always @(bcd)

begin

    case (bcd)

        4'b0000: seven = 7'b0111111;
        4'b0001: seven = 7'b0000110;
        4'b0010: seven = 7'b1011011;
        4'b0011: seven = 7'b1001111;
        4'b0100: seven = 7'b1100110;
        4'b0101: seven = 7'b1101101;
        4'b0110: seven = 7'b0111101;
        4'b0111: seven = 7'b0000111;
        4'b1000: seven = 7'b0111111;
        4'b1001: seven = 7'b1101111;
        default : seven= 7'b0000000;
        endcase
        end
        assign segs_with_dp = {dot,seven};         
endmodule


module binarytobcd(binary, start, clk, done, bcd);

input [13:0] binary;

input start, clk;

output reg done;

output reg [15:0] bcd = 0;

reg [13:0] binary_reg = 0;

reg [2:0] state = 0;

reg [3:0] counter = 0;

always @(posedge clk)

case(state)

2'd0: begin
 if(start) begin
     bcd <= 16'd0;
     binary_reg <= binary;
     counter <= 0; 
     done <= 0;
     state <= 2'd1;

end
end

2'd1:
if(counter == 4'd14) begin
     state <= 2'd0; 
     done = 1;
end

else begin
    if (bcd[3:0] >= 5) bcd[3:0] <= bcd[3:0] + 3;
    if (bcd[7:4] >= 5) bcd[7:4] <= bcd[7:4] + 3;
    if (bcd[11:8] >= 5) bcd[11:8] <= bcd[11:8] + 3;
    if (bcd[15:12] >= 5) bcd[15:12] <= bcd[15:12] + 3;
    state <= 2'd2;
end

2'd2: begin 
    bcd <= {bcd[14:0], binary_reg[13]};
    binary_reg <= binary_reg <<1;
    counter <= counter +1;
    state <= 2'd1;
    end
    
    endcase
    endmodule


module fitbit (mode,reset,clk, start, stop, oflow, cathode, anode);
input clk, start,stop,reset;
input [1:0] mode;
output oflow;
output[7:0] cathode;
output[7:0] anode;

wire start_db, stop_db, pulse;

wire [13:0] steps;

wire [4:0] distance;

reg start_bin2bcd;

wire done_bin2bcd;

wire [15:0] steps_bcd;

reg [15:0] bcd;

reg dot;

assign anode [7:4] = 4'b1111;

debouncer start_debuoncer (clk, reset, start, start_db);
debouncer stop_debouncer(clk, reset, stop, stop_db);

PULSE_Generator psg(.MODE(mode), .START (start_db), .STOP(stop_db), .CLK(clk), .RST(reset), .PULSE (pulse)); 
FitBit_Tracker fbt(.PULSE(PULSE), .CLK(clk), .RESET (reset), .STEPS (steps), .OFLOW(oflow), .DISTANCE (distance));

binarytobcd bin2bcd(.binary(steps), .start(start_bin2bcd), .clk(clk), .done (done_bin2bcd), .bcd(steps_bcd)); 
seg_driver sg(.bcd(bcd), .dot (dot), .clk(clk), .cathode (cathode), .anode (anode [3:0]));

reg [6:0] bin2bcd_counter=0;
always @ (posedge clk) begin

    if(bin2bcd_counter[6] ==1) begin

        bin2bcd_counter <= 0;
        start_bin2bcd <= 1;

    end

    else begin 
    bin2bcd_counter <= bin2bcd_counter + 1;
    start_bin2bcd <= 0;
end
end

reg [2:0] state = 0 ;
reg [27:0] counter = 0;

always @(posedge clk) begin
counter <= counter + 1;

    if(counter >= 200000000) begin // 200000000

        counter <= 0;

    case(state)

2'd0: begin
 state <= 1;
end

2'd1: begin 
state <= 2;
end

2'd2: begin 
state <= 0;
end

endcase
end
case(state)

2'd0: begin

    if(done_bin2bcd == 1)
         bcd <= steps_bcd;
     dot <= 0;

end

2'd1: begin

bcd[15:8] <= 0;

bcd[7:4] <= distance[4:1];

if(distance[0] == 1'b1)

bcd[3:0] <= 5;

else

bcd[3:0] <= 0;

dot <= 1;

end

2'd2: begin
 bcd[15:2] <= 0;
 bcd[1:0] <= mode;
 dot <= 0;
 end
 
 endcase
 end
 endmodule
 
 
 module debouncer #(
parameter N_BOUNCE =3,
parameter IS_PULLUP = 0
)

(clk, rst, i_sig, o_sig_debounced);

input clk;
input rst;
input i_sig;
output o_sig_debounced;

reg isig_rg, isig_sync_rg; //Registers in 2FF Synchronizer
reg sig_rg, sig_d_rg, sig_debounced_rg; //Registers for switch's state reg [N_BOUNCE 0] counter_rg; //Counter
reg [N_BOUNCE : 0] counter_rg;
always @(posedge clk)

begin

if (rst)

begin

// Internal Registers

    sig_rg <= IS_PULLUP;
    sig_d_rg <= IS_PULLUP;
    sig_debounced_rg <= IS_PULLUP; 
    counter_rg <= 1;
end


else

begin

sig_rg <= isig_sync_rg;

sig_d_rg <= sig_rg;

counter_rg <= (sig_d_rg == sig_rg)? counter_rg + 1:1;
if (counter_rg [N_BOUNCE])
    begin 
        sig_debounced_rg <= sig_d_rg;
        end
        end
        end
 
 always @ (posedge clk) begin
    if(rst)
        begin 
            isig_rg <= IS_PULLUP;
            isig_sync_rg <= IS_PULLUP;
            end
            
     else 
     begin 
            isig_rg <= isig_rg;
            isig_sync_rg <= isig_rg;
            end
        end
      assign o_sig_debounced = sig_debounced_rg;
      
 endmodule
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

 



