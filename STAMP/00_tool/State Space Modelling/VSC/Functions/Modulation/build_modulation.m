function modulation = build_modulation(x,u,y,vdc0,vc_q0,vc_d0)
    %vc_d0=0.12;
    A = 0;
    B = [0 0 0];
    C = [0;0];
    D = [vdc0/vdc0        0         -vc_q0*vdc0/vdc0^2;
            0         vdc0/vdc0     -vc_d0*vdc0/vdc0^2];
    D = sqrt(2/3)*[1 0 0;
                   0 1 0]; 

    modulation = ss(A,B,C,D,'statename',x,'inputname',u,'outputname',y);

end