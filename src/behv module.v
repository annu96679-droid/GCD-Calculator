`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2025 23:47:25
// Design Name: 
// Module Name: gcd_dp
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


//data path for GCD CALCULATOR
module gcd_dp(
    input  wire         clk,
    input  wire         rst,       // active-high reset
    input  wire         ldA,       // load A_in into A_reg
    input  wire         ldB,       // load B_in into B_reg
    input  wire         subA,      // A <= A - B
    input  wire         subB,      // B <= B - A
    input  wire [15:0]  A_in,
    input  wire [15:0]  B_in,
    output wire [15:0]  A_out,
    output wire [15:0]  B_out,
    output wire         A_eq_B,
    output wire         A_gt_B,
    output wire         A_lt_B
);
    reg [15:0] A_reg, B_reg;

    wire [15:0] A_minus_B = A_reg - B_reg;
    wire [15:0] B_minus_A = B_reg - A_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 16'd0;
            B_reg <= 16'd0;
        end else begin
            if (ldA)       A_reg <= A_in;
            else if (subA) A_reg <= A_minus_B;

            if (ldB)       B_reg <= B_in;
            else if (subB) B_reg <= B_minus_A;
        end
    end

    assign A_out = A_reg;
    assign B_out = B_reg;
    assign A_eq_B = (A_reg == B_reg);
    assign A_gt_B = (A_reg > B_reg);
    assign A_lt_B = (A_reg < B_reg);

endmodule

module gcd_ctrl(
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire       A_eq_B,
    input  wire       A_gt_B,
    input  wire       A_lt_B,
    input  wire [15:0] B_val,
    output reg        ldA,
    output reg        ldB,
    output reg        subA,
    output reg        subB,
    output reg        done
);
    // states in the form of parameter
    parameter IDLE    = 3'b000;
    parameter LOAD    = 3'b001;
    parameter COMPARE = 3'b010;
    parameter DONE_ST = 3'b011;

    reg [2:0] state, next_state;

    // Next-state + output logic
    always @(*) 
    begin
        // default signals
        ldA = 0; ldB = 0; subA = 0; subB = 0; done = 0;
        next_state = state;

        case (state)
            IDLE: 
            begin
                if (start) next_state = LOAD;
            end

            LOAD: 
            begin
                ldA = 1; ldB = 1;
                next_state = COMPARE;
            end

            COMPARE:
             begin
                if (B_val == 16'd0)
                 begin
                    next_state = DONE_ST;
                end 
                else if (A_eq_B)
                 begin
                    next_state = DONE_ST;
                end 
                else if (A_gt_B)
                 begin
                    subA = 1;
                    next_state = COMPARE;
                end 
                else if (A_lt_B)
                 begin
                    subB = 1;
                    next_state = COMPARE;
                end
            end

            DONE_ST:
             begin
                done = 1;
                if (!start) next_state = IDLE;
            end
        endcase
    end

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else state <= next_state;
    end

endmodule


// Top module
module gcd_top(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [15:0] A_in,
    input  wire [15:0] B_in,
    output wire        done,
    output wire [15:0] result
);
    wire ldA, ldB, subA, subB;
    wire [15:0] A_out, B_out;
    wire A_eq_B, A_gt_B, A_lt_B;

    gcd_dp DP (.clk(clk), .rst(rst), .ldA(ldA), .ldB(ldB), .subA(subA), .subB(subB), .A_in(A_in), .B_in(B_in), .A_out(A_out), .B_out(B_out),.A_eq_B(A_eq_B), .A_gt_B(A_gt_B), .A_lt_B(A_lt_B) );

    gcd_ctrl CTRL (.clk(clk), .rst(rst), .start(start), .A_eq_B(A_eq_B), .A_gt_B(A_gt_B), .A_lt_B(A_lt_B),.B_val(B_out),.ldA(ldA), .ldB(ldB), .subA(subA), .subB(subB), .done(done));

    assign result = A_out;

endmodule