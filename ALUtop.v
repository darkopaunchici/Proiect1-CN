// Operations: Adunare, Scadere, Multiplicare Booth Radix-4, Diviziune Non-restoring

module alu_top(
    input wire clk,               
    input wire reset,              
    input wire [7:0] operand_a,    
    input wire [7:0] operand_b,    
    input wire [1:0] operation,    
    input wire start,              
    output wire [15:0] result,     
    output wire ready,             
    output wire overflow,         
    output wire zero              
);

    wire [15:0] add_result;
    wire [15:0] sub_result;
    wire [15:0] mul_result;
    wire [15:0] div_result;
    wire add_overflow, sub_overflow, mul_overflow, div_overflow;
    wire add_zero, sub_zero, mul_zero, div_zero;
    wire mul_ready, div_ready;
    
    // Semnale de control
    wire select_add, select_sub, select_mul, select_div;
    wire start_mul, start_div;
    
    control_unit ctrl_unit (
        .clk(clk),
        .reset(reset),
        .operation(operation),
        .start(start),
        .mul_ready(mul_ready),
        .div_ready(div_ready),
        .select_add(select_add),
        .select_sub(select_sub),
        .select_mul(select_mul),
        .select_div(select_div),
        .start_mul(start_mul),
        .start_div(start_div),
        .ready(ready)
    );
    
    adder_8bit adder (
        .a(operand_a),
        .b(operand_b),
        .sum(add_result[7:0]),
        .overflow(add_overflow)
    );
    assign add_result[15:8] = {8{add_result[7]}};  
    assign add_zero = (add_result[7:0] == 8'd0);
    
    subtractor_8bit subtractor (
        .a(operand_a),
        .b(operand_b),
        .difference(sub_result[7:0]),
        .overflow(sub_overflow)
    );
    assign sub_result[15:8] = {8{sub_result[7]}}; 
    assign sub_zero = (sub_result[7:0] == 8'd0);
    
    booth_radix4_multiplier multiplier (
        .clk(clk),
        .reset(reset),
        .start(start_mul),
        .multiplicand(operand_a),
        .multiplier(operand_b),
        .product(mul_result),
        .ready(mul_ready),
        .overflow(mul_overflow)
    );
    assign mul_zero = (mul_result == 16'd0);
    
    nonrestoring_divider divider (
        .clk(clk),
        .reset(reset),
        .start(start_div),
        .dividend(operand_a),
        .divisor(operand_b),
        .quotient(div_result[7:0]),
        .remainder(div_result[15:8]),
        .ready(div_ready),
        .overflow(div_overflow)
    );
    assign div_zero = (div_result[7:0] == 8'd0);
    
    mux_4to1_16bit result_mux (
        .a(add_result),
        .b(sub_result),
        .c(mul_result),
        .d(div_result),
        .sel({select_div, select_mul, select_sub, select_add}),
        .out(result)
    );
    
    mux_4to1_1bit overflow_mux (
        .a(add_overflow),
        .b(sub_overflow),
        .c(mul_overflow),
        .d(div_overflow),
        .sel({select_div, select_mul, select_sub, select_add}),
        .out(overflow)
    );
    
    mux_4to1_1bit zero_mux (
        .a(add_zero),
        .b(sub_zero),
        .c(mul_zero),
        .d(div_zero),
        .sel({select_div, select_mul, select_sub, select_add}),
        .out(zero)
    );

endmodule