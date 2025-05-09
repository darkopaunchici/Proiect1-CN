// Basic Arithmetic Units: Adder and Subtractor
// Structural implementation using full adders

module full_adder(
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);
    wire sum1, carry1, carry2;
    
    // Half adder 1
    xor xor1(sum1, a, b);
    and and1(carry1, a, b);
    
    // Half adder 2
    xor xor2(sum, sum1, cin);
    and and2(carry2, sum1, cin);
    
    // Final carry
    or or1(cout, carry1, carry2);
    
endmodule

module adder_8bit(
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] sum,
    output wire overflow
);
    wire [8:0] carry;  // Extra bit for overflow detection
    
    assign carry[0] = 1'b0;  // Initial carry-in is 0 for addition
    
    // Instantiate 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : adder_gen
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    // Overflow detection for signed numbers
    // Overflow occurs when adding two positive numbers results in a negative number
    // or adding two negative numbers results in a positive number
    assign overflow = (a[7] == b[7]) && (sum[7] != a[7]);
    
endmodule

// 8-bit Subtractor using 2's complement
module subtractor_8bit(
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] difference,
    output wire overflow
);
    wire [7:0] b_comp;
    wire [7:0] sum;
    wire [8:0] carry;
    
    // 2's complement of b (invert bits and add 1)
    assign b_comp = ~b;
    assign carry[0] = 1'b1;  // Initial carry-in is 1 for subtraction using 2's complement
    
    // Instantiate 8 full adders for a + (~b) + 1
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : subtractor_gen
            full_adder fa(
                .a(a[i]),
                .b(b_comp[i]),
                .cin(carry[i]),
                .sum(difference[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    
    // Overflow detection for signed numbers
    // Overflow occurs when subtracting a negative from positive results in negative
    // or subtracting positive from negative results in positive
    assign overflow = (a[7] != b[7]) && (difference[7] != a[7]);
    
endmodule
