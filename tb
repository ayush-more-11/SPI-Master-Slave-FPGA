`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2026 13:37:39
// Design Name: 
// Module Name: spi_tb
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

module spi_tb;

reg clk = 0;
reg rst = 0;
reg tx_enb = 0;
wire [7:0] dout;
wire done;

always #5 clk = ~clk;

initial begin 
rst = 1;
repeat(5) @(posedge clk);
rst = 0;
end 

initial begin 
tx_enb = 0;
repeat(5) @(posedge clk);
tx_enb = 1;
end 

top dut (clk, rst, tx_enb, dout, done);

endmodule




/*module spi_tb; // for spi master 

    reg clk = 0;
    reg rst = 0;
    reg tx_enb = 0;
    wire mosi;
    wire ss;
    wire sclk;
    
    always #5 clk = ~clk;
    
    initial begin
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    end

    initial begin
    tx_enb = 0;
    repeat(5) @(posedge clk);
    tx_enb = 1;
    end

spi dut (clk, rst, tx_enb, mosi, ss, sclk);

endmodule */
