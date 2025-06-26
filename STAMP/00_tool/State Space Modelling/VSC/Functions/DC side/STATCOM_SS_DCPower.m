function STATCOM_SS_idc = STATCOM_SS_DCPower(Vdc0, Pac0, number)
    A = 0;
    B = [0 0];
    C = 0;
    D = [-1/Vdc0 Pac0/Vdc0^2];
    STATCOM_SS_idc = ss(A,B,C,D,'statename','','inputname',{'Power_POD' , ['STAT',num2str(number),'.vdc']},'outputname',['STAT',num2str(number),'.idc']);
end 