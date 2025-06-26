%% SG base 

%     Irms = Sb/Vb/sqrt(3);        % rms line current
%     Ipk  = Irms*sqrt(2);         % peak line current

%% SG parameters

    % Transformer
    Rtr = 0.002; %pu
    Xtr = 0.1; %pu
    Ltr = Xtr/wb;
   
    Rsnb = 300; %pu
    
    %---------------------------------
    % Electrical machine
    %---------------------------------
    Rs_pu = 0.0025; 
    Xl = 0.2;
    Xd = 1.8;
    Xd_tr = 0.3;
    Xd_subtr = 0.25;
    Xq = 1.7;
    Xq_tr = 0.55;
    Xq_subtr = 0.25;
    
    Xmd = Xd - Xl; 
    Xmq = Xq - Xl; 
    
    Tdo_tr = 8;
    Tdo_subtr = 0.03;
    Tqo_tr = 0.4;
    Tqo_subtr = 0.05;
    
    % Conversion to equivalent circuit parameters
    Zb = Vb^2/Ssg;
    Lbase = Zb/wb;
    Ll_pu = Xl; 
    Lmd_pu = Xd - Xl; 
    Lmq_pu = Xq - Xl; 
    % 
    % Lfd_pu = (Lmd_pu*(Xd_tr-Xl))/(Lmd_pu-Xd_tr+Xl);
    % L1q_pu = (Lmq_pu*(Xq_tr-Xl))/(Lmq_pu-Xq_tr+Xl);
    % 
    % L1d_pu = (Xd_subtr-Xl)*(Lmd_pu*Lfd_pu)/(Lmd_pu*Lfd_pu-(Lfd_pu+Lmd_pu)*(Xd_subtr-Xl));
    % L2q_pu = (Xq_subtr-Xl)*(Lmq_pu*L1q_pu)/(Lmq_pu*L1q_pu-(L1q_pu+Lmq_pu)*(Xq_subtr-Xl));
    % 
    % Rf_pu = (Lmd_pu+Lfd_pu)/(Tdo_tr*wb);
    % R1d_pu = 1/(Tdo_subtr*wb)*(L1d_pu+Lmd_pu*Lfd_pu/(Lmd_pu+Lfd_pu));
    % 
    % R1q_pu = (Lmq_pu+L1q_pu)/(Tqo_tr*wb);
    % R2q_pu = 1/(Tqo_subtr*wb)*(L2q_pu+Lmq_pu*L1q_pu/(Lmq_pu+L1q_pu));
    
    
    %d axis
    Td_tr = Tdo_tr*Xd_tr/Xd;
    Td_subtr = Tdo_subtr*Xd_subtr/Xd_tr;
    
    Ld = Xd*Lbase;
    Lmd = Xmd*Lbase;
    Ll = Xl*Lbase;
    
    A = Lmd^2/(Ld*(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr));
    a = (Ld*(Td_tr+Td_subtr)-Ll*(Tdo_tr+Tdo_subtr))/Lmd;
    b = (Ld*Td_tr*Td_subtr-Ll*Tdo_tr*Tdo_subtr)/Lmd;
    c = (Tdo_tr*Tdo_subtr-Td_tr*Td_subtr)/(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr);
    
    ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
    La = ra*(a+sqrt(a^2-4*b))/2;
    rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
    Lb = rb*(a-sqrt(a^2-4*b))/2;
    
    Rf_pu = ra/Zb;
    Lfd_pu = La/Lbase;
    R1d_pu = rb/Zb;
    L1d_pu = Lb/Lbase;
    
    
    % q axis
    Tq_tr = Tqo_tr*Xq_tr/Xq;
    Tq_subtr = Tqo_subtr*Xq_subtr/Xq_tr;
    
    Lq = Xq*Lbase;
    Lmq = Xmq*Lbase;
    
    A = Lmq^2/(Lq*(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr));
    a = (Lq*(Tq_tr+Tq_subtr)-Ll*(Tqo_tr+Tqo_subtr))/Lmq;
    b = (Lq*Tq_tr*Tq_subtr-Ll*Tqo_tr*Tqo_subtr)/Lmq;
    c = (Tqo_tr*Tqo_subtr-Tq_tr*Tq_subtr)/(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr);
    
    ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
    La = ra*(a+sqrt(a^2-4*b))/2;
    rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
    Lb = rb*(a-sqrt(a^2-4*b))/2;
    
    R1q_pu = ra/Zb;
    L1q_pu = La/Lbase;
    R2q_pu = rb/Zb;
    L2q_pu = Lb/Lbase;

%% Exciter and Governor

    % Inertia
    H = 6.5; % sec
    % wm= 2*pi*50; %rad/s
    % J= 2*H*Ssg/wm^2; % kg.m^2
    
    % Transformer
    % Rtr_pu = 0.0025; %pu
    % Ltr_pu = 0.1;    %pu
    
    % Rtr = Rtr_pu*Vn^2/Ssg;
    % Ltr = Ltr_pu*Vn^2/Ssg/wb;
    
    % Governor
    gov.R = 0.05;
    gov.T1 = 7.5; %s
    gov.T2 = 2.8; %s
    gov.T3 = 0.1;
    gov.Dt = 0;
    
    % Turbine
    Turb.K1 = 0.22;
    Turb.K3 = 0;
    Turb.K5 = 0.14;
    Turb.K7 = 0.14;
    Turb.K2 = 0;
    Turb.K4 = 0.22;
    Turb.K6 = 0.14;
    Turb.K8 = 0.14;
    Turb.T4 = 0.25;
    Turb.T5 = 7.5;
    Turb.T6 = 7.5;
    Turb.T7 = 0.4;
    
    %Exciter SG
    % Exc.TR = 0.001;
    % VImin = 0.8; %pu Lower limit on error signal
    % VImax = 1.2; %pu Upper limit on error signal
    Exc.TC = 1; % [s] Lead time constant
    Exc.TB = 10; %[s] Lag time constant
    Exc.KA = 200; %[pu]
    Exc.TA = 0.015; %[s] Regulator time constant
    Exc.VRmin = -4.53; %[pu] Minimum output
    Exc.VRmax = 5.64; %[pu] Maximum regulator
    
    
    % PSS
    Ks1 = 10; %20;
    Ks2 = 0.1564;
    Ks3 = 1; %1;
    
    Tw1 = 2;
    Tw2 = 2;
    Tw3 = 2;
    Tw4 = 2; %0;
    
    T1 = 0.25;
    T2 = 0.03; %0.2;
    T3 = 0.15;
    T4 = 0.015; %0.1;
    T6 = 0;
    T7 = 2;
    T8 = 0.5;
    T9 = 0.1;
     
    N = 1;
    M = 1;