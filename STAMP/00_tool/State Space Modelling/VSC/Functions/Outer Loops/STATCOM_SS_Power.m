function [Power] = STATCOM_SS_Power(NAMEIN,NAMEOUT,vq0,iq0,vd0,id0)
    A = 0;
    B = [0 0 0 0];
    C = 0;
    D = 3/2*[iq0,vq0,id0,vd0];

    Power = ss(A,B,C,D,'statename','','inputname',NAMEIN,'outputname',NAMEOUT);

end