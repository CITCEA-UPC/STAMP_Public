function g2l = build_global2local(x,u,y,e_theta0,q0,d0)
    A = [0];
    B = [0 0 0];
    C = [0;0];
    D = 1*[cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*q0-cos(e_theta0)*d0;
          sin(e_theta0) cos(e_theta0) cos(e_theta0)*q0-sin(e_theta0)*d0];

   g2l   = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end