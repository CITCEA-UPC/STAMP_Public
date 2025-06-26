function [washout_filter] = STATCOM_SS_WASHOUTFILTER(T,NAMEIN,NAMEOUT,NUMBER)

    A     = -1/T;
    B     = -1/T;
    C     = 1;
    D     = 1;

    x = sprintf('STAT%d.WashOutFilter',NUMBER); 
    washout_filter   = ss(A,B,C,D,'StateName',x,'inputname',NAMEIN,'outputname',NAMEOUT);
end