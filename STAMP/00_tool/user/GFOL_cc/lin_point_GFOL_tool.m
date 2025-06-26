%% Linearization point for GFOL

Pvsc0  = T_XX.P*(Sb/Svsc);
Qvsc0  = T_XX.Q*(Sb/Svsc);
Vg     = T_XX.V; 
delta0 = T_XX.delta*pi/180; 
w0     = wb;

% Calculation of voltages and currents (REF: NET-POC)
Is       = conj((Pvsc0+1i*Qvsc0)./Vg);  % converter filter current
phi      = atan2(imag(Is),real(Is));    % angle of converter filter current
U        = Vg + Is*(Rtr+1i*Xtr);        % Voltage at capacitor bus
theta_in = atan2(imag(U),real(U));      % angle between POC and capacitor bus

Vc       = U + Is*(Rc+1i*Xc); % voltage applied by the converter
theta_vc = atan2(imag(Vc),real(Vc));

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

% qd VSC current (REF:GLOBAL)
is_q0 = abs(Is).*cos(delta_bus  + phi);
is_d0 = -abs(Is).*sin(delta_bus + phi);

% qd converter voltage (REF:GLOBAL)
vc_q0 = abs(Vc).*cos(delta_bus + theta_vc); 
vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc); 

%% Initial values in qd referenced to VSC REF 

% qd converter voltage (REF:LOCAL)
[vc_qc0,vc_dc0] = rotation_vect(real(Vc),-imag(Vc),theta_in);

% qd VSC-POC voltage (REF:LOCAL)
[u_qc0,u_dc0] = rotation_vect(real(U),-imag(U),theta_in);

% qd VSC-POC voltage (REF:LOCAL)
[is_qc0,is_dc0] = rotation_vect(real(Is),-imag(Is),theta_in);


%% Store linearization point

    lp.is_q0 = is_q0; 
    lp.is_d0 = is_d0;
    lp.u_q0  = u_q0;
    lp.u_d0  = u_d0;
    lp.u_qc0  = u_qc0;
    lp.u_dc0  = u_dc0;
    lp.vc_qc0 = vc_qc0; 
    lp.vc_qd0 = vc_dc0; 
    lp.vg_q0 = vg_q0; 
    lp.vg_d0 = vg_d0; 
    lp.w0_pu = 1;
    lp.w0 = w0; 
    lp.etheta0 = e_theta0 ; 

    lp_GFOL{end+1} = lp;
    clear lp
