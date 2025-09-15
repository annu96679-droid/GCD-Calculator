`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2025 23:56:47
// Design Name: 
// Module Name: gcd_tb
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



module gcd_tb();
    reg clk, rst, start;
    reg [15:0] A_in, B_in;
    wire done;
    wire [15:0] result;

    // DUT instance
    gcd_top DUT ( .clk(clk), .rst(rst), .start(start), .A_in(A_in), .B_in(B_in), .done(done), .result(result));

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    
    initial 
    begin
        $monitor("time=%0t | clk=%b | rst=%b | start=%b | A=%0d | B=%0d | done=%b | result=%0d",$time, clk, rst, start, A_in, B_in, done, result);
    end

   
    initial 
    begin
        // Initialize
        rst = 1; start = 0; A_in = 0; B_in = 0;
        #20 rst = 0;   

        // Test case 1: gcd(48,18)=6
        A_in = 48; B_in = 18;
        #10 start = 1;
        #10 start = 0;
        wait(done);    // wait until done goes high
        #20;

        // Test case 2: gcd(27,36)=9
        A_in = 27; B_in = 36;
        #10 start = 1;
        #10 start = 0;
        wait(done);
        #20;

        // Test case 3: gcd(100,25)=25
        A_in = 100; B_in = 25;
        #10 start = 1;
        #10 start = 0;
        wait(done);
        #20;

        // Test case 4: gcd(7,3)=1
        A_in = 7; B_in = 3;
        #10 start = 1;
        #10 start = 0;
        wait(done);
        #20;

        $display("All tests completed at time %0t", $time);
        $finish;
    end

   
    initial
     begin
        $dumpfile("gcd_tb.vcd");
        $dumpvars(0, gcd_tb);
    end
endmodule
