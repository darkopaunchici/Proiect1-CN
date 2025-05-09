// Multiplexers for ALU
// Implements various multiplexers used in the ALU design

// 4-to-1 Multiplexer for 16-bit values
module mux_4to1_16bit(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [15:0] c,
    input wire [15:0] d,
    input wire [3:0] sel,  // One-hot encoding: {sel_d, sel_c, sel_b, sel_a}
    output wire [15:0] out
);
    // Structural implementation using AND-OR gates
    wire [15:0] out_a, out_b, out_c, out_d;
    
    // AND gates for each input with its select line
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : mux_16bit_gen
            and and_a(out_a[i], a[i], sel[0]);
            and and_b(out_b[i], b[i], sel[1]);
            and and_c(out_c[i], c[i], sel[2]);
            and and_d(out_d[i], d[i], sel[3]);
            
            // OR gate to combine all ANDed outputs
            or or_out(out[i], out_a[i], out_b[i], out_c[i], out_d[i]);
        end
    endgenerate
endmodule

// 4-to-1 Multiplexer for 1-bit values
module mux_4to1_1bit(
    input wire a,
    input wire b,
    input wire c,
    input wire d,
    input wire [3:0] sel,  // One-hot encoding: {sel_d, sel_c, sel_b, sel_a}
    output wire out
);
    // Structural implementation using AND-OR gates
    wire out_a, out_b, out_c, out_d;
    
    // AND gates for each input with its select line
    and and_a(out_a, a, sel[0]);
    and and_b(out_b, b, sel[1]);
    and and_c(out_c, c, sel[2]);
    and and_d(out_d, d, sel[3]);
    
    // OR gate to combine all ANDed outputs
    or or_out(out, out_a, out_b, out_c, out_d);
endmodule

// 2-to-1 Multiplexer for 8-bit values
module mux_2to1_8bit(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire sel,  // 0 selects a, 1 selects b
    output wire [7:0] out
);
    // Structural implementation using AND-OR gates
    wire [7:0] out_a, out_b;
    wire not_sel;
    
    // Invert select line for a
    not not_gate(not_sel, sel);
    
    // AND gates for each input with its select line
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mux_8bit_gen
            and and_a(out_a[i], a[i], not_sel);
            and and_b(out_b[i], b[i], sel);
            
            // OR gate to combine ANDed outputs
            or or_out(out[i], out_a[i], out_b[i]);
        end
    endgenerate
endmodule