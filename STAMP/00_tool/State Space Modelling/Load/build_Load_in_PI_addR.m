function [Load] = build_Load_in_PI_addR(nodeAC,number,f,R,L,pf_bus,delta_slk)

% Calculate vq0 vd0
%theta0 = results.bus(:,9)*pi/180; % if voltage source as slack
theta0 = pf_bus.theta*pi/180-delta_slk; % if SG1 as slack

% As vectors
vq0 = pf_bus.Vm.*cos(theta0)*sqrt(2/3);
vd0 = -pf_bus.Vm.*sin(theta0)*sqrt(2/3);

    w=2*pi*f;
   
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

%     Ar = [0];
%     Br = [0 0];
%     Cr = [0;0];
%     Dr = 1/R*[1 0 ; 0 1];
%     ur = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
%           join(['NET','.vn',num2str(nodeAC),'d'])};
% 
%     yr = {join(['Load',num2str(number),'.irq']) ;...
%                join(['Load',num2str(number),'.ird'])};
% 
%     SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    Ar = [0];
    Br = [0 0 0];
    Cr = [0;0];
    Dr = [1/R  0 -vq0/R^2; 
          0   1/R -vd0/R^2];
    ur = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d']) ;... 
          join(['NET','.Rld',num2str(number)])};

    yr = {join(['Load',num2str(number),'.irq']) ;...
               join(['Load',num2str(number),'.ird'])};

    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);


    Anus = [0];
    Bnus = [0 0 0 0];
    Cnus = [0 ; 0];
    Dnus = [-1 -1 0   0;...
            0   0 -1 -1];
    unus = {join(['Load',num2str(number),'.irq']) ;...
            join(['Load',num2str(number),'.ilq']) ;...
            join(['Load',num2str(number),'.ird']) ;...
            join(['Load',num2str(number),'.ild'])};
    ynus = {join(['Load',num2str(number),'.iq']) ;...
            join(['Load',num2str(number),'.id'])};
    
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName','','InputName',unus,'OutputName',ynus);

    uLoad = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
             join(['NET','.vn',num2str(nodeAC),'d']) ;... 
             join(['NET','.Rld',num2str(number)])};

    yLoad = ynus;

    Load = connect(SS_r,SS_l,SS_nus,uLoad,yLoad);
    
end