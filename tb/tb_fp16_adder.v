//Testbench for IEEE-754 Half Precision Floating Point Adder
`timescale 1ns / 1ps

module tb_fp16_adder;

// Inputs
reg [15:0] a;
reg [15:0] b;

// Outputs
wire [15:0] result;

// Instantiate the Unit Under Test (UUT)
fp16_adder uut (
    .a(a),
    .b(b),
    .out(result)
);

// Test vectors and expected results
reg [15:0] test_a [0:19];
reg [15:0] test_b [0:19];
reg [15:0] expected [0:19];
reg [255:0] test_name [0:19];

// IEEE-754 half precision format helper function to display floating point numbers
function [15:0] ieee754_half_encode;
    input sign;
    input [4:0] exponent;
    input [9:0] mantissa;
    begin
        ieee754_half_encode = {sign, exponent, mantissa};
    end
endfunction

// Function to create IEEE-754 half precision number from common values
function [15:0] float_to_ieee754_half;
    input real value;
    begin
        if (value == 0.0) begin
            float_to_ieee754_half = 16'h0000;      // +0.0
        end else if (value == 1.0) begin
            float_to_ieee754_half = 16'h3C00;      // 1.0
        end else if (value == 2.0) begin
            float_to_ieee754_half = 16'h4000;      // 2.0
        end else if (value == 3.0) begin
            float_to_ieee754_half = 16'h4200;      // 3.0
        end else if (value == -1.0) begin
            float_to_ieee754_half = 16'hBC00;      // -1.0
        end else if (value == -2.0) begin
            float_to_ieee754_half = 16'hC000;      // -2.0
        end else if (value == -3.0) begin
            float_to_ieee754_half = 16'hC200;      // -3.0
        end else if (value == 0.5) begin
            float_to_ieee754_half = 16'h3800;      // 0.5
        end else begin
            float_to_ieee754_half = 16'h0000;      // Default to zero for unsupported values
        end
    end
endfunction

// Initialize test vectors
initial begin
    // Test case 0: Simple addition (1.0 + 1.0 = 2.0)
    test_a[0] = 16'h3C00;        // 1.0
    test_b[0] = 16'h3C00;        // 1.0
    expected[0] = 16'h4000;      // 2.0
    test_name[0] = "1.0 + 1.0 = 2.0";
    
    // Test case 1: Addition with different magnitudes (2.0 + 1.0 = 3.0)
    test_a[1] = 16'h4000;        // 2.0
    test_b[1] = 16'h3C00;        // 1.0
    expected[1] = 16'h4200;      // 3.0
    test_name[1] = "2.0 + 1.0 = 3.0";
    
    // Test case 2: Subtraction (1.0 + (-1.0) = 0.0)
    test_a[2] = 16'h3C00;        // 1.0
    test_b[2] = 16'hBC00;        // -1.0
    expected[2] = 16'h0000;      // 0.0
    test_name[2] = "1.0 + (-1.0) = 0.0";
    
    // Test case 3: Addition with zero (+1.0 + 0.0 = 1.0)
    test_a[3] = 16'h3C00;        // 1.0
    test_b[3] = 16'h0000;        // +0.0
    expected[3] = 16'h3C00;      // 1.0
    test_name[3] = "1.0 + 0.0 = 1.0";
    
    // Test case 4: Addition with negative zero (1.0 + (-0.0) = 1.0)
    test_a[4] = 16'h3C00;        // 1.0
    test_b[4] = 16'h8000;        // -0.0
    expected[4] = 16'h3C00;      // 1.0
    test_name[4] = "1.0 + (-0.0) = 1.0";
    
    // Test case 5: Zero + Zero = Zero
    test_a[5] = 16'h0000;        // +0.0
    test_b[5] = 16'h0000;        // +0.0
    expected[5] = 16'h0000;      // +0.0
    test_name[5] = "0.0 + 0.0 = 0.0";
    
    // Test case 6: Positive infinity + finite number = positive infinity
    test_a[6] = 16'h7C00;        // +Infinity
    test_b[6] = 16'h3C00;        // 1.0
    expected[6] = 16'h7C00;      // +Infinity
    test_name[6] = "+Inf + 1.0 = +Inf";
    
    // Test case 7: Negative infinity + finite number = negative infinity
    test_a[7] = 16'hFC00;        // -Infinity
    test_b[7] = 16'h3C00;        // 1.0
    expected[7] = 16'hFC00;      // -Infinity
    test_name[7] = "-Inf + 1.0 = -Inf";
    
    // Test case 8: Positive infinity + positive infinity = positive infinity
    test_a[8] = 16'h7C00;        // +Infinity
    test_b[8] = 16'h7C00;        // +Infinity
    expected[8] = 16'h7C00;      // +Infinity
    test_name[8] = "+Inf + +Inf = +Inf";
    
    // Test case 9: Positive infinity + negative infinity = NaN
    test_a[9] = 16'h7C00;        // +Infinity
    test_b[9] = 16'hFC00;        // -Infinity
    expected[9] = 16'h7E00;      // NaN (half precision)
    test_name[9] = "+Inf + (-Inf) = NaN";
    
    // Test case 10: NaN + any number = NaN
    test_a[10] = 16'h7E00;       // NaN
    test_b[10] = 16'h3C00;       // 1.0
    expected[10] = 16'h7E00;     // NaN
    test_name[10] = "NaN + 1.0 = NaN";
    
    // Test case 11: Any number + NaN = NaN
    test_a[11] = 16'h3C00;       // 1.0
    test_b[11] = 16'h7E00;       // NaN
    expected[11] = 16'h7E00;     // NaN
    test_name[11] = "1.0 + NaN = NaN";
    
    // Test case 12: Small number addition (0.5 + 0.5 = 1.0)
    test_a[12] = 16'h3800;       // 0.5
    test_b[12] = 16'h3800;       // 0.5
    expected[12] = 16'h3C00;     // 1.0
    test_name[12] = "0.5 + 0.5 = 1.0";
    
    // Test case 13: Very large numbers (near infinity)
    test_a[13] = 16'h7BFF;       // Largest normal positive number (65504)
    test_b[13] = 16'h7BFF;       // Largest normal positive number
    expected[13] = 16'h7C00;     // Should overflow to +Infinity
    test_name[13] = "Max + Max = +Inf (overflow)";
    
    // Test case 14: Denormalized number + normal number
    test_a[14] = 16'h0001;       // Smallest positive denormalized number
    test_b[14] = 16'h3C00;       // 1.0
    expected[14] = 16'h3C00;     // ~1.0 (denormalized number is negligible)
    test_name[14] = "Denorm + 1.0 ≈ 1.0";
    
    // Test case 15: Negative numbers
    test_a[15] = 16'hBC00;       // -1.0
    test_b[15] = 16'hBC00;       // -1.0
    expected[15] = 16'hC000;     // -2.0
    test_name[15] = "-1.0 + (-1.0) = -2.0";
    
    // Test case 16: Mixed signs with different magnitudes
    test_a[16] = 16'h4200;       // 3.0
    test_b[16] = 16'hBC00;       // -1.0
    expected[16] = 16'h4000;     // 2.0
    test_name[16] = "3.0 + (-1.0) = 2.0";
    
    // // Test case 17: Very small result
    // test_a[17] = 16'h3C00;       // 1.0
    // test_b[17] = 16'hBBFF;       // Very close to -1.0
    // expected[17] = 16'h1400;     // Very small positive number
    // test_name[17] = "1.0 - 0.999 ≈ small";
    
    // Test case 18: Equal magnitude, opposite signs (should be exactly zero)
    test_a[18] = 16'h4200;       // 3.0
    test_b[18] = 16'hC200;       // -3.0
    expected[18] = 16'h0000;     // 0.0
    test_name[18] = "3.0 + (-3.0) = 0.0";
    
    // Test case 19: Addition resulting in denormalized number
    test_a[19] = 16'h0400;       // Smallest normal positive number
    test_b[19] = 16'h8400;       // Smallest normal negative number
    expected[19] = 16'h0000;     // Should be zero
    test_name[19] = "SmallNorm + (-SmallNorm) = 0";
end

// Test execution
integer i;
integer pass_count;
integer fail_count;

initial begin
    // Initialize
    pass_count = 0;
    fail_count = 0;
    
    $display("Starting IEEE-754 Half Precision Floating Point Adder Tests");
    $display("================================================================");
    
    // Run all test cases
    for (i = 0; i < 20; i = i + 1) begin
        // Apply inputs
        a = test_a[i];
        b = test_b[i];
        
        // Wait for a short time for combinational logic to settle
        #1;
        
        // Check result
        $display("Test %0d: %s", i, test_name[i]);
        $display("  Input A:  0x%h", a);
        $display("  Input B:  0x%h", b);
        $display("  Expected: 0x%h", expected[i]);
        $display("  Got:      0x%h", result);
        
        // For NaN comparisons, check if both are NaN (any NaN representation is valid)
        if ((expected[i][14:10] == 5'h1F && expected[i][9:0] != 10'h0) && 
            (result[14:10] == 5'h1F && result[9:0] != 10'h0)) begin
            $display("  PASS (Both are NaN)");
            pass_count = pass_count + 1;
        end else if (result == expected[i]) begin
            $display("  PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL");
            fail_count = fail_count + 1;
        end
        $display("");
    end
    
    // Summary
    $display("================================================================");
    $display("Test Summary:");
    $display("  Total Tests: %0d", pass_count + fail_count);
    $display("  Passed:      %0d", pass_count);
    $display("  Failed:      %0d", fail_count);
    
    if (fail_count == 0) begin
        $display("  ALL TESTS PASSED!");
    end else begin
        $display("  Some tests failed. Please check the implementation.");
    end
    
    $display("================================================================");
    
    // End simulation
    #100;
    $finish;
end

// Optional: Generate VCD file for waveform viewing
initial begin
    $dumpfile("tb_fp16_adder.vcd");
    $dumpvars(0, tb_fp16_adder);
end

endmodule