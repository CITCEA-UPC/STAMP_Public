function [MMC_trafo_SS,ufinal] = build_MMC_trafo(nodeAC,number,Connectivity_Matrix,f,R,L)
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
    unus{j}   = join(['VSC',num2str(number),'.idiffq']); 
    unus{j+1} = join(['VSC',num2str(number),'.idiffd']);
    Dnus(:,j:j+1) = [1 0;0 1]; 

    Anus = [0];
    columns_Bin = size(Dnus,2);
    Bnus = zeros(1,columns_Bin);
    Cnus = [0;0];
    ynus = { join(['VSC',num2str(number),'.itrafoq']) ;...
             join(['VSC',num2str(number),'.itrafod']) };
    xnus={''};
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName',xnus,'inputname',unus,'outputname',ynus);
    

%     Al = [0 0; 0 0];
%     Bl = [1/L 0; 0 1/L];
%     Cl = [1 0; 0 1];
%     Dl = [0 0; 0 0];
%     xl = {join(['VSC',num2str(number),'.iltrafoq']);...
%           join(['VSC',num2str(number),'.iltrafod'])};
%     ul = {join(['NET','.vn',num2str(nodeAC),'q'])  ;... 
%           join(['NET','.vn',num2str(nodeAC),'d'])} ;
%     yl = {join(['VSC',num2str(number),'.iltrafoq']);...
%           join(['VSC',num2str(number),'.iltrafod'])};
%     SS_l = ss(Al,Bl,Cl,Dl,'StateName',xl,'InputName',ul,'OutputName',yl);
% 
%     Anus_rl = [0];
%     Bnus_rl = [0 0 0 0];
%     Cnus_rl = [0;0];
%     Dnus_rl = [1 0 -1 0; 0 1 0 -1];
%     unus_rl = { join(['VSC',num2str(number),'.itrafoq'])  ;...
%                 join(['VSC',num2str(number),'.itrafod'])  ;...
%                 join(['VSC',num2str(number),'.iltrafoq']) ;...
%                 join(['VSC',num2str(number),'.iltrafod'])};
%     ynus_rl = {join(['VSC',num2str(number),'.irtrafoq']) ;...
%                join(['VSC',num2str(number),'.irtrafod'])};
%     SS_nus_rl = ss(Anus_rl,Bnus_rl,Cnus_rl,Dnus_rl,'StateName',{''},'InputName',unus_rl,'OutputName',ynus_rl);

    Ar = [0];
    Br = [0 0];
    Cr = [0;0];
    Dr = R*[1 0 ; 0 1];
%     ur = {join(['VSC.',num2str(number),'irtrafoq']) ;...
%                join(['VSC.',num2str(number),'irtrafod'])};
    ur = {join(['VSC',num2str(number),'.itrafoq']) ;...
               join(['VSC',num2str(number),'.itrafod'])};
    yr = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d'])};
    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    utrafo = unus;
    ufinal = unus(1:end-2);
    ytrafo = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])};
    %MMC_trafo_SS = connect(SS_r,SS_nus_rl,SS_l,SS_nus,utrafo,ytrafo);
    MMC_trafo_SS = connect(SS_r,SS_nus,utrafo,ytrafo);
end