// Control Unit for 8-bit ALU
// Manages operation selection and timing

module control_unit(
    input wire clk,
    input wire reset,
    input wire [1:0] operation,    // 00=Add, 01=Sub, 10=Mul, 11=Div
    input wire start,              // Start signal for multi-cycle operations
    input wire mul_ready,          // Multiplication complete signal
    input wire div_ready,          // Division complete signal
    output reg select_add,         // Select adder output
    output reg select_sub,         // Select subtractor output
    output reg select_mul,         // Select multiplier output
    output reg select_div,         // Select divider output
    output reg start_mul,          // Start signal for multiplier
    output reg start_div,          // Start signal for divider
    output reg ready               // ALU operation complete signal
);

    // State definitions
    localparam IDLE = 2'b00;
    localparam COMPUTING = 2'b01;
    localparam DONE = 2'b10;
    
    // Operation codes
    localparam ADD = 2'b00;
    localparam SUB = 2'b01;
    localparam MUL = 2'b10;
    localparam DIV = 2'b11;
    
    // State registers
    reg [1:0] current_state, next_state;
    reg [1:0] current_op;
    
    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            current_op <= ADD;
        end
        else begin
            current_state <= next_state;
            if (current_state == IDLE && start)
                current_op <= operation;
        end
    end
    
    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start) begin
                    if (operation == ADD || operation == SUB)
                        next_state = DONE;    // Single-cycle operations
                    else
                        next_state = COMPUTING;  // Multi-cycle operations
                end
                else
                    next_state = IDLE;
            end
            
            COMPUTING: begin
                if ((current_op == MUL && mul_ready) || 
                    (current_op == DIV && div_ready))
                    next_state = DONE;
                else
                    next_state = COMPUTING;
            end
            
            DONE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output logic
    always @(*) begin
        // Default values
        select_add = 1'b0;
        select_sub = 1'b0;
        select_mul = 1'b0;
        select_div = 1'b0;
        start_mul = 1'b0;
        start_div = 1'b0;
        ready = 1'b0;
        
        case (current_state)
            IDLE: begin
                // Initialize control signals for appropriate operation
                case (operation)
                    ADD: select_add = 1'b1;
                    SUB: select_sub = 1'b1;
                    MUL: select_mul = 1'b1;
                    DIV: select_div = 1'b1;
                endcase
                
                // Immediate completion for single-cycle operations
                if (operation == ADD || operation == SUB)
                    ready = start;
                    
                // Start signals for multi-cycle operations
                start_mul = (operation == MUL) && start;
                start_div = (operation == DIV) && start;
            end
            
            COMPUTING: begin
                // Select the appropriate operation
                case (current_op)
                    MUL: begin
                        select_mul = 1'b1;
                        ready = mul_ready;
                    end
                    DIV: begin
                        select_div = 1'b1;
                        ready = div_ready;
                    end
                endcase
            end
            
            DONE: begin
                // Maintain selection of appropriate operation
                case (current_op)
                    ADD: select_add = 1'b1;
                    SUB: select_sub = 1'b1;
                    MUL: select_mul = 1'b1;
                    DIV: select_div = 1'b1;
                endcase
                ready = 1'b1;
            end
        endcase
    end

endmodule