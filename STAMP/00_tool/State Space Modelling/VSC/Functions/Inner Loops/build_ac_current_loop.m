function ac_current_loop = build_ac_current_loop(x,u,y,kp,ki,Lc,wb)
    A = [0 0;
           0 0];
    B = [1 0 -1 0 0 0;
           0 1 0 -1 0 0];
    C = [+ki 0;
           0 +ki];
    D = [+kp 0  -kp  +wb*Lc     1 0;
           0    +kp -wb*Lc -kp  0 1];

    ac_current_loop = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end