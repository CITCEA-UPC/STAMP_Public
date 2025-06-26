function zoh = build_zoh_abc_2order_dc(x,u,y,tau)
    if tau==-1
        A = [0];
        B = [0];
        C = [0];
        D = [1];
        x='';
    
        zoh = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    else
        %q-component
        a = [20*tau^2 -60*tau +840];
        b = [60*tau^2 +360*tau +840];
        [Ass,Bss,Css,Dss] = tf2ss(a,b);
        zoh = ss(Ass,Bss,Css,Dss,'statename',x,'inputname',u,'outputname',y);
       
    end
    
end