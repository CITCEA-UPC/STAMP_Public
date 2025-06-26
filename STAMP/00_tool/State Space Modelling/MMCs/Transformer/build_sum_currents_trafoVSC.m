function [SS_nus] = build_sum_currents_trafoVSC(nodeAC,number)

% This block works together with buil_MMC_trafo_trafoVSC to generate the output:
% "sum of trafo and MMC current in node"

    unus = { join(['VSC',num2str(number),'.itrafoq']) ;...
             join(['VSC',num2str(number),'.itrafod']);
             join(['VSC',num2str(number),'.idiffq']);
             join(['VSC',num2str(number),'.idiffd'])};
    Dnus = [-1 0 1 0;0 -1 0 1]; 

    Anus = [0];
    Bnus = zeros(1,4);
    Cnus = [0;0];


    ynus = { join(['NET.','iq',num2str(nodeAC)]) ;...
             join(['NET.','id',num2str(nodeAC)]) };
    xnus={''};
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);
   

end