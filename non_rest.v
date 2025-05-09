// Non-restoring Divider
// Implements division using the non-restoring algorithm

module nonrestoring_divider(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] dividend,    // 8-bit dividend
    input wire [7:0] divisor,     // 8-bit divisor
    output reg [7:0] quotient,    // 8-bit quotient
    output reg [7:0] remainder,   // 8-bit remainder
    output reg ready,             // Division complete signal
    output reg overflow           // Overflow/division by zero flag
);
    // State definitions
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam FINAL_RESTORE = 2'b10;
    localparam DONE = 2'b11;
    
    // Internal registers and wires
    reg [1:0] state;
    reg [3:0] counter;          // Counter for iteration control
    reg [8:0] partial_remainder; // One extra bit for sign information
    reg [7:0] A;                // Partial remainder register
    reg [7:0] Q;                // Quotient register
    reg [7:0] M;                // Divisor register
    
    // Sign extension
    wire [8:0] extended_divisor;
    assign extended_divisor = {1'b0, M};
    
    // Adder/Subtractor for partial remainder computation
    wire [8:0] add_result, sub_result;
    assign add_result = partial_remainder + extended_divisor;
    assign sub_result = partial_remainder - extended_divisor;
    
    // State machine and division process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            counter <= 4'b0;
            partial_remainder <= 9'b0;
            A <= 8'b0;
            Q <= 8'b0;
            M <= 8'b0;
            quotient <= 8'b0;
            remainder <= 8'b0;
            ready <= 1'b0;
            overflow <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Check for division by zero
                        if (divisor == 8'b0) begin
                            overflow <= 1'b1;
                            ready <= 1'b1;
                            state <= DONE;
                        end
                        else begin
                            // Initialize registers for division
                            partial_remainder <= 9'b0;
                            A <= 8'b0;
                            Q <= dividend;
                            M <= divisor;
                            counter <= 4'd8;  // Need 8 iterations for 8-bit division
                            overflow <= 1'b0;
                            ready <= 1'b0;
                            state <= COMPUTE;
                        end
                    end
                end
                
                COMPUTE: begin
                    // Left shift A,Q
                    partial_remainder <= {partial_remainder[7:0], Q[7]};
                    Q <= {Q[6:0], 1'b0};
                    
                    // Subtract or add based on the sign of partial remainder
                    if (partial_remainder[8] == 1'b0) begin
                        // If partial remainder is positive, subtract divisor
                        partial_remainder <= sub_result;
                    end
                    else begin
                        // If partial remainder is negative, add divisor
                        partial_remainder <= add_result;
                    end
                    
                    // Set quotient bit based on the sign of the new partial remainder
                    Q[0] <= (partial_remainder[8] == 1'b0) ? 1'b1 : 1'b0;
                    
                    // Decrement counter and check if done
                    counter <= counter - 1;
                    if (counter == 4'd1) begin
                        state <= FINAL_RESTORE;
                    end
                end
                
                FINAL_RESTORE: begin
                    // Restore remainder if it's negative
                    if (partial_remainder[8] == 1'b1) begin
                        partial_remainder <= add_result;
                    end
                    
                    state <= DONE;
                end
                
                DONE: begin
                    // Form the final quotient and remainder
                    quotient <= Q;
                    remainder <= partial_remainder[7:0];
                    
                    ready <= 1'b1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule