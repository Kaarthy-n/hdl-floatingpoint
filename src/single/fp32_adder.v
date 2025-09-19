`timescale 1ns/1ps
`include "../common/fpu_adder_parameterized.v"

//======================================================================
// Project      : Floating Point Unit - Single Precision Adder Wrapper
// File         : fp32_adder.v
// Author       : P Kaarthick Natesh
// Affiliation  : IIITDM Kancheepuram
// Email        : ec22b1004@iiitdm.ac.in
//
// Created On   : 19-09-2025
// Last Edited  : 19-09-2025
// Version      : v1.0
//
// Description: 
//   Single precision (FP32/binary32) floating point adder wrapper module.
//   Instantiates the parameterized FPU adder with IEEE 754 binary32 format
//   parameters. Provides a clean interface for 32-bit floating point addition.
//
// IEEE 754 binary32 Format:
//   ┌─────────┬─────────────┬──────────────────────────┐
//   │  Sign   │  Exponent   │        Mantissa          │
//   │ 1 bit   │   8 bits    │        23 bits           │
//   │ [31]    │  [30:23]    │        [22:0]            │
//   └─────────┴─────────────┴──────────────────────────┘
//   Total: 32 bits, Bias: 127, Range: ±3.40×10³⁸
//
// Parameters:
//   - Total Width: 32 bits
//   - Exponent Width: 8 bits
//   - Mantissa Width: 23 bits
//   - Exponent Bias: 127
//
// Ports:
//   input  [31:0] a     - First FP32 operand
//   input  [31:0] b     - Second FP32 operand
//   output [31:0] sum   - FP32 addition result
//
// Features:
//   - IEEE 754 binary32 compliant
//
// License      : MIT
// Tool Version : Icarus Verilog 0.11.0, Vivado 2025.1, Xcelium
// Target Tech  : FPGA - Zynq-7000, ASIC - GPDK45
//======================================================================

module fp32_adder (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] sum
);

//----------------------------------------------------------------------
// Local Parameters for FP32 Format
//----------------------------------------------------------------------
localparam TOTAL_WIDTH = 32;
localparam EXP_WIDTH   = 8;
localparam MANT_WIDTH  = 23;

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