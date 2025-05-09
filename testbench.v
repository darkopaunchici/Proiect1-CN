// ALU Testbench
// Tests functionality of the 8-bit ALU

`timescale 1ns/1ps

module alu_tb();
    // Test signals
    reg clk;
    reg reset;
    reg [7:0] operand_a;
    reg [7:0] operand_b;
    reg [1:0] operation;
    reg start;
    wire [15:0] result;
    wire ready;
    wire overflow;
    wire zero;
    
    // DUT Instantiation
    alu_top dut (
        .clk(clk),
        .reset(reset),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .start(start),
        .result(result),
        .ready(ready),
        .overflow(overflow),
        .zero(zero)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end
    
    // Test vectors
    initial begin
        // Initialize signals
        reset = 1;
        operand_a = 8'h00;
        operand_b = 8'h00;
        operation = 2'b00;
        start = 0;
        
        // Apply reset
        #20 reset = 0;
        
        // Test 1: Addition (5 + 3 = 8)
        #10;
        $display("Test 1: Addition (5 + 3)");
        operand_a = 8'd5;
        operand_b = 8'd3;
        operation = 2'b00; // ADD
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result == 16'd8)
            $display("PASS: 5 + 3 = %d", result);
        else
            $display("FAIL: 5 + 3 = %d (expected 8)", result);
        #20;
        
        // Test 2: Subtraction (10 - 6 = 4)
        $display("Test 2: Subtraction (10 - 6)");
        operand_a = 8'd10;
        operand_b = 8'd6;
        operation = 2'b01; // SUB
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result == 16'd4)
            $display("PASS: 10 - 6 = %d", result);
        else
            $display("FAIL: 10 - 6 = %d (expected 4)", result);
        #20;
        
        // Test 3: Multiplication (7 * 6 = 42)
        $display("Test 3: Multiplication (7 * 6)");
        operand_a = 8'd7;
        operand_b = 8'd6;
        operation = 2'b10; // MUL
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result == 16'd42)
            $display("PASS: 7 * 6 = %d", result);
        else
            $display("FAIL: 7 * 6 = %d (expected 42)", result);
        #20;
        
        // Test 4: Division (20 / 4 = 5)
        $display("Test 4: Division (20 / 4)");
        operand_a = 8'd20;
        operand_b = 8'd4;
        operation = 2'b11; // DIV
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result[7:0] == 8'd5)
            $display("PASS: 20 / 4 = %d (quotient)", result[7:0]);
        else
            $display("FAIL: 20 / 4 = %d (expected quotient 5)", result[7:0]);
        #20;
        
        // Test 5: Negative number addition (-5 + 3 = -2)
        $display("Test 5: Negative Addition (-5 + 3)");
        operand_a = 8'b11111011; // -5 in 2's complement
        operand_b = 8'd3;
        operation = 2'b00; // ADD
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result[7:0] == 8'b11111110) // -2 in 2's complement
            $display("PASS: -5 + 3 = -2");
        else
            $display("FAIL: -5 + 3 = %b (expected -2)", result[7:0]);
        #20;
        
        // Test 6: Negative number multiplication (-4 * 3 = -12)
        $display("Test 6: Negative Multiplication (-4 * 3)");
        operand_a = 8'b11111100; // -4 in 2's complement
        operand_b = 8'd3;
        operation = 2'b10; // MUL
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result == 16'hFFF4) // -12 in 2's complement
            $display("PASS: -4 * 3 = -12");
        else
            $display("FAIL: -4 * 3 = %h (expected FFF4 or -12)", result);
        #20;
        
        // Test 7: Division with remainder (17 / 5 = 3 remainder 2)
        $display("Test 7: Division with remainder (17 / 5)");
        operand_a = 8'd17;
        operand_b = 8'd5;
        operation = 2'b11; // DIV
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (result[7:0] == 8'd3 && result[15:8] == 8'd2)
            $display("PASS: 17 / 5 = %d remainder %d", result[7:0], result[15:8]);
        else
            $display("FAIL: 17 / 5 = %d remainder %d (expected 3 remainder 2)", 
                     result[7:0], result[15:8]);
        #20;
        
        // Test 8: Division by zero (should set overflow flag)
        $display("Test 8: Division by zero");
        operand_a = 8'd25;
        operand_b = 8'd0;
        operation = 2'b11; // DIV
        start = 1;
        #10 start = 0;
        wait(ready);
        #5;
        if (overflow)
            $display("PASS: Division by zero detected (overflow flag set)");
        else
            $display("FAIL: Division by zero not detected (overflow flag not set)");
        #20;
        
        // End simulation
        $display("Simulation complete");
        #20 $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%t, A=%d, B=%d, Op=%b, Result=%d, Ready=%b, Overflow=%b, Zero=%b",
                 $time, operand_a, operand_b, operation, result, ready, overflow, zero);
    end
endmodule