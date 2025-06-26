function delay = build_delay(tau,x,u,y)
    A= [-1/tau];
    B = [1/tau];
    C = 1;
    D = [0]; 
    delay = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end