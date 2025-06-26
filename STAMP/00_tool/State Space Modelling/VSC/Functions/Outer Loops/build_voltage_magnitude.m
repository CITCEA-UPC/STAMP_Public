function voltage_magnitude = build_voltage_magnitude(x,u,y,uq0,ud0)
    A = [0];
    B = [0 0];
    C = [0];
    D = [uq0/(sqrt(uq0^2+ud0^2)) ud0/(sqrt(uq0^2+ud0^2))];

    voltage_magnitude = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end