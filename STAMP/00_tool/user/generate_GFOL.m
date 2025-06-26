 %% Set names of state variables

num = T_XX.number; %number of the USER element
bus = T_XX.bus;

% Frequency droop
fdroop_x     = ['GFOL' num2str(bus) '.w_filt_x']; 
P_ref         = ['GFOL' num2str(bus) '.P_ref']; 
omega_ref     = ['GFOL' num2str(bus) '.omega_ref']; 

% Voltage droop
udroop_x   = ['GFOL' num2str(bus) '.q_filt_x']; 
Q_ref      = ['GFOL' num2str(bus) '.Q_ref']; 
Umag_ref   = ['GFOL' num2str(bus) '.Umag_ref']; 

% LC:
is_q   = ['GFOL' num2str(bus) '.is_q']; 
is_d   = ['GFOL' num2str(bus) '.is_d']; 

% Power control:
p_x = ['GFOL' num2str(bus) '.Ke_P'];  
q_x = ['GFOL' num2str(bus) '.Ke_Q']; 

% AC side current control
is_q_x1   = ['GFOL' num2str(bus) '.Ke_is_q'];  
is_q_x2   = ['GFOL' num2str(bus) '.Ke_is_d']; 
is_qc_ref = ['GFOL' num2str(bus) '.is_qc_ref'];
is_dc_ref = ['GFOL' num2str(bus) '.is_dc_ref']; 

% omega to angle VSC (1/s)
angle_vsc_x = ['GFOL' num2str(bus) '.angle_vsc_x']; 
w_vsc       = ['GFOL' num2str(bus) '.w']; 

% PLL
pll_x       = ['GFOL' num2str(bus) '.pll_x']; 

% omega to angle grid (1/s)
etheta_x = ['GFOL' num2str(bus) '.etheta_x']; 

% in/out voltages & currents in grid (global) ref
vnXq = ['NET.vn' num2str(bus) 'q'];    
vnXd = ['NET.vn' num2str(bus) 'd'];    
iq   = ['USER' num2str(num) '.iq'];    
id   = ['USER' num2str(num) '.id'];    

%% Parameters

    % Element base
    Vb_kV  = T_XX.Vb;       % rated RMS L-L, kV
    Vb     = Vb_kV*1e3;     % rated RMS L-L    
    Svsc = T_XX.Sb*1e6;          % SG rated power  
    run GFOL_param_tool.m

%% Linearization point

    run lin_point_GFOL_tool.m       

%% State-space VSC pu

% Transforms --------------------------------------------------------------

% REF INVERSE transform: vc_c to vc
Avc_l2g  = [0];
Bvc_l2g  = [0 0 0];
Cvc_l2g  = [0;0];
Dvc_l2g  = [cos(e_theta0) sin(e_theta0) -sin(e_theta0)*vc_qc0+cos(e_theta0)*vc_dc0;
           -sin(e_theta0) cos(e_theta0) -cos(e_theta0)*vc_qc0-sin(e_theta0)*vc_dc0];
vc_l2g_x = {''};
vc_l2g_u = {'vc_qc','vc_dc' 'e_theta'};
vc_l2g_y = {'vc_q','vc_d'};
vc_l2g   = ss(Avc_l2g,Bvc_l2g,Cvc_l2g,Dvc_l2g,'StateName',vc_l2g_x,'inputname',vc_l2g_u,'outputname',vc_l2g_y);

% REF transform: is to is_c
Ais_g2l = [0];
Bis_g2l = [0 0 0];
Cis_g2l = [0;0];
Dis_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*is_q0-cos(e_theta0)*is_d0;
          sin(e_theta0) cos(e_theta0) cos(e_theta0)*is_q0-sin(e_theta0)*is_d0];
is_g2l_x = {''};
is_g2l_u = {is_q is_d 'e_theta'};
is_g2l_y = {'is_qc' 'is_dc'};
is_g2l   = ss(Ais_g2l,Bis_g2l,Cis_g2l,Dis_g2l,'StateName',is_g2l_x,'inputname',is_g2l_u,'outputname',is_g2l_y);

% REF transform: u to u_c
Au_g2l = [0];
Bu_g2l = [0 0 0];
Cu_g2l = [0;0];
Du_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*u_q0-cos(e_theta0)*u_d0;
          sin(e_theta0) cos(e_theta0) cos(e_theta0)*u_q0-sin(e_theta0)*u_d0];
u_g2l_x = {''};
u_g2l_u = {'u_q','u_d' 'e_theta'};
u_g2l_y = {'u_qc','u_dc'};
u_g2l   = ss(Au_g2l,Bu_g2l,Cu_g2l,Du_g2l,'StateName',u_g2l_x,'inputname',u_g2l_u,'outputname',u_g2l_y);

% Change base of current: VSC pu -> System pu
Avsc_pu=[0 0; 0 0];
Bvsc_pu=[0 0; 0 0];
Cvsc_pu=[0 0;0 0];
Dvsc_pu=[Svsc/Sb 0; 0 Svsc/Sb];
vsc_pu_x={''}; 
vsc_pu_u={is_q,is_d};
vsc_pu_y={iq, id};
vsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vsc_pu_x,'inputname',vsc_pu_u,'outputname',vsc_pu_y);

% -------------------------------------------------------------------------

% PLL:
Apll_n1=[0];
Bpll_n1=[1];
Cpll_n1=[-ki_pll];
Dpll_n1=[-kp_pll];
pll_n1_x={pll_x};
pll_n1_u={'u_dc'};
pll_n1_y={w_vsc};
pll_n1 = ss(Apll_n1,Bpll_n1,Cpll_n1,Dpll_n1,'StateName',pll_n1_x,'inputname',pll_n1_u,'outputname',pll_n1_y);

% Angle deviation from system reference
Adang=[0];
Bdang=[1 -1];
Cdang=[1];
Ddang=[0 0];
dang_x={etheta_x};
dang_u={w_vsc,REF_w};
dang_y={'e_theta'};
dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);

% Frequency droop with low-pass filter on omega:
Afdroop_n1=[-1/tau_droop_f];
Bfdroop_n1=[0 1];
Cfdroop_n1=[-k_droop_f/tau_droop_f/wb];
Dfdroop_n1=[+k_droop_f/wb 0];
fdroop_n1_x={fdroop_x};
fdroop_n1_u={omega_ref w_vsc};
fdroop_n1_y={P_ref};
fdroop_n1 = ss(Afdroop_n1,Bfdroop_n1,Cfdroop_n1,Dfdroop_n1,'StateName',fdroop_n1_x,'inputname',fdroop_n1_u,'outputname',fdroop_n1_y);

% voltage magnitude
Au_n1   = [0];
Bu_n1   = [0 0];
Cu_n1   = [0];
Du_n1   = [u_q0/(sqrt(u_q0^2+u_d0^2)) u_d0/(sqrt(u_q0^2+u_d0^2))];
Au_n1_x = {''};
Au_n1_u = {'u_q' 'u_d'};
Au_n1_y = {'Umag'};
u_n1 = ss(Au_n1,Bu_n1,Cu_n1,Du_n1,'StateName',Au_n1_x,'inputname',Au_n1_u,'outputname',Au_n1_y);

% Voltage droop with low-pass filter in v:
Audroop_n1  = [-1/tau_droop_u];
Budroop_n1  = [0 1];
Cudroop_n1  = [-k_droop_u/tau_droop_u];
Dudroop_n1  = [+k_droop_u 0];
udroop_n1_x = {udroop_x};
udroop_n1_u = {Umag_ref 'Umag'};
udroop_n1_y = {Q_ref};
udroop_n1   = ss(Audroop_n1,Budroop_n1,Cudroop_n1,Dudroop_n1,'StateName',udroop_n1_x,'inputname',udroop_n1_u,'outputname',udroop_n1_y);

% P control
Ap_n1=[0];
Bp_n1=[1 -u_q0 -u_d0 -is_q0 -is_d0]; 
Cp_n1=[ki_P];
Dp_n1=[kp_P -u_q0*kp_P -u_d0*kp_P -is_q0*kp_P -is_d0*kp_P];
p_n1_x={p_x};
p_n1_u={P_ref is_q is_d 'u_q' 'u_d'};
p_n1_y={is_qc_ref};
p_n1 = ss(Ap_n1,Bp_n1,Cp_n1,Dp_n1,'StateName',p_n1_x,'inputname',p_n1_u,'outputname',p_n1_y);

% Q control
Aq_n1=[0];
Bq_n1=[1 u_d0 -u_q0 -is_d0 is_q0];
Cq_n1=[ki_Q];
Dq_n1=[kp_Q u_d0*kp_Q -u_q0*kp_Q -is_d0*kp_Q +is_q0*kp_Q];
q_n1_x={q_x};
q_n1_u={Q_ref is_q is_d 'u_q' 'u_d'};
q_n1_y={is_dc_ref};
q_n1 = ss(Aq_n1,Bq_n1,Cq_n1,Dq_n1,'StateName',q_n1_x,'inputname',q_n1_u,'outputname',q_n1_y);

% AC side current control
Ais_n1 = [0 0;
          0 0];
Bis_n1 = [1 0 -1 0 0 0;
          0 1 0 -1 0 0];
Cis_n1 = [+ki_s 0;
          0 +ki_s];
Dis_n1 = [+kp_s 0     -kp_s  +wb*Lc 1 0;
          0     +kp_s -wb*Lc -kp_s  0 1];
is_n1_x = {is_q_x1 is_q_x2};
is_n1_u = {is_qc_ref  is_dc_ref 'is_qc' 'is_dc' 'u_qc' 'u_dc'};
is_n1_y = {'vc_qc' 'vc_dc'};
is_n1   = ss(Ais_n1,Bis_n1,Cis_n1,Dis_n1,'StateName',is_n1_x,'inputname',is_n1_u,'outputname',is_n1_y);

% plant: RL filter and trafo

Arl_n1=[-(Rc+Rtr)/(Lc+Ltr) -wb;
             wb -(Rc+Rtr)/(Lc+Ltr)];
Brl_n1=[+1/(Lc+Ltr) 0 -1/(Lc+Ltr) 0;
             0 +1/(Lc+Ltr) 0 -1/(Lc+Ltr)];
Crl_n1=[1 0;
             0 1;
             (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr) 0;
             0 (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr)];
Drl_n1=[0 0 0 0;
             0 0 0 0;
         	 Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr) 0;
             0 Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr)];
rl_n1_x={is_q is_d};
rl_n1_u={'vc_q' 'vc_d' 'vg_q' 'vg_d'};
rl_n1_y={is_q is_d 'u_q' 'u_d'};
rl_n1 = ss(Arl_n1,Brl_n1,Crl_n1,Drl_n1,'StateName',rl_n1_x,'inputname',rl_n1_u,'outputname',rl_n1_y);



% Build complete model
input_vars = {'vg_q','vg_d',REF_w};
output_vars = {iq,id,w_vsc};  

SS_GFOL = connect(vc_l2g,is_g2l,u_g2l,vsc_pu,pll_n1,dang,fdroop_n1,u_n1,udroop_n1,p_n1,q_n1,is_n1,rl_n1,input_vars,output_vars); 


%%  adapt inputs/outputs

SS_GFOL.InputName(1) = {vnXq};
SS_GFOL.InputName(2) = {vnXd};

