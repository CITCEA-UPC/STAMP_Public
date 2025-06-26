function base_change = build_base_change(x,u,y,change)

    A = [0 0;0 0];
    B = [0 0; 0 0];
    C = [0 0;0 0];
    D = [1 0; 0 1]/change;

    base_change = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    
end