module clock_divider #(
    parameter CLK_FREQ = 50000000,
    parameter TARGET_FREQ = 50000000
)
(
    input clk, 
    input rst,
    output reg sclk
); 


localparam DIVIDER = CLK_FREQ / TARGET_FREQ / 2; 
reg [6:0] counter; 


always @(posedge clk) begin
    if (rst) begin
        counter <= 7'b0;
        sclk <= 1'b0; 
    end
    else begin
        if (counter == DIVIDER - 1) begin
            sclk <= ~sclk; 
            counter <= 7'b0;
        end
        else begin
            counter <= counter + 1; 
        end
    end
end


endmodule