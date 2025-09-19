`timescale 1ns/1ps
//======================================================================
// Project      : Floating Point Unit - Adder
// File         : fpu_adder_parameterized.v
// Author       : P Kaarthick Natesh
// Affiliation  : IIITDM Kancheepuram
// Email        : ec22b1004@iiitdm.ac.in
//
// Created On   : 19-09-2025
// Last Edited  : 19-09-2025
// Version      : v1.0
//
// Description: 
//   Parameterized Floating Point Adder supporting IEEE 754 format with 
//   configurable total width, exponent width, and mantissa width. Handles 
//   normalized, denormalized, zero, infinity, and NaN cases. Supports both 
//   addition and subtraction based on operand signs.
//
// IEEE 754 Format Support:
//   ┌──────────────┬─────────────┬─────────────┬──────────────┬──────────────┐
//   │ Format       │ Total Width │ Exp Width   │ Mant Width   │ Instantiation│
//   ├──────────────┼─────────────┼─────────────┼──────────────┼──────────────┤
//   │ binary16     │     16      │      5      │     10       │ Half Prec.   │
//   │ binary32     │     32      │      8      │     23       │ Single Prec. │
//   │ binary64     │     64      │     11      │     52       │ Double Prec. │
//   │ binary128    │    128      │     15      │    112       │ Quad Prec.   │
//   │ binary256    │    256      │     19      │    236       │ Octo Prec.   │
//   └──────────────┴─────────────┴─────────────┴──────────────┴──────────────┘
//
// Parameters:
//   TOTAL_WIDTH  - Total bit width of the floating point number
//   EXP_WIDTH    - Bit width of the exponent field
//   MANT_WIDTH   - Bit width of the mantissa field
//
// Ports:
//   input  [TOTAL_WIDTH-1:0] a   - First floating point operand
//   input  [TOTAL_WIDTH-1:0] b   - Second floating point operand
//   output reg [TOTAL_WIDTH-1:0] out - Result of floating point addition
//
// Features:
//   - Handles special cases: zero, infinity, NaN, denormalized numbers
//   - Aligns exponents and shifts mantissas for correct addition/subtraction
//   - Normalizes result and manages overflow/underflow
//   - Parameterized for easy adaptation to different floating point formats
//   - No rounding implemented; truncation used
//
// Notes        : 
//   - All three parameters (TOTAL_WIDTH, EXP_WIDTH, MANT_WIDTH) must be specified
//   - TOTAL_WIDTH must equal (1 + EXP_WIDTH + MANT_WIDTH)
//   - Assumes normalized inputs; handles denormalized numbers in computation
//   - Rounding is not implemented (truncation used)
//   - Supports all IEEE 754 binary interchange formats
//
// License      : MIT
// Tool Version : Icarus Verilog 0.11.0, Vivado 2025.1, Xcelium
// Target Tech  : FPGA - Zynq-7000, ASIC - GPDK45
//======================================================================

module fpu_adder_parameterized #(
    parameter TOTAL_WIDTH,    
    parameter EXP_WIDTH,        
    parameter MANT_WIDTH     
)(
    input [TOTAL_WIDTH-1:0] a,
    input [TOTAL_WIDTH-1:0] b,
    output reg [TOTAL_WIDTH-1:0] out
);

// Local parameters for bit positions and constants
localparam SIGN_POS = TOTAL_WIDTH - 1;
localparam EXP_POS_HIGH = TOTAL_WIDTH - 2;
localparam EXP_POS_LOW = MANT_WIDTH;
localparam MANT_POS_HIGH = MANT_WIDTH - 1;
localparam MANT_POS_LOW = 0;
localparam EXP_BIAS = (1 << (EXP_WIDTH - 1)) - 1;
localparam EXP_MAX = (1 << EXP_WIDTH) - 1;
localparam MANT_FULL_WIDTH = MANT_WIDTH + 1;      // Mantissa with hidden bit
localparam MANT_SHIFTED_WIDTH = MANT_FULL_WIDTH + 1; // For alignment and carry
localparam SUM_WIDTH = MANT_SHIFTED_WIDTH + 1;    // For sum result

// Split input operands into sign, exponent, and mantissa
wire sign_a, sign_b;
wire [EXP_WIDTH-1:0] exp_a, exp_b;
wire [MANT_WIDTH-1:0] mant_a, mant_b;

assign sign_a = a[SIGN_POS];
assign exp_a = a[EXP_POS_HIGH:EXP_POS_LOW];
assign mant_a = a[MANT_POS_HIGH:MANT_POS_LOW];

assign sign_b = b[SIGN_POS];
assign exp_b = b[EXP_POS_HIGH:EXP_POS_LOW];
assign mant_b = b[MANT_POS_HIGH:MANT_POS_LOW];

// Detect special cases for both operands
wire a_is_zero = (exp_a == {EXP_WIDTH{1'b0}}) && (mant_a == {MANT_WIDTH{1'b0}});
wire b_is_zero = (exp_b == {EXP_WIDTH{1'b0}}) && (mant_b == {MANT_WIDTH{1'b0}});
wire a_is_inf = (exp_a == {EXP_WIDTH{1'b1}}) && (mant_a == {MANT_WIDTH{1'b0}});
wire b_is_inf = (exp_b == {EXP_WIDTH{1'b1}}) && (mant_b == {MANT_WIDTH{1'b0}});
wire a_is_nan = (exp_a == {EXP_WIDTH{1'b1}}) && (mant_a != {MANT_WIDTH{1'b0}});
wire b_is_nan = (exp_b == {EXP_WIDTH{1'b1}}) && (mant_b != {MANT_WIDTH{1'b0}});
wire a_is_denorm = (exp_a == {EXP_WIDTH{1'b0}}) && (mant_a != {MANT_WIDTH{1'b0}});
wire b_is_denorm = (exp_b == {EXP_WIDTH{1'b0}}) && (mant_b != {MANT_WIDTH{1'b0}});

// Internal registers for computation
reg [EXP_WIDTH-1:0] exp_diff;
reg [EXP_WIDTH-1:0] result_exp;
reg [MANT_FULL_WIDTH-1:0] mant_a_full, mant_b_full;
reg [MANT_SHIFTED_WIDTH-1:0] mant_a_shifted, mant_b_shifted;
reg [SUM_WIDTH-1:0] sum_result;
reg result_sign;
reg [MANT_WIDTH-1:0] result_mant;
reg add_sub; // 0: add, 1: subtract

always @(*) begin
    // Handle special cases first

    // If either operand is NaN, result is NaN
    if (a_is_nan || b_is_nan) begin
        out = {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {MANT_WIDTH-1{1'b0}}}; // NaN
    end
    // Both operands are infinity
    else if (a_is_inf && b_is_inf) begin
        if (sign_a == sign_b) begin
            out = {sign_a, {EXP_WIDTH{1'b1}}, {MANT_WIDTH{1'b0}}}; // Same sign infinity
        end else begin
            out = {1'b0, {EXP_WIDTH{1'b1}}, 1'b1, {MANT_WIDTH-1{1'b0}}}; // NaN (inf - inf)
        end
    end
    // Only a is infinity
    else if (a_is_inf) begin
        out = a;
    end
    // Only b is infinity
    else if (b_is_inf) begin
        out = b;
    end
    // Both operands are zero
    else if (a_is_zero && b_is_zero) begin
        if (sign_a == sign_b) begin
            out = {sign_a, {TOTAL_WIDTH-1{1'b0}}}; // Preserve sign
        end else begin
            out = {TOTAL_WIDTH{1'b0}}; // +0
        end
    end
    // Only a is zero
    else if (a_is_zero) begin
        out = b;
    end
    // Only b is zero
    else if (b_is_zero) begin
        out = a;
    end
    else begin
        // Handle denormalized numbers by setting hidden bit
        mant_a_full = a_is_denorm ? {1'b0, mant_a} : {1'b1, mant_a};
        mant_b_full = b_is_denorm ? {1'b0, mant_b} : {1'b1, mant_b};
        
        // Determine operation: add if signs are same, subtract if different
        add_sub = sign_a ^ sign_b; // 0 for add, 1 for subtract
        
        // Align exponents: shift mantissa of smaller exponent
        if (exp_a > exp_b) begin
            result_exp = exp_a;
            exp_diff = exp_a - exp_b;
            mant_a_shifted = {mant_a_full, 1'b0}; // Extra bit for carry
            if (exp_diff >= MANT_SHIFTED_WIDTH) begin
                mant_b_shifted = {MANT_SHIFTED_WIDTH{1'b0}}; // Too small, becomes zero
            end else begin
                mant_b_shifted = {mant_b_full, 1'b0} >> exp_diff;
            end
        end else if (exp_b > exp_a) begin
            result_exp = exp_b;
            exp_diff = exp_b - exp_a;
            mant_b_shifted = {mant_b_full, 1'b0};
            if (exp_diff >= MANT_SHIFTED_WIDTH) begin
                mant_a_shifted = {MANT_SHIFTED_WIDTH{1'b0}};
            end else begin
                mant_a_shifted = {mant_a_full, 1'b0} >> exp_diff;
            end
        end else begin
            // Exponents are equal, no shift needed
            result_exp = exp_a;
            mant_a_shifted = {mant_a_full, 1'b0};
            mant_b_shifted = {mant_b_full, 1'b0};
        end
        
        if (add_sub == 0) begin
            // Addition
            sum_result = mant_a_shifted + mant_b_shifted;
            result_sign = sign_a; // Both have same sign
            
            // Check for overflow in mantissa (carry out)
            if (sum_result[SUM_WIDTH-1]) begin
                sum_result = sum_result >> 1;
                result_exp = result_exp + 1;
            end
        end else begin
            // Subtraction: subtract smaller from larger, set sign accordingly
            if ((exp_a > exp_b) || ((exp_a == exp_b) && (mant_a_full >= mant_b_full))) begin
                sum_result = mant_a_shifted - mant_b_shifted;
                result_sign = sign_a;
            end else begin
                sum_result = mant_b_shifted - mant_a_shifted;
                result_sign = sign_b;
            end
        end
        
        // Normalize the result
        if (sum_result == {SUM_WIDTH{1'b0}}) begin
            // Result is zero
            out = {TOTAL_WIDTH{1'b0}};
        end else begin
            // Find the leading 1 and normalize
            reg [EXP_WIDTH-1:0] shift_amount;
            reg [SUM_WIDTH-1:0] temp_sum;
            integer i;
            
            shift_amount = 0;
            temp_sum = sum_result;
            
            // If already normalized (leading 1 in correct position)
            if (sum_result[SUM_WIDTH-2]) begin
                // Extract mantissa bits
                result_mant = sum_result[SUM_WIDTH-3:SUM_WIDTH-2-MANT_WIDTH];
            end else begin
                // Find position of leading 1
                for (i = SUM_WIDTH-3; i >= 0; i = i - 1) begin
                    if (sum_result[i] && shift_amount == 0) begin
                        shift_amount = (SUM_WIDTH-2) - i;
                    end
                end
                // Shift left to normalize
                temp_sum = sum_result << shift_amount;
                result_mant = temp_sum[SUM_WIDTH-3:SUM_WIDTH-2-MANT_WIDTH];
                result_exp = result_exp - shift_amount;
            end
            
            // Handle exponent overflow/underflow
            if (result_exp >= EXP_MAX) begin
                out = {result_sign, {EXP_WIDTH{1'b1}}, {MANT_WIDTH{1'b0}}}; // Infinity
            end else if (result_exp <= 0) begin
                out = {result_sign, {EXP_WIDTH{1'b0}}, result_mant}; // Denormalized or zero
            end else begin
                out = {result_sign, result_exp, result_mant}; // Normalized result
            end
        end
    end
end

endmodule