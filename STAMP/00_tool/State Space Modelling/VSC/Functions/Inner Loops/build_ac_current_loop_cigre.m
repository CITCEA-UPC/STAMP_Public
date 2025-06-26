function ac_current_loop = build_ac_current_loop_cigre(x,u,y,kp,ki,cc_damp,Rc,Lc,wb)
    A = [0 0;
         0 0];
    B = [1 0 -1 0 0 0 0 0;
         0 1 0 -1 0 0 0 0];
    C = [+ki 0;
           0 +ki];
    % D = [+kp      0  -kp-cc_damp+Rc*wb*Lc        +wb*Lc        1 0  cc_damp       0;
    %        0    +kp          -wb*Lc       -kp-cc_damp+Rc*wb*Lc  0 1     0      cc_damp];

    D = [+kp      0  -kp-cc_damp+Rc*wb*Lc        +wb*Lc         1             0               +cc_damp       0;
           0    +kp          -wb*Lc      -kp-cc_damp+Rc*wb*Lc  0             1                  0      cc_damp];

    ac_current_loop = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end