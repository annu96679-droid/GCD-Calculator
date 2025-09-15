`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2025 00:27:00
// Design Name: 
// Module Name: gcd
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

// data path for GCD

module gcd_dp(
    input clk, rst,
    input ldA, ldB, sel_in, sel1, sel2,
    input [15:0] data_in,
    output lt, gt, eq,
    output [15:0] A, B
);

    reg [15:0] A_reg, B_reg;
    wire [15:0] mux_in, mux_A, mux_B, sub_out;

    // Input multiplexer (choose data_in or subtract result)
    assign mux_in = (sel_in) ? data_in : sub_out;

    // Register A
    always @(posedge clk or posedge rst) begin
        if (rst)
            A_reg <= 0;
        else if (ldA)
            A_reg <= mux_in;
    end

    // Register B
    always @(posedge clk or posedge rst) begin
        if (rst)
            B_reg <= 0;
        else if (ldB)
            B_reg <= mux_in;
    end

    // Comparator
    assign lt = (A_reg < B_reg);
    assign gt = (A_reg > B_reg);
    assign eq = (A_reg == B_reg);

    // Subtractor inputs 
    assign mux_A = (sel1) ? A_reg : B_reg;
    assign mux_B = (sel2) ? B_reg : A_reg;

    assign sub_out = mux_A - mux_B;

    // internal registers
    assign A = A_reg;
    assign B = B_reg;

endmodule


// for control path

module gcd_cp(
    input clk, rst, start, lt, gt, eq,
    output reg ldA, ldB, sel_in, sel1, sel2, done
);

    reg [2:0] state, next_state;

    // State encoding
    parameter  IDLE   = 3'b000,
               LOAD_A = 3'b001,
               LOAD_B = 3'b010,
               COMP   = 3'b011,
               SUB    = 3'b100,
               DONE   = 3'b101;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (state)
            IDLE:   next_state = (start) ? LOAD_A : IDLE;
            LOAD_A: next_state = LOAD_B;
            LOAD_B: next_state = COMP;
            COMP:   if (eq)      next_state = DONE;
                    else          next_state = SUB;
            SUB:    next_state = COMP;
            DONE:   next_state = DONE;
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(*) 
    begin
        // default values
        ldA = 0; ldB = 0; sel_in = 0; sel1 = 0; sel2 = 0; done = 0;

        case (state)
            LOAD_A: 
            begin
                ldA = 1; sel_in = 1;   // load A from data_in
            end
            LOAD_B:
             begin
                ldB = 1; sel_in = 1;   // load B from data_in
            end
            SUB: 
            begin
                sel_in = 0;            // select subtractor output
                if (gt) 
                begin
                   ldA = 1; sel1 = 1; sel2 = 0; 
                end  // A = A - B
                else if (lt) 
                begin 
                   ldB = 1; sel1 = 0; sel2 = 1;
                 end // B = B - A
            end
            DONE: begin
                done = 1;
            end
        endcase
    end

endmodule


//top module

module gcd_top(
    input clk, rst, start,
    input [15:0] data_in,
    output done,
    output [15:0] A, B
);

    wire ldA, ldB, sel_in, sel1, sel2;
    wire lt, gt, eq;

    gcd_dp DP(.clk(clk), .rst(rst), .ldA(ldA), .ldB(ldB), .sel_in(sel_in), .sel1(sel1), .sel2(sel2), .data_in(data_in), .lt(lt), .gt(gt), .eq(eq),  .A(A), .B(B));

    gcd_cp CP(.clk(clk), .rst(rst), .start(start), .lt(lt), .gt(gt), .eq(eq), .ldA(ldA), .ldB(ldB), .sel_in(sel_in), .sel1(sel1), .sel2(sel2), .done(done));

endmodule
