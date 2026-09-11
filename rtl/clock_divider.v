module clock_divider #(
    parameter CLK_FREQ = 50000000,
    parameter TARGET_FREQ = 1000000
)
(
    input clk, 
    input rst,
    input sclk_enable,
    output reg sclk, 
    output reg sclk_postick, 
    output reg sclk_negtick
); 


localparam DIVIDER = CLK_FREQ / TARGET_FREQ / 2; 
reg [6:0] counter; 


always @(posedge clk) begin
    if (rst || ~sclk_enable) begin
        counter <= 7'b0;
        sclk <= 1'b0; 
        sclk_postick <= 1'b0; 
        sclk_negtick <= 1'b0; 
    end
    else begin
        if (counter == DIVIDER - 1) begin
            sclk <= ~sclk; 
            counter <= 7'b0;

            if (sclk) begin
                sclk_postick <= 1'b0; 
                sclk_negtick <= 1'b1; 
            end
            else begin
                sclk_postick <= 1'b1;
                sclk_negtick <= 1'b0; 
            end
        end
        else begin
            counter <= counter + 1; 
            sclk_postick <= 1'b0;
            sclk_negtick <= 1'b0; 
        end
    end
end


endmodule