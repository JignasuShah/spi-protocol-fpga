module spi_slave (
    input            clk,
    input            sclk,
    input            rst,
    input            mosi,  
    input            cs_in,
    output reg       miso,
    output reg       rx_valid,
    output reg [7:0] rx_out
); 

    reg       state_reg, next_state; 
    reg       sclk_delayed; 
    reg       cs; 
    reg [2:0] bit_counter; 
    reg [7:0] shift_reg; 

    localparam IDLE = 1'b0; 
    localparam IN_STREAM = 1'b1; 

    always @(posedge clk) begin
        
        if (rst) begin
            state_reg <= IDLE; 
            bit_counter <= 3'b0; 
            sclk_delayed <= 1'b0; 
        end
        else begin 
            sclk_delayed <= sclk; 
            cs <= cs_in; 
            state_reg <= next_state; 
            if (state_reg == IDLE) begin
                bit_counter <= 3'b0; 
                rx_valid <= 1'b1; 
                rx_out <= shift_reg; 
            end

            else if (state_reg == IN_STREAM) begin
                rx_valid <= 1'b0; 
                rx_out <= 8'b0; 
                if (sclk && ~sclk_delayed) begin
                    shift_reg <= {shift_reg[6:0], mosi}; 
                    bit_counter <= bit_counter + 1; 
                end
            end
        end
    end

    always @(*) begin
        case (state_reg) 
            IDLE: begin
                if (~cs) begin
                    next_state = IN_STREAM; 
                end
                else begin
                    next_state = IDLE; 
                end
            end

            IN_STREAM: begin
                if (bit_counter == 3'd7 && sclk && ~sclk_delayed) begin
                    next_state = IDLE; 
                end
                else begin
                    next_state = IN_STREAM; 
                end
            end
        endcase
        
        if (cs) begin
            miso = 1'b0; 
        end
        else begin
            miso = shift_reg[7]; 
        end
    end


endmodule 