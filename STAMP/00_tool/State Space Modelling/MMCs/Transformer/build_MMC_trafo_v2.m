function [MMC_trafo_SS,ufinal] = build_MMC_trafo_v2(nodeAC,number,f,R,L)

% This version has the following input/output:
%   input: sum of NET currents in node , idiff
%   output: NET node voltage
% To separate MMC from trafo

    unus = {join(['NET.','iq',num2str(nodeAC)]);
            join(['NET.','id',num2str(nodeAC)]);
            join(['VSC',num2str(number),'.idiffq']);
            join(['VSC',num2str(number),'.idiffd'])};
    Dnus = [1 0 1 0;0 1 0 1]; 

    Anus = [0];
    Bnus = zeros(1,4);
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
%     ur = {join(['VSC',num2str(number),'.irtrafoq']) ;...
%                join(['VSC',num2str(number),'.irtrafod'])};
    ur = {join(['VSC',num2str(number),'.itrafoq']) ;...
               join(['VSC',num2str(number),'.itrafod'])};
    yr = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d'])};
    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    utrafo = unus;
    ufinal = unus(1:end-2);
    ytrafo = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])};
%     MMC_trafo_SS = connect(SS_r,SS_nus_rl,SS_l,SS_nus,utrafo,ytrafo);
    MMC_trafo_SS = connect(SS_r,SS_nus,utrafo,ytrafo);
end