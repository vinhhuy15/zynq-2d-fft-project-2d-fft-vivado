`timescale 1ns / 1ps

module DVIClocking (
    input  wire PixelClkX5,
    input  wire aLockedIn,
    output wire PixelClk,
    output wire SerialClk,
    output wire aLockedOut
);

    reg [2:0] div_count = 3'd0;
    reg pixel_clk_reg = 1'b0;

    assign SerialClk = PixelClkX5;
    assign PixelClk = pixel_clk_reg;
    assign aLockedOut = aLockedIn;

    always @(posedge PixelClkX5) begin
        if (!aLockedIn) begin
            div_count <= 3'd0;
            pixel_clk_reg <= 1'b0;
        end else if (div_count == 3'd4) begin
            div_count <= 3'd0;
            pixel_clk_reg <= ~pixel_clk_reg;
        end else begin
            div_count <= div_count + 3'd1;
        end
    end

endmodule
