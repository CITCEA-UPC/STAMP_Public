function active_power_control = build_active_power_control(x,u,y,kp,ki,iq0,id0,uq0,ud0)
    A = [0];
    B = [1 -3/2*uq0 -3/2*ud0 -3/2*iq0 -3/2*id0]; 
    C = [ki];
    D = [kp -3/2*uq0*kp -3/2*ud0*kp -3/2*iq0*kp -3/2*id0*kp];

    active_power_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    
end