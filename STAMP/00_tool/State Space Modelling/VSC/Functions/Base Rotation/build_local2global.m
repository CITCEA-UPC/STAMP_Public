function l2g = build_local2global(x,u,y,e_theta0,q0,d0)
    A  = [0];
    B  = [0 0 0];
    C  = [0;0];
    D  = [cos(e_theta0) sin(e_theta0) -sin(e_theta0)*q0+cos(e_theta0)*d0;
          -sin(e_theta0) cos(e_theta0) -cos(e_theta0)*q0-sin(e_theta0)*d0];

    l2g   = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end