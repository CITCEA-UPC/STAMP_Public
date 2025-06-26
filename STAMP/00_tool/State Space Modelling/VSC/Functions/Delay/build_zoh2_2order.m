function zoh = build_zoh2_2order(x,u,y,t)
    if t==-1
        A = [0];
        B = [0];
        C = [0];
        D = [1];
        x='';
    
    else
        A = [0 1 ; -12/t^2 -6/t^2];
        B = [0;1];
        C = [1 -6/t];
        D = [1];

        %a = [12/t];
        %b = [t 6 12/t];

        a = [20*t^2 -60*t +840];
        b = [60*t^2 +360*t +840];

        [A,B,C,D] = tf2ss(a,b);
    end
    
    zoh = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end