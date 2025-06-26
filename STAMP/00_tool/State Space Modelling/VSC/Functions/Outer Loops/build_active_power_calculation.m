function reactive_power = build_active_power_calculation(x,u,y,iq0,id0,uq0,ud0)
    A = [0];
    B = [0 0 0 0];
    C = [0];
    D = [3/2*uq0 3/2*ud0 3/2*iq0 3/2*id0];

    reactive_power = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end