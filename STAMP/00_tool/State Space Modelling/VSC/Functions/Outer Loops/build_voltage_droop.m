function voltage_droop = build_voltage_droop(x,u,y,k,tau)
    if tau == 0
        A = 0;
        B = [0 0];
        C = 0;
        D = [k -k];
    else
        A  = [-1/tau];
        B  = [0 1];
        C  = [-k/tau];
        D  = [+k 0];
    end

    voltage_droop   = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end