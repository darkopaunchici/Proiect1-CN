// Booth Radix-4 Multiplier
// Implements multiplication using Booth's Radix-4 algorithm

module booth_radix4_multiplier(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] multiplicand,
    input wire [7:0] multiplier,
    output reg [15:0] product,
    output reg ready,
    output reg overflow
);
    // State definitions
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE = 2'b10;
    
    // Internal registers and wires
    reg [1:0] state;
    reg [3:0] counter;          // Counter for iteration control
    reg [16:0] acc;             // Accumulator - 17 bits wide for sign extension
    reg [7:0] Q;                // Multiplier register
    reg Q_neg1;                 // Additional bit for Booth encoding
    reg [8:0] M;                // Multiplicand with extra bit for sign extension
    
    // Booth encoding wires
    wire [1:0] booth_sel;
    wire [8:0] booth_value;
    
    // Booth encoding selector (examine 2 bits + Q_neg1)
    assign booth_sel = {Q[1:0], Q_neg1};
    
    // Booth value generation
    booth_value_generator booth_gen(
        .sel(booth_sel),
        .M(M),
        .booth_value(booth_value)
    );
    
    // State machine and multiplication process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            counter <= 4'b0000;
            acc <= 17'b0;
            Q <= 8'b0;
            Q_neg1 <= 1'b0;
            M <= 9'b0;
            product <= 16'b0;
            ready <= 1'b0;
            overflow <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Initialize registers for multiplication
                        acc <= 17'b0;
                        Q <= multiplier;
                        Q_neg1 <= 1'b0;
                        M <= {multiplicand[7], multiplicand}; // Sign extend multiplicand
                        counter <= 4'd4;   // Need 4 iterations for Radix-4 (8 bit / 2)
                        state <= COMPUTE;
                        ready <= 1'b0;
                    end
                end
                
                COMPUTE: begin
                    // Shift and add based on Booth encoding
                    acc <= {acc[14:0], Q[7:6]};
                    Q <= {Q[5:0], Q_neg1, 1'b0};
                    Q_neg1 <= Q[0];
                    
                    // Add, subtract or do nothing based on booth selector
                    case (booth_sel)
                        3'b001, 3'b010: acc <= acc + M;         // +M (multiplier bits = 01 or 10)
                        3'b011: acc <= acc + {M, 1'b0};        // +2M (multiplier bits = 11)
                        3'b100: acc <= acc - {M, 1'b0};        // -2M (multiplier bits = 100)
                        3'b101, 3'b110: acc <= acc - M;         // -M (multiplier bits = 101 or 110)
                        default: acc <= acc;                   // No operation (multiplier bits = 000 or 111)
                    endcase
                    
                    // Decrement counter and check if done
                    counter <= counter - 1;
                    if (counter == 4'd1) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    // Form the final product
                    product <= {acc[16], acc[14:0]};
                    
                    // Check for overflow
                    // Overflow occurs if the product doesn't fit in 16 bits
                    overflow <= (acc[16:15] != 2'b00) && (acc[16:15] != 2'b11);
                    
                    ready <= 1'b1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule

// Booth Value Generator
// Determines the value to add/subtract based on Booth encoding
module booth_value_generator(
    input wire [2:0] sel,        // 3 bits: Q[i+1], Q[i], Q[i-1]
    input wire [8:0] M,          // Signed multiplicand with sign extension
    output reg [8:0] booth_value // Value to add/subtract
);
    always @(*) begin
        case (sel)
            3'b000, 3'b111: booth_value = 9'b0;         // 0
            3'b001, 3'b010: booth_value = M;            // +M
            3'b011:         booth_value = {M[7:0], 1'b0}; // +2M (shift left by 1)
            3'b100:         booth_value = {~M[7:0], 1'b0} + 1'b1; // -2M (2's complement of 2M)
            3'b101, 3'b110: booth_value = ~M + 1'b1;     // -M (2's complement)
            default:        booth_value = 9'b0;
        endcase
    end
endmodule