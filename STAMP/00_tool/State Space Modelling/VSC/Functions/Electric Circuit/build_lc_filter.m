function lc_filter = build_lc_filter(x,u,y,Rc,Rac,Lc,Cac,wb,is_q0,is_d0,ucap_q0,ucap_d0)

   A =  [(-Rc-Rac)/Lc -wb -1/Lc 0;
            wb (-Rc-Rac)/Lc 0 -1/Lc;
            1/Cac 0 0 -wb;
            0 1/Cac wb 0];

   % B =  [1/Lc 0 Rac/Lc 0 -is_d0; 
   %         0 1/Lc 0 Rac/Lc +is_q0;
   %         0 0 -1/Cac 0 -ucap_d0; 
   %         0 0 0 -1/Cac +ucap_q0];

   B =  [1/Lc 0 Rac/Lc 0 0; 
           0 1/Lc 0 Rac/Lc 0;
           0 0 -1/Cac 0 0; 
           0 0 0 -1/Cac 0];

   C  = [1 0 0 0;
           0 1 0 0;
           Rac 0 1 0;
           0 Rac 0 1];
   D =  [0 0 0 0 0;
           0 0 0 0 0;
           0 0 -Rac 0 0;
           0 0 0 -Rac 0];

   lc_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end