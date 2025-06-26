function voltage_droop_with_QLPF = build_voltage_droop_with_QLPF(x,u,y,k,tau,ig_d0,ig_q0,u_q0,u_d0)
    
    A = [-1/tau];
    B = [0 -3/2*ig_d0 3/2*ig_q0 3/2*u_d0 -3/2*u_q0];
    C = [k/tau];
    D = [+k 0 0 0 0];

    voltage_droop_with_QLPF = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);              
end