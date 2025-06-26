function [Load] = build_Load_in_PI_R_addR(nodeAC,number,R,pf_bus,delta_slk)

% Calculate vq0 vd0
theta0 = pf_bus.theta*pi/180-delta_slk; % if SG1 as slack

% As vectors
vq0 = pf_bus.Vm.*cos(theta0)*sqrt(2/3);
vd0 = -pf_bus.Vm.*sin(theta0)*sqrt(2/3);

    Ar = [0];
    Br = [0 0 0];
    Cr = [0;0];
    Dr = [1/R  0 -vq0/R^2; 
          0   1/R -vd0/R^2]*(-1);
    ur = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d']) ;... 
          join(['NET','.Rld',num2str(number)])};

    yr = {join(['Load',num2str(number),'.iq']) ;...
               join(['Load',num2str(number),'.id'])};

    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    Load = SS_r;
    
end