function reactive_power_control = build_reactive_power_control(x,u,y,kp,ki,iq0,id0,uq0,ud0)
    A = [0];
    B = [1 3/2*ud0 -3/2*uq0 -3/2*id0 3/2*iq0];
    C = [ki];
    D = [kp 3/2*ud0*kp -3/2*uq0*kp -3/2*id0*kp  3/2*iq0*kp];

    reactive_power_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end