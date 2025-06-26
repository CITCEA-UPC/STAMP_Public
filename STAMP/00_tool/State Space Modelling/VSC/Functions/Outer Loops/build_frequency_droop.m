function f_droop = build_frequency_droop(x,u,y,k,tau,wb)
    A=[-1/tau];
    B=[0 1];
    C=[-k/tau/wb];
    D=[+k/wb 0];

    f_droop = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end