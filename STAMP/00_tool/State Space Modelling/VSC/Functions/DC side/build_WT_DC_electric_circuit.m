function WT_DC_electric_circuit = build_WT_DC_electric_circuit(Ceq,number)
    A = 0;
    B = 1/(Ceq);
    C = 1;
    D = 0;
    WT_DC_electric_circuit = ss(A,B,C,D,'statename',['WT',num2str(number),'vdc'],'inputname',['WT',num2str(number),'.idc'],'outputname',['WT',num2str(number),'.vdc']);
end