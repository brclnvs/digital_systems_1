module proj5_bruno_5 (
    input  logic        clk,
    input  logic        reset,
    input  logic        INI,
    input  logic [15:0] A,
    input  logic [7:0]  B,
    output logic        OCUP,
    output logic        P,
    output logic [15:0] R,
    output logic [7:0]  REM
);

    typedef enum logic [2:0] {
        S_IDLE, S_LOAD, S_COMP, S_CALC, S_OUTPUT
    } state_t;

    state_t current_state, next_state;

    logic [15:0] A_reg;
    logic [7:0]  B_reg;
    logic [15:0] count;
    
    logic [15:0] sub_out;
    logic        a_reg_less_than_b_reg;

    assign sub_out = A_reg - {8'b0, B_reg};
    assign a_reg_less_than_b_reg = A_reg < {8'b0, B_reg};

    always_ff @(posedge clk, negedge reset) begin
        if (!reset) begin
            current_state <= S_IDLE;
            A_reg <= 16'd0;
            B_reg <= 8'd0;
            count <= 16'd0;
            R     <= 16'd0;
            REM   <= 8'd0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                S_LOAD: begin
                    A_reg <= A;
                    B_reg <= B;
                    count <= 16'd0;
                end
                S_CALC: begin
                    A_reg <= sub_out;
                    count <= count + 1;
                end
                S_OUTPUT: begin
                    R <= count;
                    REM <= A_reg[7:0];
                end
                default: begin
                end
            endcase

            if (INI) begin
                R <= 16'd0;
                REM <= 8'd0;
            end
        end
    end
    
    always_comb begin
        next_state = current_state;
        P = 1'b0;
        OCUP = 1'b0;

        case (current_state)
            S_IDLE:   begin OCUP = 1'b0; if (INI) next_state = S_LOAD; end
            S_LOAD:   begin OCUP = 1'b1; next_state = S_COMP; end
            S_COMP:   begin OCUP = 1'b1; if (a_reg_less_than_b_reg) next_state = S_OUTPUT; else next_state = S_CALC; end
            S_CALC:   begin OCUP = 1'b1; next_state = S_COMP; end
            S_OUTPUT: begin OCUP = 1'b0; P = 1'b1; next_state = S_IDLE; end
            default:  next_state = S_IDLE;
        endcase
    end
endmodule
