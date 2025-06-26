function[T_Rsnub] = SS_RSNUB_MULT(T_SG, Connectivity_Matrix)

[ocurrences,nodesAC] = groupcounts(T_SG.bus);

% create empty table to stor Rsnub -SS
sz = [size(nodesAC,1) 3];
varTypes = ["double","cell","cell"];
varNames = ["Node_AC","ss","ugrid"];
T_Rsnub = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

    for idx_node = 1:1:size(nodesAC,1)
        nodeAC = nodesAC(idx_node);

        % define variable names
        vnXq = ['NET.vn' num2str(nodeAC) 'q'];   %'NET.vsX_q' 
        vnXd = ['NET.vn' num2str(nodeAC) 'd'];   %'NET.vsX_d'

        % generate sum-of-NET.currents matrices
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
    
         % generate sum-of-SG.currents matrices
        if ocurrences(idx_node) > 1 
            sumInvRsnub = 0;
            SGnum_vect   = T_SG.number(T_SG.bus == nodeAC);
            for i=1:1:ocurrences(idx_node)
                SGnum = SGnum_vect(i);                
                unus{j}   = join(['SG' num2str(SGnum) '.iq']);
                unus{j+1} = join(['SG' num2str(SGnum) '.id']);
                Dnus(:,j:j+1) = [1 0;0 1]; 
                j=j+2;

                sumInvRsnub = sumInvRsnub + 1/T_SG.Rsnb(T_SG.number == SGnum);
            end
            % parlalel de Rsnub al node
            Rsnub = 1/sumInvRsnub;

        elseif ocurrences(idx_node) == 1 
            SGnum   = T_SG.number(T_SG.bus == nodeAC);
            iq   = ['SG' num2str(SGnum) '.iq'];      %'NET.isX_q'
            id   = ['SG' num2str(SGnum) '.id'];      %'NET.isX_d'
            unus{j}   = iq; 
            unus{j+1} = id;
            Dnus(:,j:j+1) = [1 0;0 1]; 

            Rsnub = T_SG.Rsnb(T_SG.bus == nodeAC);
        end

        Anus = [0];
        Bnus = zeros(1, size(Dnus,2));
        Cnus = [0;0];
        ynus = {['NET' num2str(nodeAC) '.ir_q'] ['NET' num2str(nodeAC) '.ir_d']};
        xnus={''};
        SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);

        Ar = [0];
        Br = [0 0];
        Cr = [0;0];
        Dr = Rsnub*[1 0 ; 0 1];
        ur = {['NET' num2str(nodeAC) '.ir_q'] ['NET' num2str(nodeAC) '.ir_d']};
        yr = {vnXq vnXd};
        SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);


        %Rsnuber en el node, que en fotem --> connect??
        u_snub = unus;
        y_snub = yr;
        ugrid = unus(1:end-2*ocurrences(idx_node));           
        rsnub = connect(SS_r,SS_nus,u_snub,y_snub);

        T_Rsnub(idx_node,:) = {nodeAC, {rsnub}, {ugrid}}; 
    
    end


%     [T_SG.ss_Rsnub{sg}, ugrid] = SS_RSNUB(T_SG.Rsnb(sg), Connectivity_Matrix, T_SG.bus(sg), SGnum, in, out);
%     in   = [ugrid(:)' +corrents iq,id de tots els SG al nodeAC ]
%     out  = [vnXq vnXd]


end