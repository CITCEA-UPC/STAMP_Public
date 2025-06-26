function measurement_delay = build_measurement_delay(x,u,y,tau)
    if tau==0
    A=[0];
    B = [0];
    C = [0];
    D = [1];
    else
    A= [-1/tau];
    B = [1/tau];
    C = 1;
    D = [0];
    end
    measurement_delay = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end