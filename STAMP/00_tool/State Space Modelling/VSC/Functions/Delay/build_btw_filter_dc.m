function btw_filter = build_btw_filter_dc(fc,x,u,y)
    if fc==-1
        
        A = [0];
        B = [0];
        C = [0];
        D = [1];
        x='';
        btw_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    else
           
        wc = fc*2*pi;
        n = 2;
        [Ass,Bss,Css,Dss] = butter(n,wc,'low','s');
        btw_filter = ss(Ass,Bss,Css,Dss,'statename',x,'inputname',u,'outputname',y);

    end
end