function base_change = build_change_to_peak(x,u,y)

    A = [0];
    B = [0 0];
    C = [0;0];
    D = sqrt(3/2)*[1 0; 0 1];

    base_change = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    
end