
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

% Current control
taus = 1e-3;
kp_s = Lc/taus;
ki_s = Rc/taus;

% PLL tuning
ts_pll    = 0.1;
xi_pll    = 0.707;
omega_pll = 4/(ts_pll*xi_pll);
tau_pll   = 2*xi_pll/omega_pll;
kp_pll    = 2*omega_pll*xi_pll;
ki_pll    = kp_pll/tau_pll;

% Power loops
tau_p = 0.1;
kp_P  = taus/tau_p*(Svsc/Ib_vsc)/1000; %PSCAD in kA
ki_P  = 1/tau_p*(Svsc/Ib_vsc)/1000; %PSCAD in kA

tau_q   = 0.1;
kp_Q = taus/tau_q*(Svsc/Ib_vsc)/1000; %PSCAD in kA
ki_Q = 1/tau_q*(Svsc/Ib_vsc)/1000; %PSCAD in kA

% %%%%%%%%%%%% NEW GFOL

% P-w droop
tau_droop_f = 1/50;
k_droop_f   = 20;

% V-Q droop
tau_droop_u = 1/50;
k_droop_u   = 50*0.3; 

%% Transformer Impedance
Rtr = 0.002; %pu
Xtr = 0.1; %pu
Ltr = Xtr/wb;
