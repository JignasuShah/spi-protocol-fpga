module spi_master (
    input               clk,
    input               rst,
    input               miso,
    input               start,
    input [1:0]         cs_select, 
    input [7:0]         tx_data, 
    output              sclk, 
    output reg          mosi, 
    output reg          cs_one, 
    output reg          cs_two, 
    output reg          cs_three,
    output reg          cs_four, 
    output reg          rx_valid, 
    output reg [7:0]    rx_out
); 

    wire        sclk_postick, sclk_negtick;
    reg         cs_internal;   
    reg [1:0]   state_reg, next_state; 
    reg [2:0]   bit_counter, delay_counter; 
    reg [7:0]   tx_reg, rx_reg; 

    localparam IDLE = 2'b00; 
    localparam SETUP = 2'b01;
    localparam IN_STREAM = 2'b10;
    localparam HOLD = 2'b11; 

    localparam DELAY_CYCLES = 5; 

    clock_divider #(50000000, 1000000) clock_div (.clk(clk), .rst(rst), .sclk_enable(state_reg == IN_STREAM), .sclk(sclk), .sclk_postick(sclk_postick), .sclk_negtick(sclk_negtick));
    
    
    always @(posedge clk) begin
        if (rst) begin
            state_reg <= IDLE; 
        end
        else begin
            state_reg <= next_state; 

            if (state_reg == IDLE) begin
                bit_counter <= 3'd0; 
                delay_counter <= 3'd0; 
                rx_valid <= 1'b0; 
                rx_out <= rx_reg; 

                if (start) begin
                    tx_reg <= tx_data; 
                end

            end

            else if (state_reg == SETUP) begin
                delay_counter <= delay_counter + 1; 
            end


            else if (state_reg == IN_STREAM) begin
                delay_counter <= 3'd0; 

                if (sclk_postick) begin 
                    tx_reg <= {tx_reg[6:0], 1'b0}; 
                end

                if (sclk_negtick) begin
                    bit_counter <= bit_counter + 1;
                    rx_reg <= {rx_reg[6:0], miso}; 

                    if (bit_counter == 3'd7) begin
                        rx_valid <= 1'b1; 
                    end
                    else begin
                        rx_valid <= 1'b0; 
                    end
                end

            end
            else if (state_reg == HOLD) begin
                delay_counter <= delay_counter + 1; 
            end


        end
    end

    always @(*) begin

        case(state_reg) 

        IDLE: begin

            if (start) begin
                next_state = SETUP; 
            end
            else begin
                next_state = IDLE; 
            end
        end

        SETUP: begin
            if (delay_counter == DELAY_CYCLES - 1) begin
                next_state = IN_STREAM; 
            end
            else begin
                next_state = SETUP; 
            end
        end


        IN_STREAM: begin
            
            if (bit_counter == 3'd7 && sclk_negtick) begin
                next_state = HOLD; 
            end
            else begin
                next_state = IN_STREAM; 
            end
        end

        HOLD: begin
            if (delay_counter == DELAY_CYCLES - 1) begin
                next_state = IDLE; 
            end
            else begin
                next_state = HOLD; 
            end
        end

        default: begin
            next_state = state_reg; 
        end
        endcase

        cs_internal = state_reg == IDLE; 

        if (state_reg == IDLE) begin
            mosi = 1'b0; 
        end
        else begin
            mosi = tx_reg[7]; 
        end
    end
    


    always @(*) begin
        case (cs_select) 
        2'b00: begin
            cs_one = cs_internal; 
            cs_two = 1'b1; 
            cs_three = 1'b1; 
            cs_four = 1'b1; 
        end

        2'b01: begin
            cs_one = 1'b1; 
            cs_two = cs_internal; 
            cs_three = 1'b1; 
            cs_four = 1'b1; 
        end

        2'b10: begin
            cs_one = 1'b1; 
            cs_two = 1'b1; 
            cs_three = cs_internal; 
            cs_four = 1'b1; 
        end

        2'b11: begin
            cs_one = 1'b1; 
            cs_two = 1'b1; 
            cs_three = 1'b1; 
            cs_four = cs_internal; 
        end
        
        default: begin
            cs_one = 1'b1; 
            cs_two = 1'b1; 
            cs_three = 1'b1; 
            cs_four = 1'b1; 
        end
        
        endcase
    end

endmodule 