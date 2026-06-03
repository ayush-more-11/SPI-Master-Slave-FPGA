`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.05.2026 12:04:58
// Design Name: 
// Module Name: spi
// Project Name: 
// Target Devices: 
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

module spi(
input wire clk,
input wire rst, // expected that rst and tx_enb are complement ot each other 
input wire tx_enb, // uses has data which neesd to be transmitted 
output reg mosi,
output reg cs,
output wire sclk
);

/* used to create a custom user-defined enumerated data type that pairs descriptive text names with numeric constants
typedef enum logic [1:0] { 
    idle = 0, // sense tx_enb is high or not 
    start_tx = 1, // initiate transaction i.e make cs low 
    tx_data = 2, // 
    end_tx = 3 } state_type;

state_type state, next_state;
*/

parameter idle     = 2'b00;
parameter start_tx = 2'b01;
parameter tx_data  = 2'b10;
parameter end_tx   = 2'b11;

reg [1:0] state, next_state;

reg [7:0] din = 8'hff;

reg spi_clk = 0;
reg [2:0] count = 0;
reg [3:0] bit_count = 0;

////////////// Generating clock ///////////////
always@(posedge clk)
  begin 
    case(next_state)
    idle: begin 
        spi_clk <= 0;
    end
    
    start_tx: begin 
    if(count < 3'b011 || count == 3'b111)
        spi_clk <= 1'b1;
    else 
        spi_clk <= 1'b0;
    end 
    
    tx_data: begin 
    if(count < 3'b011 || count == 3'b111)
        spi_clk <= 1'b1;
    else 
        spi_clk <= 1'b0;
    end
    
    end_tx: begin
    if(count < 3'b011 || count == 3'b111)
        spi_clk <= 1'b1;
    else 
        spi_clk <= 1'b0;
    end
    
    default: spi_clk <= 1'b0;
    endcase 
  end 

//////// Sense Reset ( sequential ) ///////////

always@(posedge clk)
begin 
    if(rst)
        state <= idle;
    else 
        state <= next_state;
end 

/////// next_state decoder ( combinational block ) ////////////////
    always@(*)
    begin 
    next_state = state;
    mosi = 1'b0;
    cs   = 1'b1;
    
    case(state)
    
    idle: begin 
        if(tx_enb)
            next_state = start_tx;
        else 
            next_state = idle;
        end
        
    start_tx: begin
        cs = 1'b0;
        
        if(count == 3'b111)
            next_state = tx_data;
        else 
            next_state = start_tx;
        end
     
     tx_data: begin
        cs = 1'b0;
        if(bit_count != 8) begin
            mosi = din[7-bit_count];
            next_state = tx_data;
         end
        else begin 
                next_state = end_tx;
                mosi = 1'b0;
              end
         end
         
      end_tx: begin 
        if(count == 3'b111)
            next_state = idle;
         else 
            next_state = end_tx;
         end
     endcase 
 end 

// counter 
always@(posedge clk)
begin 
    case(state)
        idle: begin 
            count <= 0;
            bit_count <= 0;
        end 
        
        start_tx: begin
            if(count == 3'b111)
                count <= 0;
            else
                count <= count + 1;
        end
        /*start_tx : count <= count + 1;*/
        
        tx_data: begin
            if(bit_count != 8)begin 
                if(count < 3'b111)
                    count <= count + 1;
                 else 
                 begin 
                    count <= 0;    
                    bit_count <= bit_count + 1;
                    end 
             end
          end 
          
          end_tx:begin 
            count <= count + 1;
            bit_count <= 0;
          end 
          
          default: begin 
          count <= 0;
          bit_count <= 0;
          end 
          
          endcase
          end 
          
assign sclk = spi_clk;

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module spi_slave(
        input sclk, mosi, cs,
        output [7:0] dout,
        output reg done );

integer count = 0;

parameter idle = 0;
parameter sample = 1;
reg [1:0] state;

reg [7:0] data = 0;

always@(negedge sclk)
begin 
case(state)

idle: begin 
    done <= 1'b0; // no valid data in idle state 
    
    if(cs == 1'b0)
        state <= sample;
    else 
        state <= idle;
    end 
    
sample: begin 
    if(count < 8)
    begin 
        count <= count + 1;
        data <= {data[6:0], mosi}; // left shifting 
        state <= sample;
    end 
    else 
    begin 
        count <= 0;
        state <= idle;
        done <= 1'b1;
    end 
end 

default: state <= idle;
endcase 
end 

assign dout = data;

endmodule 
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module top(
    input clk, rst, tx_enb,
    output [7:0] dout,
    output done );
    
    wire mosi, ss, sclk;
    
    spi         spi_m(clk, rst, tx_enb, mosi, ss, sclk);
    spi_slave   spi_s(sclk, mosi, ss, dout, done);
    
endmodule   

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




















