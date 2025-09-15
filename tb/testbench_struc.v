timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2025 00:32:45
// Design Name: 
// Module Name: GCD_TB
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


module GCD_TB;
    reg clk, rst, start;
    reg [15:0] data_in;
    wire done;

    // Instantiate Top GCD module
    gcd_top uut (.clk(clk), .rst(rst), .start(start), .data_in(data_in), .done(done));

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial
     begin
        
        $dumpfile("gcd.vcd");
        $dumpvars(0, GCD_TB);

        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        data_in = 0;

        // Release reset
        #10 rst = 0;

        // Load A 
        #10 start = 1; data_in = 148;
        #10 start = 0; data_in = 0;

        // Load B 
        #20 start = 1; data_in = 18;
        #10 start = 0; data_in = 0;

        // Wait for GCD calculation
        #200;

        $finish;
    end

    initial
     begin
        $monitor("time=%0t | clk=%b | rst=%b | start=%b | data_in=%d | done=%b",$time, clk, rst, start, data_in, done);
    end

endmodule