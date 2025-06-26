function [LPF_filter] = STATCOM_SS_LPF(T,NAMEIN,NAMEOUT,NUMBER)

    A     = -1/T;
    B     = 1/T;
    C     = 1;
    D     = 0;

    x = sprintf('STAT%d.LPF_Power',NUMBER); 
    LPF_filter   = ss(A,B,C,D,'StateName',x,'inputname',NAMEIN,'outputname',NAMEOUT);
end