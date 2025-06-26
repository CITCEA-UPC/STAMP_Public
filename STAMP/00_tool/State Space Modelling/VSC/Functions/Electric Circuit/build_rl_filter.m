function rl_filter = build_rl_filter(x,u,y,Rc,Lc,Rtr,Ltr,wb)
    A = [-(Rc+Rtr)/(Lc+Ltr) -wb;
         wb -(Rc+Rtr)/(Lc+Ltr)];
    B = [+1/(Lc+Ltr) 0 -1/(Lc+Ltr) 0;
         0 +1/(Lc+Ltr) 0 -1/(Lc+Ltr)];
    C = [1 0;
         0 1;
        (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr) 0;
         0 (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr)];
    D = [0 0 0 0;
         0 0 0 0;
 	     Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr) 0;
         0 Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr)];

    rl_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end