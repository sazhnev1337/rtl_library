// ====== low-power delay line: 4 ticks, ring buffer ======
reg [1:0] dly_ptr;
reg signed [13:0] dly_re [0:3];
reg signed [13:0] dly_im [0:3];

always @(posedge clk) begin
    dly_ptr <= dly_ptr + 2'd1;
end

// запись: только один регистр переключается за такт
always @(posedge clk) begin
    dly_re[dly_ptr] <= in_re;
    dly_im[dly_ptr] <= in_im;
end

// чтение: следующая за текущей позиция — самое старое значение
wire [1:0] rd_ptr = dly_ptr + 2'd1;
wire signed [13:0] delay_out_re = dly_re[rd_ptr];
wire signed [13:0] delay_out_im = dly_im[rd_ptr];
