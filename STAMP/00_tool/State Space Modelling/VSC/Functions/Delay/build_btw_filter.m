function btw_filter = build_btw_filter(w,n,x,u,y)
    [A,B,C,D] = butter(n,w,'s');
    btw_filter = ss(A,B,C,D,'statename',x,'inputname',u,'outputname',y);
end