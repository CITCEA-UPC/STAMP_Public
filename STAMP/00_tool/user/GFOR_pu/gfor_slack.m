%% GFOR as slack

%% Parameters

    Svsc = T_XX.Sb*1e6;          % SG rated power  
    run GFOR_param_tool.m

%% Delta slack

Pvsc0  = T_XX.P*(Sb/Svsc);
Qvsc0  = T_XX.Q*(Sb/Svsc);
Vg     = T_XX.V; 
delta0 = T_XX.delta*pi/180; 
w0     = wb;

% Calculation of voltages and currents (REF: NET-POC)
Ig       = conj((Pvsc0+1i*Qvsc0)./Vg); % Transformer current
phi      = atan2(imag(Ig),real(Ig)); % angle of transformer current
U        = Vg + Ig*(Rtr+1i*Xtr); % Voltage at capacitor bus
theta_in = atan2(imag(U),real(U)); % angle between POC and capacitor bus

% Calculate angles
delta_slk = theta_in; 


