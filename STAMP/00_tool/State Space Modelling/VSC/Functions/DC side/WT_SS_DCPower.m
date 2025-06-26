function WT_SS_idc = WT_SS_DCPower(Vdc0, Pac0, Pdc0, number)
    A = 0;
    B = [0 0 0];
    C = 0;
    D = [-1/Vdc0 1/Vdc0 (Pac0-Pdc0)/Vdc0^2];
    WT_SS_idc = ss(A,B,C,D,'statename','',...
        'inputname',{['WT',num2str(number),'.p'],['WT',num2str(number),'.pdc'] , ['WT',num2str(number),'.vdc']},...
        'outputname',['WT',num2str(number),'.idc']);
end 