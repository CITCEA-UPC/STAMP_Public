function [Load] = build_LoadC_in_PI_addR(nodeAC,number,f,R,C,pf_bus,delta_slk)

%¡It needs a parasitic resistance in series with C to properly connect
% the RC load with the PI-section line. The parasitic resistance is set
% to Rpar = 0.001 pu!
Rpar = 0.001;

% Calculate vq0 vd0
%theta0 = results.bus(:,9)*pi/180; % if voltage source as slack
theta0 = pf_bus.theta*pi/180-delta_slk; % if SG1 as slack

% As vectors
vq0 = pf_bus.Vm.*cos(theta0)*sqrt(2/3);
vd0 = -pf_bus.Vm.*sin(theta0)*sqrt(2/3);

w=2*pi*f;
   
Ac = [0 -w; w 0];
Bc = [1/C 0; 0 1/C];
Cc = [1 0; 0 1];
Dc = [0 0; 0 0];
xc = {join(['Load',num2str(number),'.vcq']);...
              join(['Load',num2str(number),'.vcd'])};
uc = {join(['Load',num2str(number),'.iparq']) ;...
      join(['Load',num2str(number),'.ipard'])};
yc = {join(['Load',num2str(number),'.vcq']) ;... 
      join(['Load',num2str(number),'.vcd'])};
SS_c = ss(Ac,Bc,Cc,Dc,'StateName',xc,'InputName',uc,'OutputName',yc);
    
Apar = [0];
Bpar = [0 0 0 0];
Cpar = [0;0];
Dpar = 1/Rpar*[1 0 -1 0; 0 1 0 -1];
upar = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
        join(['NET','.vn',num2str(nodeAC),'d']) ;...
        join(['Load',num2str(number),'.vcq'])   ;... 
        join(['Load',num2str(number),'.vcd'])  };

ypar = {join(['Load',num2str(number),'.iparq']) ;...
        join(['Load',num2str(number),'.ipard'])};

SS_par = ss(Apar,Bpar,Cpar,Dpar,'StateName','','InputName',upar,'OutputName',ypar);

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
        join(['Load',num2str(number),'.iparq']) ;...
        join(['Load',num2str(number),'.ird']) ;...
        join(['Load',num2str(number),'.ipard'])};
ynus = {join(['Load',num2str(number),'.iq']) ;...
       join(['Load',num2str(number),'.id'])};
    
SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName','','InputName',unus,'OutputName',ynus);

uLoad = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
         join(['NET','.vn',num2str(nodeAC),'d']) ;... 
         join(['NET','.Rld',num2str(number)])};

yLoad = ynus;

Load = connect(SS_r,SS_c,SS_par,SS_nus,uLoad,yLoad);
    
end