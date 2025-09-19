`timescale 1ns/1ps
`include "../common/fpu_adder_parameterized.v"

//======================================================================
// Project      : Floating Point Unit - Double Precision Adder Wrapper
// File         : fp64_adder.v
// Author       : P Kaarthick Natesh
// Affiliation  : IIITDM Kancheepuram
// Email        : ec22b1004@iiitdm.ac.in
//
// Created On   : 19-09-2025
// Last Edited  : 19-09-2025
// Version      : v1.0
//
// Description: 
//   Double precision (FP64/binary64) floating point adder wrapper module.
//   Instantiates the parameterized FPU adder with IEEE 754 binary64 format
//   parameters. Provides a clean interface for 64-bit floating point addition.
//
// IEEE 754 binary64 Format:
//   ┌─────────┬─────────────┬──────────────────────────────────────────────────────┐
//   │  Sign   │  Exponent   │                    Mantissa                         │
//   │ 1 bit   │  11 bits    │                   52 bits                           │
//   │ [63]    │  [62:52]    │                   [51:0]                            │
//   └─────────┴─────────────┴──────────────────────────────────────────────────────┘
//   Total: 64 bits, Bias: 1023, Range: ±1.80×10³⁰⁸
//
// Parameters:
//   - Total Width: 64 bits
//   - Exponent Width: 11 bits
//   - Mantissa Width: 52 bits
//   - Exponent Bias: 1023
//
// Ports:
//   input  [63:0] a     - First FP64 operand
//   input  [63:0] b     - Second FP64 operand
//   output [63:0] sum   - FP64 addition result
//
// Features:
//   - IEEE 754 binary64 compliant
//
// License      : MIT
// Tool Version : Icarus Verilog 0.11.0, Vivado 2025.1, Xcelium
// Target Tech  : FPGA - Zynq-7000, ASIC - GPDK45
//======================================================================

module fp64_adder (
    input  [63:0] a,
    input  [63:0] b,
    output [63:0] sum
);

//----------------------------------------------------------------------
// Local Parameters for FP64 Format
//----------------------------------------------------------------------
localparam TOTAL_WIDTH = 64;
localparam EXP_WIDTH   = 11;
localparam MANT_WIDTH  = 52;

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
    .out (sum)
);

endmodule