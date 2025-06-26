function reactive_power_control = build_WT_reactive_power_control(x,u,y,kp,ki)
    A = [0];
    B = [1 -1];
    C = [ki];
    D = [kp -kp];

    reactive_power_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end