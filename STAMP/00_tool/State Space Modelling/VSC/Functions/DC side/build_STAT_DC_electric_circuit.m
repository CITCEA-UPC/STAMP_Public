function STAT_DC_electric_circuit = build_STAT_DC_electric_circuit(Ceq,number)
    A = 0;
    B = 1/Ceq;
    C = 1;
    D = 0;
    STAT_DC_electric_circuit = ss(A,B,C,D,'statename',['STAT',num2str(number),'vdc'],'inputname',['STAT',num2str(number),'.idc'],'outputname',['STAT',num2str(number),'.vdc']);
end