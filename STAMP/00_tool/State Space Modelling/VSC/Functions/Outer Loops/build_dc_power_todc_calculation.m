function dc_power_todc = build_dc_power_todc_calculation(x,u,y,vdc0,idc0)
    A = [0];
    B = [0 0]; 
    C = [0];
    D = [idc0 vdc0];

    dc_power_todc = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    
end