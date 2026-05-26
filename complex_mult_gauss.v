module complex_mult_gauss #(
    parameter PW_D     = 12,   // data width (ps1_re, ps1_im)
    parameter PW_C     = 10,   // coef width (coef_re, coef_im)
    parameter PW_OUT   = 18,   // output width of each real multiplier
    parameter P_TRUNC  = 6     // truncation bits in Booth multiplier
)(
    input  wire clk,

    input  wire signed [PW_D-1:0] ps1_re,
    input  wire signed [PW_D-1:0] ps1_im,

    input  wire signed [PW_C-1:0] coef_re,
    input  wire signed [PW_C-1:0] coef_im,

    output wire signed [PW_OUT:0] out_re,   // PW_OUT+1 for subtraction
    output wire signed [PW_OUT:0] out_im
);

// Промежуточные результаты
wire signed [PW_OUT-1:0] m1, m2_neg, m3_neg;

// m1 = (ps1_re + ps1_im) * coef_re
booth_mul_diff_mod #(
    .PW_D    (PW_C),       // multiplier = coef_re
    .PW_C    (PW_D),       // i_a, i_b = ps1_re, ps1_im
    .PW_OUT  (PW_OUT),
    .P_TRUNC (P_TRUNC),
    .P_DIFF  (0),          // A + B
    .P_INV   (0),          // no inversion
    .P_FF_EN (0)
) u_m1 (
    .clk     (clk),
    .i_x     (coef_re),
    .i_a     (ps1_re),
    .i_b     (ps1_im),
    .o_x_amb (m1)
);

// -m2 = -[(coef_re + coef_im) * ps1_im]
booth_mul_diff_mod #(
    .PW_D    (PW_D),       // multiplier = ps1_im
    .PW_C    (PW_C),       // i_a, i_b = coef_re, coef_im
    .PW_OUT  (PW_OUT),
    .P_TRUNC (P_TRUNC),
    .P_DIFF  (0),          // A + B  (coef_re + coef_im)
    .P_INV   (1),          // invert → gives -m2
    .P_FF_EN (0)
) u_m2_neg (
    .clk     (clk),
    .i_x     (ps1_im),
    .i_a     (coef_re),
    .i_b     (coef_im),
    .o_x_amb (m2_neg)
);

// -m3 = -[(coef_re - coef_im) * ps1_re]
booth_mul_diff_mod #(
    .PW_D    (PW_D),       // multiplier = ps1_re
    .PW_C    (PW_C),       // i_a, i_b = coef_re, coef_im
    .PW_OUT  (PW_OUT),
    .P_TRUNC (P_TRUNC),
    .P_DIFF  (1),          // A - B  (coef_re - coef_im)
    .P_INV   (1),          // invert → gives -m3
    .P_FF_EN (0)
) u_m3_neg (
    .clk     (clk),
    .i_x     (ps1_re),
    .i_a     (coef_re),
    .i_b     (coef_im),
    .o_x_amb (m3_neg)
);

// Re = m1 - m2 = m1 + (-m2)
// Im = m1 - m3 = m1 + (-m3)
assign out_re = $signed(m1) + $signed(m2_neg);
assign out_im = $signed(m1) + $signed(m3_neg);

endmodule
