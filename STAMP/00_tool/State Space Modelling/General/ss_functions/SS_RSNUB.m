function[rsnub, ugrid] = SS_RSNUB(Rsnub, Connectivity_Matrix, nodeAC, number, isg_q, isg_d, vnXq, vnXd)
    
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

    unus{j}   = isg_q; 
    unus{j+1} = isg_d;
    Dnus(:,j:j+1) = [1 0;0 1]; 

    Anus = [0];
    Bnus = zeros(1, size(Dnus,2));
    Cnus = [0;0];
    ynus = {['SG' num2str(number) '.ir_q'] ['SG' num2str(number) '.ir_d']};
    xnus={''};
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);
    
    Ar = [0];
    Br = [0 0];
    Cr = [0;0];
    Dr = Rsnub*[1 0 ; 0 1];
    ur = {['SG' num2str(number) '.ir_q'] ['SG' num2str(number) '.ir_d']};
    yr = {vnXq vnXd};
    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);
    
    u_snub = unus;
    y_snub = yr;
    ugrid = unus(1:end-2); 
        
    rsnub = connect(SS_r,SS_nus,u_snub,y_snub);

end