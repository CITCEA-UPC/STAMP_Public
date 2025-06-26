
%% Converter base values
    Vn_vsc = Vb;            % RMS L-L for base peak
    Vb_vsc = Vn_vsc*sqrt(2)/sqrt(3);
    %Ib_vsc = Svsc/Vn_vsc;   % Phase, RMS
    Ib_vsc = Svsc/Vb_vsc*2/3;   % Phase, RMS
    Zb_vsc = Vn_vsc^2/Svsc;

%% 2L-VSC grid forming

Rc  = 0.005;               % Converter grid coupling filter resistance [pu]
Xc  = 0.15;
Lc  = Xc/wb;             % Converter grid coupling filter inductance [pu]
Cac = 0.15/wb;             % Converter grid coupling filter capacitance
Rac = 1/(3*10*wb*Cac);     % passive damping

% Current control
taus = 1e-3;
% kp_s=(Lc_n1*Zb_n1)/taus*(Ib_n1/Vb_n1);
% ki_s=(Rc_n1*Zb_n1)/taus*(Ib_n1/Vb_n1);
kp_s = Lc/taus;
ki_s = Rc/taus;

% AC voltage tuning: 
% kp_vac_n1=4.789*(Vn_vsc/Ib_vsc);
% ki_vac_n1=42.05*(Vn_vsc/Ib_vsc);
set_time_v  = 0.05;     % in s
xi_v        = 0.707;    %damping
wn_v        = 4/(set_time_v*xi_v); % natural frequency
kp_vac      = 2*xi_v*wn_v*Cac*100;
ki_vac      = wn_v^2*Cac;

% feedforward filters
tau_u  = 0.1e-3;
tau_ig = 0.1e-3;

% Droop parameters
k_droop_f   = 0.05; 
tau_droop_f = 1/10; %1/50; 
k_droop_u   = (0.02/0.3); 
tau_droop_u = 1/10; %1/50; 

% POD control P
Tpw = 5;
Tpf = 0.1;

% POD control Q
Tqw = 5;
Tqf = 0.1;

%% Transformer Impedance
Rtr = 0.002; %pu
Xtr = 0.15; %pu
Ltr = Xtr/wb;
