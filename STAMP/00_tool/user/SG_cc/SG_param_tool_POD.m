%% SG base 

%     Irms = Sb/Vb/sqrt(3);        % rms line current
%     Ipk  = Irms*sqrt(2);         % peak line current

%% SG parameters

    % Transformer
    Rtr = 0; %0.002; %pu
    Xtr = T_data.Xtr; %pu
    Ltr = Xtr/wb;
   
    Rsnb = 300; %pu
    
    %---------------------------------
    % Electrical machine
    %---------------------------------

    Rs_pu = 0.0025; 

    Xl       = T_data.Xl;
    Xd       = T_data.Xd;
    Xd_tr    = T_data.Xd_tr;
    Xd_subtr = T_data.Xd_subtr;
    Xq       = T_data.Xq;
    Xq_tr    = T_data.Xq_tr;
    Xq_subtr = T_data.Xq_subtr;
    
    Xmd = Xd - Xl; 
    Xmq = Xq - Xl; 
    
    Tdo_tr      = T_data.Tdo_tr;
    Tdo_subtr   = T_data.Tdo_subtr;
    Tqo_tr      = T_data.Tqo_tr;
    Tqo_subtr   = T_data.Tqo_subtr;
    
    % Conversion to equivalent circuit parameters

    Ll_pu = Xl; 
    Lmd_pu = Xd - Xl; 
    Lmq_pu = Xq - Xl; 
    
    Lfd_pu = (Lmd_pu*(Xd_tr-Xl))/(Lmd_pu-Xd_tr+Xl);
    L1q_pu = (Lmq_pu*(Xq_tr-Xl))/(Lmq_pu-Xq_tr+Xl);
    
    L1d_pu = (Xd_subtr-Xl)*(Lmd_pu*Lfd_pu)/(Lmd_pu*Lfd_pu-(Lfd_pu+Lmd_pu)*(Xd_subtr-Xl));
    L2q_pu = (Xq_subtr-Xl)*(Lmq_pu*L1q_pu)/(Lmq_pu*L1q_pu-(L1q_pu+Lmq_pu)*(Xq_subtr-Xl));
    
    Rf_pu = (Lmd_pu+Lfd_pu)/(Tdo_tr*wb);
    R1d_pu = 1/(Tdo_subtr*wb)*(L1d_pu+Lmd_pu*Lfd_pu/(Lmd_pu+Lfd_pu));
    
    R1q_pu = (Lmq_pu+L1q_pu)/(Tqo_tr*wb);
    R2q_pu = 1/(Tqo_subtr*wb)*(L2q_pu+Lmq_pu*L1q_pu/(Lmq_pu+L1q_pu));
    

%     Zb = Vb^2/Ssg;
%     Lbase = Zb/wb;

%     %d axis
%     Td_tr = Tdo_tr*Xd_tr/Xd;
%     Td_subtr = Tdo_subtr*Xd_subtr/Xd_tr;
%     
%     Ld = Xd*Lbase;
%     Lmd = Xmd*Lbase;
%     Ll = Xl*Lbase;
%     
%     A = Lmd^2/(Ld*(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr));
%     a = (Ld*(Td_tr+Td_subtr)-Ll*(Tdo_tr+Tdo_subtr))/Lmd;
%     b = (Ld*Td_tr*Td_subtr-Ll*Tdo_tr*Tdo_subtr)/Lmd;
%     c = (Tdo_tr*Tdo_subtr-Td_tr*Td_subtr)/(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr);
%     
%     ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
%     La = ra*(a+sqrt(a^2-4*b))/2;
%     rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
%     Lb = rb*(a-sqrt(a^2-4*b))/2;
%     
%     Rf_pu = ra/Zb;
%     Lfd_pu = La/Lbase;
%     R1d_pu = rb/Zb;
%     L1d_pu = Lb/Lbase;
%     
%     
%     % q axis
%     Tq_tr = Tqo_tr*Xq_tr/Xq;
%     Tq_subtr = Tqo_subtr*Xq_subtr/Xq_tr;
%     
%     Lq = Xq*Lbase;
%     Lmq = Xmq*Lbase;
%     
%     A = Lmq^2/(Lq*(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr));
%     a = (Lq*(Tq_tr+Tq_subtr)-Ll*(Tqo_tr+Tqo_subtr))/Lmq;
%     b = (Lq*Tq_tr*Tq_subtr-Ll*Tqo_tr*Tqo_subtr)/Lmq;
%     c = (Tqo_tr*Tqo_subtr-Tq_tr*Tq_subtr)/(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr);
%     
%     ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
%     La = ra*(a+sqrt(a^2-4*b))/2;
%     rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
%     Lb = rb*(a-sqrt(a^2-4*b))/2;
%     
%     R1q_pu = ra/Zb;
%     L1q_pu = La/Lbase;
%     R2q_pu = rb/Zb;
%     L2q_pu = Lb/Lbase;

%% Exciter and Governor

    % Inertia
    H = T_data.H; % sec
    % wm= 2*pi*50; %rad/s
    % J= 2*H*Ssg/wm^2; % kg.m^2
    
    % Transformer
    % Rtr_pu = 0.0025; %pu
    % Ltr_pu = 0.1;    %pu
    
    % Rtr = Rtr_pu*Vn^2/Ssg;
    % Ltr = Ltr_pu*Vn^2/Ssg/wb;
    
    % Governor
    gov.R = 1/T_data.K; 
    gov.T1 = T_data.T1; %s
    gov.T2 = T_data.T2; %s
    gov.T3 = T_data.T3;
    gov.Dt = 0;
    
    % Turbine
    Turb.K1 = T_data.K1;
    Turb.K3 = T_data.K3;
    Turb.K5 = T_data.K5;
    Turb.K7 = T_data.K7;
    Turb.K2 = T_data.K2;
    Turb.K4 = T_data.K4;
    Turb.K6 = T_data.K6;
    Turb.K8 = T_data.K8;
    Turb.T4 = T_data.T4;
    Turb.T5 = T_data.T5;
    Turb.T6 = T_data.T6;
    Turb.T7 = T_data.T7;

   
    switch T_data.exc{:}
        case 'ST4B'
            Exc.TR = T_data.TR;
            Exc.KPR = T_data.KPR;
            Exc.KIR = T_data.KIR;
            Exc.TA = T_data.TA;
            Exc.KPM = T_data.KPM;
            Exc.KIN = T_data.KIN;
            Exc.KG = T_data.KG;
            Exc.KI = T_data.KI;
            Exc.KP = T_data.KP;
            Exc.KC = T_data.KC;
            Exc.XL = T_data.XL;
        case 'ST1'
            Exc.TR = T_data.TR;
            Exc.TB = T_data.TB;
            Exc.TC = T_data.TC;
            Exc.KA = T_data.KA; 
            Exc.TA = T_data.TA;
            Exc.KC = T_data.KC;
            Exc.KF = T_data.KF;
            Exc.TF = T_data.TF;
        case 'AC4A'
            % Exc.TR = 0.001;
            % VImin = 0.8; %pu Lower limit on error signal
            % VImax = 1.2; %pu Upper limit on error signal
            Exc.TC = 1; % [s] Lead time constant
            Exc.TB = 10; %[s] Lag time constant
            Exc.KA = 200; %[pu]
            Exc.TA = 0.015; %[s] Regulator time constant
            Exc.VRmin = -4.53; %[pu] Minimum output
            Exc.VRmax = 5.64; %[pu] Maximum regulator
    end   
    
    % PSS
    pss.Ks1 = 17.069;
    pss.Ks2 = 0.158;
    pss.Ks3 = 1;
    
    pss.Tw1 = 2;
    pss.Tw2 = 2;
    pss.Tw3 = 2;
    pss.Tw4 = 0;
    
    pss.T1 = 0.28;
    pss.T2 = 0.04;
    pss.T3 = 0.28;
    pss.T4 = 0.12;
    pss.T6 = 0;
    pss.T7 = 2;
    pss.T8 = 0;
    pss.T9 = 0.1;
     
    pss.N = 1;
    pss.M = 5;