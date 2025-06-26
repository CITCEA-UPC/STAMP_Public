function EFD_calculation = SS_EFD_CALCULATION(K,VE0,FE0,NAMEIN,NAMEOUT)
    A = 0;
    B = [0 0];
    C = 0;
    D = K*[FE0 VE0];

    EFD_calculation = ss(A,B,C,D,'statename','','inputname',NAMEIN,'outputname',NAMEOUT);
end