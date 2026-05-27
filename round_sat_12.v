function signed [11:0] round_sat_12;
    input signed [13:0] x;
    reg signed [14:0] x_add;
    reg signed [13:0] x_sat;
    reg sticky;
    reg replace_bit;
    begin
        x_add = x + 14'sd2;                            // +1 на позицию [1]

        if      (x_add >  15'sd2047)  x_sat = 14'sd2047;
        else if (x_add < -15'sd2048)  x_sat = -14'sd2048;
        else                          x_sat = x_add[13:0];

        sticky      = x_sat[0] | x_sat[1];             // OR битов [1:0] после прибавления
        replace_bit = x_sat[2] & sticky;                // tie → обнуляем LSB результата
        round_sat_12 = {x_sat[13:3], replace_bit};
    end
endfunction
