function pll = build_pll(x,u,y,kp,ki)
    A=[0];
    B=[1];
    C=[-ki];
    D=[-kp];

    pll = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end