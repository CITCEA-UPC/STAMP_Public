%% Linearization point for GFOR

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
Icap     = U/(Rac-1i/(wb*Cac)); % current through capacitor
Is       = Ig + Icap; % converter filter current
phi_is   = atan2(imag(Is),real(Is));
Vc       = U + Is*(Rc+1i*Xc); % voltage applied by the converter
theta_vc = atan2(imag(Vc),real(Vc));
Ucap     = U - Rac*Icap;
theta_ucap = atan2(imag(Ucap),real(Ucap));

% Calculate angles
delta_bus = delta0 - delta_slk;            % NET-POC
e_theta0  = delta0 + theta_in - delta_slk; % VSC-POC 

%% Initial values in qd referenced to GLOBAL REF (add delta_bus: delta0-delta_slk)

% qd GRID voltage (REF:GLOBAL)
vg_q0 = abs(Vg).*cos(delta_bus);
vg_d0 = -abs(Vg).*sin(delta_bus);

% qd VSC-PCC voltage (REF:GLOBAL)
u_q0 = abs(U).*cos(e_theta0);
u_d0 = -abs(U).*sin(e_theta0);

% qd TRAFO current (REF:GLOBAL)
ig_q0 = abs(Ig).*cos(delta_bus  + phi);
ig_d0 = -abs(Ig).*sin(delta_bus + phi);

% VSC current (REF:GLOBAL)
is_q0 = abs(Is).*cos(delta_bus  + phi_is);
is_d0 = -abs(Is).*sin(delta_bus + phi_is);

% qd converter voltage (REF:GLOBAL)
vc_q0 = abs(Vc).*cos(delta_bus + theta_vc); % 0.9783  pequeña diferencia. No se por qué
vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc); % -0.1995 pequeña diferencia. No se por qué

% Capacitor voltage GLOBAL
ucap_q0 = abs(Ucap).*cos(delta_bus + theta_ucap);
ucap_d0 = -abs(Ucap).*sin(delta_bus + theta_ucap);

%% Initial values in qd referenced to VSC REF 

% qd converter voltage (REF:LOCAL)
[vc_qc0,vc_dc0] = rotation_vect(real(Vc),-imag(Vc),theta_in);

% qd VSC-POC voltage (REF:LOCAL)
[u_qc0,u_dc0] = rotation_vect(real(U),-imag(U),theta_in);

% qd VSC-POC voltage (REF:LOCAL)
[is_qc0,is_dc0] = rotation_vect(real(Is),-imag(Is),theta_in);


%% From PSCAD
% 
% ig_q0 = data_PSCAD.Iq1(find(data_PSCAD.time>=tstep-0.01,1)); 
% ig_d0 = data_PSCAD.Id1(find(data_PSCAD.time>=tstep-0.01,1)); 
% vg_q0 = data_PSCAD.Uq1(find(data_PSCAD.time>=tstep-0.01,1)); 
% vg_d0 = data_PSCAD.Ud1(find(data_PSCAD.time>=tstep-0.01,1)); 
% u_q0 = data_PSCAD.uqc(find(data_PSCAD.time>=tstep-0.01,1))/(230*sqrt(2/3));
% u_d0 = data_PSCAD.udc(find(data_PSCAD.time>=tstep-0.01,1))/(230*sqrt(2/3));
% is_q0 = data_PSCAD.isqc(find(data_PSCAD.time>=tstep-0.01,1));
% is_d0 = data_PSCAD.isdc(find(data_PSCAD.time>=tstep-0.01,1));

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
    lp.vc_qd0 = vc_dc0; 
    lp.vg_q0 = vg_q0; 
    lp.vg_d0 = vg_d0; 
    lp.w0_pu = 1;
    lp.w0 = w0; 
    lp.etheta0 = e_theta0 ; 

    lp_GFOR{end+1} = lp;
    clear lp
