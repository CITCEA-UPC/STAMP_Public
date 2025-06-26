%% Linearization point for GFOR


wb = 2*pi*50; 
%===========================================
%Parametros de Saman
% Transformer Impedance
Rtr=0.002;
Ltr=0.3/wb;
Xtr = Ltr*wb;

Rc=0.005;                % Converter grid coupling filter resistance
Lc=0.1/wb;                % Converter grid coupling filter inductance
Xc = Lc*wb;

Cac=0.15/wb;     % Converter grid coupling filter capacitance
Rac=1/(3*10*wb*Cac); 

delta_slk = 0;

%=========================================
% Power flow de la simulacion
Pvsc0  = -0.4995;%T_XX.P*(Sb/Svsc);
Qvsc0  = +0.0289;%T_XX.Q*(Sb/Svsc);
Vg      = 1;%T_XX.V; 
delta0 = 0;%T_XX.delta*pi/180; 
w0     = wb;


% Calculation of voltages and currents
Ig  = conj((Pvsc0+1i*Qvsc0)./Vg); % Transformer current
phi = acos(Pvsc0./sqrt(Pvsc0.^2+Qvsc0.^2)).*sign(Qvsc0./Pvsc0); % Angle of transformer current (respect to POC voltage)
U   = Vg - Ig*(Rtr+1i*Xtr); % Voltage at capacitor bus
theta_in = atan(imag(U)/real(U)); % angle between POC and capacitor bus
% phi = atan(imag(Ig)/real(Ig));
Icap = U/(Rac-1i/(wb*Cac)); % current through capacitor
Is = Ig - Icap; % converter filter current
Vc   = U - Is*(Rc+1i*Xc); % voltage applied by the converter

% Calculate angles
delta_bus = delta0 - delta_slk;            % NET-PCC
e_theta0  = delta0 + theta_in - delta_slk; % VSC-PCC 

%% Initial values in qd referenced to POC

% qd GRID voltage (REF:GLOBAL)
vg_q0 = real(Vg) % Resultado no lineal vg_q0 = 1
vg_d0 = -imag(Vg) % 0
% vg_q0 = abs(Vg).*cos(delta_bus); Sale ok
%vg_d0 = -abs(Vg).*sin(delta_bus); Sale ok

% qd VSC-PCC voltage GLOBAL
u_q0 = real(U); % 0.9923
u_d0 = -imag(U); % -0.1499

% u_q0 = abs(U).*cos(e_theta0); Sale ok
% u_d0 =-abs(U).*sin(e_theta0); Sale ok

% qd TRAFO current GLOBAL
ig_q0 = real(Ig); % 0.4495
ig_d0 = -imag(Ig); % -0.0289

% ig_q0 = abs(Ig).*cos(delta_bus  + phi); Sale ok
% ig_d0 = -abs(Ig).*sin(delta_bus + phi); Cambiado de signo :S

% qd converter current GLOBAL
is_q0 = real(Is); % 0.482
is_d0 = -imag(Is); % -0.1783

% qd converter voltage (REF:GLOBAL)
vc_q0 = real(Vc) % 0.9783  pequeña diferencia. No se por qué
vc_d0 = -imag(Vc) % -0.1995 pequeña diferencia. No se por qué

%% Initial values in local reference
% Local reference is located at capacitor bus

% qd VSC-PCC voltage local
[u_qc0,u_dc0] = rotation_vect(u_q0,u_d0,theta_in)
% u_qc0 = 1.004 (no hay mas decimales xd)
% u_dc0 = 0

% qd TRAFO current GLOBAL
[ig_qc0,ig_dc0] = rotation_vect(ig_q0,ig_d0,theta_in)
% ig_qc0 = 0.4982 
% ig_dc0 = 0.04603

% qd converter current GLOBAL
[is_qc0,is_dc0] = rotation_vect(is_q0,is_d0,theta_in)
% is_qc0 = 0.5032 
% is_dc0 = -0.1043

% qd converter voltage (REF:GLOBAL)
[vc_qc0,vc_dc0] = rotation_vect(vc_q0,vc_d0,theta_in)
% vc_qc0 = 0.9971 
% vc_dc0 = -0.05115

%% Initial values in global reference
% Local reference is located at slack bus

% qd VSC-PCC voltage local
[u_q0,u_d0] = rotation_vect(u_q0,u_d0,-delta_bus) %diria que el angulo positivo aqui

% qd TRAFO current GLOBAL
[ig_q0,ig_d0] = rotation_vect(ig_q0,ig_d0,-delta_bus)

% qd converter current GLOBAL
[is_q0,is_d0] = rotation_vect(is_q0,is_d0,-delta_bus)

% qd converter voltage (REF:GLOBAL)
[vc_q0,vc_d0] = rotation_vect(vc_q0,vc_d0,-delta_bus)
 

%% Store linearization point

    lp.ig_q0 = ig_q0;  
    lp.ig_d0 = ig_d0;  
    lp.is_q0 = is_q0; 
    lp.is_d0 = is_d0;
    lp.u_q0  = u_q0;
    lp.u_d0  = u_d0;
    lp.ucap_q0 = ucap_q0; 
    lp.ucap_d0 = ucap_d0; 
    lp.vc_qc0 = vc_qc0; 
    lp.vc_qd0 = vc_qd0; 
    lp.vg_q0 = vg_q0; 
    lp.vg_d0 = vg_d0; 
    lp.w0_pu = 1;
    lp.w0 = w0; 
    lp.etheta0 = e_theta0 ; 

    lp_GFOR{end+1} = lp;
    clear lp
