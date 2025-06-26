function transformer = build_transformer(x,u,y,Rtr,Ltr,w0)
    A = [-(Rtr)/(Ltr) -w0;
            w0 -(Rtr)/(Ltr)];
    B = [1/(Ltr), 0, -1/(Ltr), 0;
           0, 1/(Ltr), 0, -1/(Ltr)];    
    C = [1, 0;
           0, 1];
    D = [0, 0, 0, 0;
         0, 0, 0, 0];

    transformer = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end