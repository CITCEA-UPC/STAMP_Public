function [SS_nus] = build_sum_currents_v2(nodeAC,Connectivity_Matrix)

% This block works together with build_MMC_trafo_v2 to generate its input:
% "sum of NET currents in node"
    currents = Connectivity_Matrix(nodeAC,:);
    total = sum(currents>0);
    Dnus = zeros(2,total+1);
    unus = cell(total+1,1);
    j=1;
    for i=1:1:size(currents,2)
        if currents(i)==1 && i<nodeAC
            unus{j}   = join(['NET.','iq_',num2str(i),'_',num2str(nodeAC)]);
            unus{j+1} = join(['NET.','id_',num2str(i),'_',num2str(nodeAC)]);
            Dnus(:,j:j+1) = [1 0;0 1]; 
            j=j+2;
        elseif currents(i)==1 && i>nodeAC
            unus{j}   = join(['NET.','iq_',num2str(nodeAC),'_',num2str(i)]);
            unus{j+1} = join(['NET.','id_',num2str(nodeAC),'_',num2str(i)]);
            Dnus(:,j:j+1) = [-1 0;0 -1]; 
            j=j+2;
        end
    end

    Anus = [0];
    columns_Bin = size(Dnus,2);
    Bnus = zeros(1,columns_Bin);
    Cnus = [0;0];
    ynus = { join(['NET.','iq',num2str(nodeAC)]) ;...
             join(['NET.','id',num2str(nodeAC)]) };
    xnus={''};
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);
   

end