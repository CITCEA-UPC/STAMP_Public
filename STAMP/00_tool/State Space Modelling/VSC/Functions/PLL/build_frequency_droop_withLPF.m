function frequency_droop = build_frequency_droop_withLPF(x,u,y,k,tau,wb,ig_q0,ig_d0,u_q0,u_d0)

    A = [-1/tau];
    B = [0 3/2*ig_q0 3/2*ig_d0 3/2*u_q0 3/2*u_d0];
    C = [-k/tau*wb];
    D = [+k*wb 0 0 0 0];

    frequency_droop = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end