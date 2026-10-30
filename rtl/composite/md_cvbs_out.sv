// Decoded composite pixels from the decoder's clock to CLK_VIDEO, which here
// is clk_md, twice the decoder's clock from the same PLL.
//
// Each output pixel is held with a toggle; CLK_VIDEO registers the toggle
// twice and takes the pixel when it changes, by which time the pixel has been
// steady for at least one CLK_VIDEO cycle. A pixel lasts two decoder clocks,
// four CLK_VIDEO cycles, so none is missed and each gives one ce_pix.

module md_cvbs_out (
	input            clk_dec,
	input            pix_in,
	input            hs_in,
	input            vs_in,
	input            hb_in,
	input            vb_in,
	input      [7:0] r_in,
	input      [7:0] g_in,
	input      [7:0] b_in,

	input            clk_vid,
	output reg       ce_pix,
	output reg       hs,
	output reg       vs,
	output reg       hb,
	output reg       vb,
	output reg [7:0] r,
	output reg [7:0] g,
	output reg [7:0] b
);

reg        tog = 1'b0;
reg [27:0] hold = 28'd0;

always @(posedge clk_dec) if (pix_in) begin
	tog  <= ~tog;
	hold <= {hs_in, vs_in, hb_in, vb_in, r_in, g_in, b_in};
end

reg tog_m = 1'b0, tog_m2 = 1'b0;

always @(posedge clk_vid) begin
	tog_m  <= tog;
	tog_m2 <= tog_m;
	ce_pix <= tog_m != tog_m2;
	if (tog_m != tog_m2) {hs, vs, hb, vb, r, g, b} <= hold;
end

endmodule
