function [leadlag] = STATCOM_SS_LEADLAG(T1,T2,NAMEIN,NAMEOUT,NUMBER,LeadLagNumber)

    A     = -1/T2;
    B     = (T2-T1)/T2;
    C     = 1/T2;
    D     = T1/T2;

    x = sprintf('STAT%d.LeadLag%d',NUMBER,LeadLagNumber); 
    leadlag   = ss(A,B,C,D,'StateName',x,'inputname',NAMEIN,'outputname',NAMEOUT);
end