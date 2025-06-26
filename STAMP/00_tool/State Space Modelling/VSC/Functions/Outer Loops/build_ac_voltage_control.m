function ac_voltage_control = build_ac_voltage_control(x,u,y,kp,ki,Cac,wb)

    A  = [0 0; 0 0];
    B  = [1 0 -1 0 0 0;
           0 1 0 -1 0 0];
    C  = [+ki 0;
           0 +ki];
    D  = [+kp 0 -kp +wb*Cac 1 0;
           0 +kp -wb*Cac -kp 0 1];

    ac_voltage_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
             
end