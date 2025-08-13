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
    
    logic a_reg_load;
    logic b_reg_load;
    logic result_load;
    logic result_clear;
    logic count_clear;
    logic count_inc;
    logic mux_sel;

    logic [15:0] a_reg_input;
    logic [15:0] sub_out;
    logic        a_reg_less_than_b_reg;

    assign sub_out = A_reg - {8'b0, B_reg};
    assign a_reg_less_than_b_reg = A_reg < {8'b0, B_reg};
    assign a_reg_input = (mux_sel == 1'b0) ? A : sub_out;

    always_comb begin
        next_state   = current_state;
        P            = 1'b0;
        OCUP         = 1'b0;
        a_reg_load   = 1'b0;
        b_reg_load   = 1'b0;
        result_load  = 1'b0;
        result_clear = 1'b0;
        count_clear  = 1'b0;
        count_inc    = 1'b0;
        mux_sel      = 1'b0;

        case (current_state)
            S_IDLE: begin
                OCUP = 1'b0;
                if (INI) begin
                    next_state   = S_LOAD;
                    mux_sel      = 1'b0;
                    a_reg_load   = 1'b1;
                    b_reg_load   = 1'b1;
                    count_clear  = 1'b1;
                    result_clear = 1'b1;
                end
            end
            S_LOAD: begin
                OCUP        = 1'b1;
                next_state  = S_COMP;
            end
            S_COMP: begin
                OCUP = 1'b1;
                if (a_reg_less_than_b_reg) next_state = S_OUTPUT;
                else                       next_state = S_CALC;
            end
            S_CALC: begin
                OCUP       = 1'b1;
                mux_sel    = 1'b1;
                a_reg_load = 1'b1;
                count_inc  = 1'b1;
                next_state = S_COMP;
            end
            S_OUTPUT: begin
                OCUP         = 1'b0;
                P            = 1'b1;
                result_load  = 1'b1;
                next_state   = S_IDLE;
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
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

            if (a_reg_load)   A_reg <= a_reg_input;
            if (b_reg_load)   B_reg <= B;
            
            if (count_clear)  count <= 16'd0;
            else if (count_inc) count <= count + 1;
            
            if (result_clear) begin
                R <= 16'd0;
                REM <= 8'd0;
            end else if (result_load) begin
                R <= count;
                REM <= A_reg[7:0];
            end
        end
    end

endmodule
