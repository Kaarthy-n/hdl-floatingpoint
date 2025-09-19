`timescale 1ns/1ps
//`include "../common/fpu_adder_parameterized.v"

//======================================================================
// Project      : Floating Point Unit - Half Precision Adder Wrapper
// File         : fp16_adder.v
// Author       : P Kaarthick Natesh
// Affiliation  : IIITDM Kancheepuram
// Email        : ec22b1004@iiitdm.ac.in
//
// Created On   : 19-09-2025
// Last Edited  : 19-09-2025
// Version      : v1.0
//
// Description: 
//   Half precision (FP16/binary16) floating point adder wrapper module.
//   Instantiates the parameterized FPU adder with IEEE 754 binary16 format
//   parameters. Provides a clean interface for 16-bit floating point addition.
//
// IEEE 754 binary16 Format:
//   ┌─────────┬─────────────┬──────────────┐
//   │  Sign   │  Exponent   │   Mantissa   │
//   │ 1 bit   │   5 bits    │   10 bits    │
//   │ [15]    │  [14:10]    │   [9:0]      │
//   └─────────┴─────────────┴──────────────┘
//   Total: 16 bits, Bias: 15, Range: ±6.55×10⁴
//
// Parameters:
//   - Total Width: 16 bits
//   - Exponent Width: 5 bits  
//   - Mantissa Width: 10 bits
//   - Exponent Bias: 15
//
// Ports:
//   input  [15:0] a     - First FP16 operand
//   input  [15:0] b     - Second FP16 operand  
//   output [15:0] sum   - FP16 addition result
//
// Features:
//   - IEEE 754 binary16 compliant
//
// License      : MIT
// Tool Version : Icarus Verilog 0.11.0, Vivado 2025.1, Xcelium
// Target Tech  : FPGA - Zynq-7000, ASIC - GPDK45
//======================================================================

module fp16_adder (
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] out
);

//----------------------------------------------------------------------
// Local Parameters for FP16 Format
//----------------------------------------------------------------------
localparam TOTAL_WIDTH = 16;
localparam EXP_WIDTH   = 5;
localparam MANT_WIDTH  = 10;

//----------------------------------------------------------------------
// Parameterized FPU Adder Instantiation
//----------------------------------------------------------------------
fpu_adder_parameterized #(
    .TOTAL_WIDTH (TOTAL_WIDTH),
    .EXP_WIDTH   (EXP_WIDTH),
    .MANT_WIDTH  (MANT_WIDTH)
) core_adder (
    .a   (a),
    .b   (b), 
    .out (out)
);

endmodule