 %% Set names of state variables

num = T_XX.number; %number of the USER element
bus = T_XX.bus;

% Frequency droop
fdroop_x1 = ['GFOR' num2str(bus) '.p_filt_x']; 
P_ref     = ['GFOR' num2str(bus) '.P_ref']; 

% Voltage droop
udroop_x1  = ['GFOR' num2str(bus) '.q_filt_x']; 
Q_ref      = ['GFOR' num2str(bus) '.Q_ref']; 

% LC:
is_q   = ['GFOR' num2str(bus) '.is_q']; 
is_d   = ['GFOR' num2str(bus) '.is_d']; 
ucap_q = ['GFOR' num2str(bus) '.ucap_q']; 
ucap_d = ['GFOR' num2str(bus) '.ucap_d']; 

% AC side voltage control:
u_q_x1 = ['GFOR' num2str(bus) '.Ke_u_q'];  
u_d_x2 = ['GFOR' num2str(bus) '.Ke_u_d']; 
u_qc_ref = ['GFOR' num2str(bus) '.u_qc_ref'];
u_dc_ref = ['GFOR' num2str(bus) '.u_dc_ref']; 

% AC side current control
is_q_x1   = ['GFOR' num2str(bus) '.Ke_is_q'];  
is_q_x2   = ['GFOR' num2str(bus) '.Ke_is_d']; 
is_qc_ref = ['GFOR' num2str(bus) '.is_qc_ref'];
is_dc_ref = ['GFOR' num2str(bus) '.is_dc_ref']; 

% omega to angle VSC (1/s)
angle_vsc_x = ['GFOR' num2str(bus) '.angle_vsc_x']; 
w_vsc       = ['GFOR' num2str(bus) '.w']; 

% omega to angle grid (1/s)
etheta_x = ['GFOR' num2str(bus) '.etheta_x']; 

% AC voltage feedforward filter 
f_igd_x1 = ['GFOR' num2str(bus) '.igd_ff_x']; 
f_igq_x1 = ['GFOR' num2str(bus) '.igq_ff_x']; 

% Trafo
ig_q    = ['GFOR' num2str(bus) '.ig_qx'];
ig_d    = ['GFOR' num2str(bus) '.ig_dx'];

% in/out voltages & currents in grid (global) ref
vnXq = ['NET.vn' num2str(bus) 'q'];    
vnXd = ['NET.vn' num2str(bus) 'd'];    
iq   = ['USER' num2str(num) '.iq'];    
id   = ['USER' num2str(num) '.id'];    

% POD
pod_P_x1 = ['GFOR' num2str(bus) '.pod_P_x1']; 
pod_P_x2 = ['GFOR' num2str(bus) '.pod_P_x2']; 
pod_Q_x1 = ['GFOR' num2str(bus) '.pod_Q_x1']; 
pod_Q_x2 = ['GFOR' num2str(bus) '.pod_Q_x2']; 

%% Parameters

    % Element base
    Vb_kV  = T_XX.Vb;       % rated RMS L-L, kV
    Vb     = Vb_kV*1e3;     % rated RMS L-L   
    Svsc   = T_XX.Sb*1e6;     % SG rated power  
    run GFOR_param_tool_POD.m

%% Linearization point

    run lin_point_GFOR_tool.m       

%% State-space VSC pu

% Transforms --------------------------------------------------------------

% if num~=num_slk

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
    
    % REF transform: ig to ig_c
    Aig_g2l = [0];
    Big_g2l = [0 0 0];
    Cig_g2l = [0;0];
    Dig_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*ig_q0-cos(e_theta0)*ig_d0;
              sin(e_theta0) cos(e_theta0) cos(e_theta0)*ig_q0-sin(e_theta0)*ig_d0];
    ig_g2l_x = {''};
    ig_g2l_u = {'ig_q','ig_d' 'e_theta'};
    ig_g2l_y = {'ig_qc','ig_dc'};
    ig_g2l   = ss(Aig_g2l,Big_g2l,Cig_g2l,Dig_g2l,'StateName',ig_g2l_x,'inputname',ig_g2l_u,'outputname',ig_g2l_y);
    
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
              sin(e_theta0) cos(e_theta0)  cos(e_theta0)*u_q0-sin(e_theta0)*u_d0];
    u_g2l_x = {''};
    u_g2l_u = {'u_q','u_d' 'e_theta'};
    u_g2l_y = {'u_qc','u_dc'};
    u_g2l   = ss(Au_g2l,Bu_g2l,Cu_g2l,Du_g2l,'StateName',u_g2l_x,'inputname',u_g2l_u,'outputname',u_g2l_y);

% else
% 
% %     % REF INVERSE transform: vc_c to vc
% %     Avc_l2g  = [0 0; 0 0];
% %     Bvc_l2g  = [0 0; 0 0];
% %     Cvc_l2g  = [0 0; 0 0];
% %     Dvc_l2g  = [1 0; 0 1];
% %     vc_l2g_x = {''};
% %     vc_l2g_u = {'vc_qc','vc_dc' 'e_theta'};
% %     vc_l2g_y = {'vc_q','vc_d'};
% %     vc_l2g   = ss(Avc_l2g,Bvc_l2g,Cvc_l2g,Dvc_l2g,'StateName',vc_l2g_x,'inputname',vc_l2g_u,'outputname',vc_l2g_y);
% 
% end

% % Change base of current: VSC pu -> System pu
% Asys_pu=[0 0; 0 0];
% Bsys_pu=[0 0; 0 0];
% Csys_pu=[0 0;0 0];
% Dsys_pu=[Svsc/Sb 0; 0 Svsc/Sb];
% sys_pu_x={''}; 
% sys_pu_u={'SG_isq_pu','SG_isd_pu'};
% sys_pu_y={'isg_q','isg_d'};
% sys_pu = ss(Asys_pu,Bsys_pu,Csys_pu,Dsys_pu,'StateName',sys_pu_x,'inputname',sys_pu_u,'outputname',sys_pu_y);


% Change base of current: VSC pu -> System pu
Avsc_pu=[0 0; 0 0];
Bvsc_pu=[0 0; 0 0];
Cvsc_pu=[0 0;0 0];
Dvsc_pu=[Svsc/Sb 0; 0 Svsc/Sb];
vsc_pu_x={''}; 
vsc_pu_u={'ig_q','ig_d'};
vsc_pu_y={iq, id};
vsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vsc_pu_x,'inputname',vsc_pu_u,'outputname',vsc_pu_y);

% -------------------------------------------------------------------------

% Transformer 
Atr = [-(Rtr)/(Ltr) -w0;
        w0 -(Rtr)/(Ltr)];
Btr = [1/(Ltr), 0, -1/(Ltr), 0;
       0, 1/(Ltr), 0, -1/(Ltr)];    
Ctr = [1, 0;
        0, 1];
Dtr = [0, 0, 0, 0;
       0, 0, 0, 0];
tr_x = {ig_q, ig_d};
tr_u = {'u_q','u_d','vg_q','vg_d'};
tr_y = {'ig_q','ig_d'};
tr_ss = ss(Atr,Btr,Ctr,Dtr,'StateName',tr_x,'inputname',tr_u,'outputname',tr_y);

if num~=num_slk
    % Angle deviation from system reference
    Adang=[0];
    Bdang=[1 -1];
    Cdang=[1];
    Ddang=[0 0];
    dang_x={etheta_x};
    dang_u={w_vsc,REF_w};
    dang_y={'e_theta'};
    dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
else
    % Angle deviation from system reference (if slack)
    Adang=[0];
    Bdang=[1];
    Cdang=[0];
    Ddang=[0];
    dang_x={etheta_x};
    dang_u={w_vsc};
    dang_y={'e_theta'};
    dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
end

% Frequency droop with low-pass filter in Pac:
Afdroop_n1=[-1/tau_droop_f];
% Bfdroop_n1=[0 3*ig_q0/2 3*ig_d0/2 3*u_q0_n1/2 3*u_d0_n1/2]
Bfdroop_n1=[0 ig_q0 ig_d0 u_q0 u_d0];
Cfdroop_n1=[-k_droop_f/tau_droop_f*wb];
Dfdroop_n1=[+k_droop_f*wb 0 0 0 0];
fdroop_n1_x={fdroop_x1};
fdroop_n1_u={P_ref 'u_q' 'u_d' 'ig_q' 'ig_d'};
fdroop_n1_y={w_vsc};
fdroop_n1 = ss(Afdroop_n1,Bfdroop_n1,Cfdroop_n1,Dfdroop_n1,'StateName',fdroop_n1_x,'inputname',fdroop_n1_u,'outputname',fdroop_n1_y);


% Voltage droop with low-pass filter in Qac:
Audroop_n1=[-1/tau_droop_u];
%Budroop_n1=[0 -3*ig_d0/2 3*ig_q0/2 3*u_d0_n1/2 -3*u_q0_n1/2];
Budroop_n1=[0 -ig_d0 ig_q0 u_d0 -u_q0];
Cudroop_n1=[k_droop_u/tau_droop_u];
Dudroop_n1=[+k_droop_u 0 0 0 0];
udroop_n1_x={udroop_x1};
udroop_n1_u={Q_ref 'u_q' 'u_d' 'ig_q' 'ig_d'};
udroop_n1_y={u_qc_ref};
udroop_n1 = ss(Audroop_n1,Budroop_n1,Cudroop_n1,Dudroop_n1,'StateName',udroop_n1_x,'inputname',udroop_n1_u,'outputname',udroop_n1_y);


% LC:
Alc_n1 =  [(-Rc-Rac)/Lc -wb -1/Lc 0;
           wb (-Rc-Rac)/Lc 0 -1/Lc;
           1/Cac 0 0 -wb;
           0 1/Cac wb 0];
Blc_n1 =  [1/Lc 0 Rac/Lc 0 -is_d0; %maybe ido??
           0 1/Lc 0 Rac/Lc +is_q0;
           0 0 -1/Cac 0 -ucap_d0; 
           0 0 0 -1/Cac +ucap_q0];
Clc_n1  = [1 0 0 0;
           0 1 0 0;
           Rac 0 1 0;
           0 Rac 0 1];
Dlc_n1 =  [0 0 0 0 0;
           0 0 0 0 0;
           0 0 -Rac 0 0;
           0 0 0 -Rac 0];
lc_x    = {is_q is_d ucap_q ucap_d};
if num~=num_slk
    lc_n1_u = {'vc_q' 'vc_d' 'ig_q' 'ig_d' REF_w};
else
    lc_n1_u = {'vc_q' 'vc_d' 'ig_q' 'ig_d' w_vsc};
end
lc_n1_y = {is_q is_d 'u_q' 'u_d'};
Lc_ss = ss(Alc_n1,Blc_n1,Clc_n1,Dlc_n1,'StateName',lc_x,'inputname',lc_n1_u,'outputname',lc_n1_y);

% AC side voltage control:
Au_n1  = [0 0;
          0 0];
Bu_n1  = [1 0 -1 0 0 0;
          0 1 0 -1 0 0];
Cu_n1  = [+ki_vac 0;
          0 +ki_vac];
Du_n1  = [+kp_vac 0 -kp_vac +wb*Cac 1 0;
          0 +kp_vac -wb*Cac -kp_vac 0 1];
u_n1_x = {u_q_x1, u_d_x2};
u_n1_u = {u_qc_ref,u_dc_ref,'u_qc','u_dc','ig_qc_f','ig_dc_f'};
u_n1_y = {is_qc_ref ,is_dc_ref};
u_n1   = ss(Au_n1,Bu_n1,Cu_n1,Du_n1,'StateName',u_n1_x,'inputname',u_n1_u,'outputname',u_n1_y);

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
is_n1_u = {is_qc_ref  is_dc_ref 'is_qc' 'is_dc' 'u_qc_f' 'u_dc_f'};
is_n1_y = {'vc_qc' 'vc_dc'};
is_n1   = ss(Ais_n1,Bis_n1,Cis_n1,Dis_n1,'StateName',is_n1_x,'inputname',is_n1_u,'outputname',is_n1_y);


% AC voltage feedforward filter 
num_ig=1;
den_ig=[tau_ig 1];
[Af_ig,Bf_ig,Cf_ig,Df_ig]=tf2ss(num_ig,den_ig);
f_igd_x={f_igd_x1};
f_igd_u={'ig_dc'};
f_igd_y={'ig_dc_f'};
f_igd = ss(Af_ig,Bf_ig,Cf_ig,Df_ig,'StateName',f_igd_x,'inputname',f_igd_u,'outputname',f_igd_y);

f_igq_x={f_igq_x1};
f_igq_u={'ig_qc'};
f_igq_y={'ig_qc_f'};
f_igq = ss(Af_ig,Bf_ig,Cf_ig,Df_ig,'StateName',f_igq_x,'inputname',f_igq_u,'outputname',f_igq_y);

% current feedforward filter 
num_u=1;
den_u=1;
[Af_u,Bf_u,Cf_u,Df_u]=tf2ss(num_u,den_u);
f_ud_x={''};
f_ud_u={'u_dc'};
f_ud_y={'u_dc_f'};
f_ud = ss(Af_u,Bf_u,Cf_u,Df_u,'StateName',f_ud_x,'inputname',f_ud_u,'outputname',f_ud_y);

f_uq_x={''};
f_uq_u={'u_qc'};
f_uq_y={'u_qc_f'};
f_uq = ss(Af_u,Bf_u,Cf_u,Df_u,'StateName',f_uq_x,'inputname',f_uq_u,'outputname',f_uq_y);

% POD control P
% AC voltage feedforward filter 
num_pod_P = [-Tpw*Kpod_P/wb 0];
den_pod_P = [Tpw*Tpf Tpw+Tpf 1];
[A_pod_P,B_pod_P,C_pod_P,D_pod_P]=tf2ss(num_pod_P,den_pod_P);
pod_P_x={pod_P_x1,pod_P_x2};
pod_P_u={w_vsc};
pod_P_y={P_ref};
pod_P = ss(A_pod_P,B_pod_P,C_pod_P,D_pod_P,'StateName',pod_P_x,'inputname',pod_P_u,'outputname',pod_P_y);

% POD control Q
% AC voltage feedforward filter 
num_pod_Q = [Tqw*Kpod_Q/wb 0];
den_pod_Q = [Tqw*Tqf Tqw+Tqf 1];
[A_pod_Q,B_pod_Q,C_pod_Q,D_pod_Q]=tf2ss(num_pod_Q,den_pod_Q);
pod_Q_x={pod_Q_x1,pod_Q_x2};
pod_Q_u={w_vsc};
pod_Q_y={Q_ref};
pod_Q = ss(A_pod_Q,B_pod_Q,C_pod_Q,D_pod_Q,'StateName',pod_Q_x,'inputname',pod_Q_u,'outputname',pod_Q_y);

% Build complete model
if num==num_slk 
    input_vars = {'vg_q','vg_d'};
else
    input_vars = {'vg_q','vg_d',REF_w};
end

output_vars = {iq,id,w_vsc}; 

SS_GFOR = connect(vc_l2g,ig_g2l,is_g2l,u_g2l,vsc_pu,tr_ss,dang,fdroop_n1,udroop_n1,Lc_ss,u_n1,is_n1,f_igd,f_igq,f_ud,f_uq,pod_P,pod_Q,input_vars,output_vars); 


%%  adapt inputs/outputs

SS_GFOR.InputName(1) = {vnXq};
SS_GFOR.InputName(2) = {vnXd};

if num==num_slk
    SS_GFOR.OutputName(3) = {REF_w};
end

