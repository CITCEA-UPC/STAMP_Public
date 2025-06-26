function Load = build_Load_in_rl(nodeAC,number,Connectivity_Matrix,T_nodes,f,R,L)

    w=2*pi*f;
    currents = Connectivity_Matrix(nodeAC,:);
    total = sum(currents>0);
    Dnus = zeros(2,2*total);
    unus = cell(2*total,1);
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
    if not(ismissing(T_nodes(nodeAC,2)))
        for i=1:1:size(T_nodes(T_nodes.Node==nodeAC,:),2)-1
            cadena_element=split(T_nodes{nodeAC,i+1});
            if not(ismissing(cadena_element))
                element = cadena_element(1);
                numberb = cadena_element(2);
                if isequal(element,"SG")
                   str = split(T_nodes{nodeAC,i+1});
                   numberb =str(2);
                   unus{j}   = join(['SG',num2str(numberb),'.iq']);
                   unus{j+1} = join(['SG',num2str(numberb),'.id']);
                   Dnus(:,j:j+1) = [1 0;0 1];
                   j=j+2;
                elseif isequal(element,"TH")
                   str = split(T_nodes{nodeAC,i+1});
                   numberb =str(2);
                   unus{j}   = join(['TH',num2str(numberb),'.iq']);
                   unus{j+1} = join(['TH',num2str(numberb),'.id']);
                   Dnus(:,j:j+1) = [1 0;0 1];
                   j=j+2;
                elseif isequal(element,"MMC")
                   str = split(T_nodes{nodeAC,i+1});
                   numberb =str(2);
                   unus{j}   = join(['VSC',num2str(numberb),'.idiffq']);
                   unus{j+1} = join(['VSC',num2str(numberb),'.idiffd']);
                   Dnus(:,j:j+1) = [1 0;0 1];
                   j=j+2;
                elseif isequal(element,"VSC")
                   str = split(T_nodes{nodeAC,i+1});
                   numberb =str(2);
                   unus{j}   = join(['VSC',num2str(numberb),'.iq']);
                   unus{j+1} = join(['VSC',num2str(numberb),'.id']);
                   Dnus(:,j:j+1) = [1 0;0 1];
                   j=j+2;
                elseif isequal(element,"user")
                   str = split(T_nodes{nodeAC,i+1});
                   numberb =str(2);
                   unus{j}   = join(['USER',num2str(numberb),'.iq']);
                   unus{j+1} = join(['USER',num2str(numberb),'.id']);
                   Dnus(:,j:j+1) = [1 0;0 1];
                   j=j+2;
                end
            end
        end
    end

    Anus = [0];
    columns_Bin = size(Dnus,2);
    Bnus = zeros(1,columns_Bin);
    Cnus = [0;0];
    ynus = { join(['Load',num2str(number),'.iq']) ;...
             join(['Load',num2str(number),'.id']) };
    xnus={''};
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);
    
    if L
        Al = [0 -w; w 0];
        Bl = [1/L 0; 0 1/L];
        Cl = [1 0; 0 1];
        Dl = [0 0; 0 0];
        xl = {join(['Load',num2str(number),'.ilq']);...
              join(['Load',num2str(number),'.ild'])};
        ul = {join(['NET','.vn',num2str(nodeAC),'q'])  ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])} ;
        yl = {join(['Load',num2str(number),'.ilq']);...
              join(['Load',num2str(number),'.ild'])};
        SS_l = ss(Al,Bl,Cl,Dl,'StateName',xl,'InputName',ul,'OutputName',yl);
    
        Anus_rl = [0];
        Bnus_rl = [0 0 0 0];
        Cnus_rl = [0;0];
        Dnus_rl = [1 0 -1 0; 0 1 0 -1];
        unus_rl = { join(['Load',num2str(number),'.iq'])  ;...
                    join(['Load',num2str(number),'.id'])  ;...
                    join(['Load',num2str(number),'.ilq']) ;...
                    join(['Load',num2str(number),'.ild'])};
        ynus_rl = {join(['Load',num2str(number),'.irq']) ;...
                   join(['Load',num2str(number),'.ird'])};
        SS_nus_rl = ss(Anus_rl,Bnus_rl,Cnus_rl,Dnus_rl,'StateName',{''},'InputName',unus_rl,'OutputName',ynus_rl);
    
        
        Ar = [0];
        Br = [0 0];
        Cr = [0;0];
        Dr = R*[1 0 ; 0 1];
        ur = {join(['Load',num2str(number),'.irq']) ;...
                   join(['Load',num2str(number),'.ird'])};
    
        yr = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])};
        SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);
    
        uLoad = unus;
        ufinal = unus(1:end-2);
        yLoad = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
                  join(['NET','.vn',num2str(nodeAC),'d'])};
    
        Load = connect(SS_r,SS_nus_rl,SS_l,SS_nus,uLoad,yLoad);

    else

        Ar = [0];
        Br = [0 0];
        Cr = [0;0];
        Dr = R*[1 0 ; 0 1];
        ur = {join(['Load',num2str(number),'.iq']) ;...
                   join(['Load',num2str(number),'.id'])};
    
        yr = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])};
        SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);
    
        uLoad = unus;
        ufinal = unus(1:end-2);
        yLoad = yr;
    
        Load = connect(SS_r,SS_nus,uLoad,yLoad);

    end
    
end