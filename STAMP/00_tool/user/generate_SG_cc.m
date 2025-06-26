 %% Set names of state variables

num = T_XX.number; %number of the USER element
bus = T_XX.bus;

% Exciter
exc_x1   = ['SG' num2str(bus) '.exc_x1'];
exc_x2   = ['SG' num2str(bus) '.exc_x2'];
exc_filt = ['SG' num2str(bus) '.exc_filtx'];

% Governor
gov_x1   = ['SG' num2str(bus) '.gov_x1'];
gov_x2   = ['SG' num2str(bus) '.gov_x2'];

% Turbine   
turbx    = ['SG' num2str(bus) '.turbx'];

% Electrical
is_q    = ['SG' num2str(bus) '.is_q'];
is_d    = ['SG' num2str(bus) '.is_d'];
ik1_q   = ['SG' num2str(bus) '.ik1_q']; 
ik2_q   = ['SG' num2str(bus) '.ik2_q'];   
ik_d    = ['SG' num2str(bus) '.ik_d'];           
if_d    = ['SG' num2str(bus) '.if_d'];  
we      = ['SG' num2str(bus) '.w']; 
theta   = ['SG' num2str(bus) '.th'];
e_theta   = ['SG' num2str(bus) '.e_th'];
% vk_d    = ['SG' num2str(bus) '.vk_d']; 
% vk1_q   = ['SG' num2str(bus) '.vk1_q']; 
% vk2_q   = ['SG' num2str(bus) '.vk2_q']; 

% Trafo
ig_q    = ['SG' num2str(bus) '.ig_qx'];
ig_d    = ['SG' num2str(bus) '.ig_dx'];

% voltages & currents in grid (global) ref
vnXq = ['NET.vn' num2str(bus) 'q'];    %'NET.vs1_q' 
vnXd = ['NET.vn' num2str(bus) 'd'];    %'NET.vs1_d'
iq   = ['USER' num2str(num) '.iq'];    %'NET.is1_q'
id   = ['USER' num2str(num) '.id'];    %'NET.is1_d'

%% Parameters

    % Element base
    Vb_kV  = T_XX.Vb;       % rated RMS L-L, kV
    Vb     = Vb_kV*1e3;     % rated RMS L-L   
    Ssg = T_XX.Sb*1e6;          % SG rated power  
    run SG_param_tool.m

%% Linearization point

    run lin_point_SG_tool.m            

%% SS_model_pu

% Transformer
k = Sb/Ssg;  
Atr = [-(Rtr)/(Ltr) -w0;
        w0 -(Rtr)/(Ltr)];

Btr = [1/(Ltr*k), 0, -1/(Ltr*k), 0;
    0, 1/(Ltr*k), 0, -1/(Ltr*k)];
     
Ctr = [1, 0;
        0, 1];

Dtr = [0, 0, 0, 0;
       0, 0, 0, 0];
tr_x={ig_q, ig_d};
% tr_x={'ig_qx','ig_dx'};
tr_u={'vsg_q','vsg_d','vg_q','vg_d'};
tr_y={'ig_q','ig_d'};
tr_ss = ss(Atr,Btr,Ctr,Dtr,'StateName',tr_x,'inputname',tr_u,'outputname',tr_y);

% Sum of currents SG snubber
Aisnb = [0];

Bisnb = [0 0 0 0];
     
Cisnb = [0;0];

Disnb = [1 0 -1 0;
        0 1 0 -1];
isnb_x={''};
isnb_u={'isg_q','isg_d','ig_q','ig_d'};
isnb_y={'isn_q','isn_d'};
isnb_ss = ss(Aisnb,Bisnb,Cisnb,Disnb,'StateName', isnb_x,'inputname',isnb_u,'outputname',isnb_y);

% SG snubber
Asnb = [0];

Bsnb = [0 0];
     
Csnb = [0;0];

Dsnb = [Rsnb*k 0;
        0 Rsnb*k];

snb_x={''};
snb_u={'isn_q','isn_d'};
snb_y={'vsg_q','vsg_d'};
snb_ss = ss(Asnb,Bsnb,Csnb,Dsnb,'StateName', snb_x,'inputname',snb_u,'outputname',snb_y);

% Espacio de estados Vsg qd: real -> pu
Avsg_pu=[0 0;0 0];
Bvsg_pu=[0 0; 0 0];
Cvsg_pu=[0 0;0 0];
% Dvsg_pu=[1/(Vb*sqrt(2/3)) 0; 0 1/(Vb*sqrt(2/3))];
% Dvsg_pu=[1/(sqrt(2/3)) 0; 0 1/(sqrt(2/3))];
Dvsg_pu=[1 0; 0 1];

vsg_pu_x={''};
if bus==bus_slk
    vsg_pu_u={'vsg_q','vsg_d'};
else
    vsg_pu_u={'vsg_qg','vsg_dg'};
end
% vsg_pu_u={'vsg_qg','vsg_dg'};
vsg_pu_y={'SG_vsgq_pu','SG_vsgd_pu'};
vsg_pu = ss(Avsg_pu,Bvsg_pu,Cvsg_pu,Dvsg_pu,'StateName',vsg_pu_x,'inputname',vsg_pu_u,'outputname',vsg_pu_y);

% SG voltage magnitude
Avsg=[0];
Bvsg=[0 0];
Cvsg=[0];
Dvsg=[vsgq_g0/sqrt(vsgq_g0^2+vsgd_g0^2) vsgd_g0/sqrt(vsgq_g0^2+vsgd_g0^2)];
vsg_x={''};
% vsg_u={'vsg_qg','vsg_dg'};
vsg_u={'SG_vsgq_pu','SG_vsgd_pu'};
vsg_y={'Vsg_mag'};
vsg = ss(Avsg,Bvsg,Cvsg,Dvsg,'StateName',vsg_x,'inputname',vsg_u,'outputname',vsg_y);

% Exciter filter
[A,B,C,D] = tf2ss(1,[10e-3 1]);
Aexf=A;
Bexf=B;
Cexf=C;
Dexf=D;
exf_x={exc_filt};
% exf_x={'exflt'};
exf_u={'Vsg_mag'};
exf_y={'Vsg_mag_filt'};
exf = ss(Aexf,Bexf,Cexf,Dexf,'StateName',exf_x,'inputname',exf_u,'outputname',exf_y);

% Exciter
s = tf('s');
tfexc = -((Exc.TC*s+1)/(Exc.TB*s+1)*Exc.KA/(Exc.TA*s+1))*Rf_pu/Lmd_pu;
[Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
exc_x={exc_x1, exc_x2};
% exc_x={'Exc1', 'Exc2'};
exc_u={'Vsg_mag_filt'};
exc_y={'SG_vfd'};
exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);

% Governor
Agov = [0 1;-1/(gov.T1*gov.T3) -(gov.T1+gov.T3)/(gov.T1*gov.T3)];
Bgov = [0 0 0;1 1/gov.R -1/gov.R];
Cgov = [1/(gov.T1*gov.T3) gov.T2/(gov.T1*gov.T3)];
Dgov = [0 gov.Dt -gov.Dt];

% gov_x={'SG_Gov1','SG_Gov2'};
gov_x={gov_x1,gov_x2};
gov_u={'SG_Pref','SG_wref','SG_w_pu'};
gov_y={'SG_cv'};
gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);

% Turbine
[At4,Bt4,Ct4,Dt4] = tf2ss(1,[Turb.T4 1]);
[At5,Bt5,Ct5,Dt5] = tf2ss(1,[Turb.T5 1]);
[At6,Bt6,Ct6,Dt6] = tf2ss(1,[Turb.T6 1]);
[At7,Bt7,Ct7,Dt7] = tf2ss(1,[Turb.T7 1]);

turb_t4 = tf(1,[Turb.T4 1]);
turb_t5 = tf(1,[Turb.T5 1]);
turb_t6 = tf(1,[Turb.T6 1]);
turb_t7 = tf(1,[Turb.T7 1]);

turb_tf = turb_t4*(Turb.K1+Turb.K2+turb_t5*(Turb.K3+Turb.K4+turb_t6*(Turb.K5+Turb.K6+turb_t7*(Turb.K7+Turb.K8))));
[Aturb,Bturb,Cturb,Dturb] = tf2ss(turb_tf.num{1},turb_tf.den{1});
for jj = 1:length(Aturb)
    turb_x(jj) = {[turbx num2str(jj)]};
    %turb_x(jj) = {['turbx' num2str(jj)]};
end
turb_u={'SG_cv'};
turb_y={'SG_Pm'};
turb_ss = ss(Aturb,Bturb,Cturb,Dturb,'StateName',turb_x,'inputname',turb_u,'outputname',turb_y);

 % Espacio de estados generador síncrono
R7 = [ -Rs_pu 0 0 0 0 0 0;
         0 -Rs_pu 0 0 0 0 0;
         0 0 Rf_pu 0 0 0 0;
         0 0 0 R1d_pu 0 0 0; 
         0 0 0 0 R1q_pu 0 0;
         0 0 0 0 0 R2q_pu 0;
         0 0 0 0 0 0 0];

 M7 = [-Ll_pu-Lmq_pu 0 0 0 Lmq_pu Lmq_pu; 
     0 -Ll_pu-Lmd_pu Lmd_pu Lmd_pu 0 0; 
     0 -Lmd_pu Lfd_pu+Lmd_pu Lmd_pu 0 0;
     0 -Lmd_pu Lmd_pu L1d_pu+Lmd_pu 0 0;
     -Lmq_pu 0 0 0 L1q_pu+Lmq_pu Lmq_pu;
     -Lmq_pu 0 0 0 Lmq_pu (L2q_pu+Lmq_pu)]/wb;

M7inv = inv(M7);
M7inv(:,7) = zeros(6,1);
M7inv(7,:)= zeros(1,7); 

N7 = [0 -w0_pu*(Ll_pu+Lmd_pu) w0_pu*Lmd_pu w0_pu*Lmd_pu 0 0 (-Ll_pu-Lmd_pu)*isd0+Lmd_pu*ifd0;
      w0_pu*(Ll_pu+Lmq_pu) 0 0 0 -w0_pu*Lmq_pu -w0_pu*Lmq_pu (Ll_pu+Lmq_pu)*isq0; 
      0 0 0 0 0 0 0;
      0 0 0 0 0 0 0;
      0 0 0 0 0 0 0;
      0 0 0 0 0 0 0;
      0 0 0 0 0 0 0];

%To add the mechanical equation to the state space
matA = [zeros(6,7);-(isd0*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0) -(isq0*(Lmq_pu-Lmd_pu)) -isq0*Lmd_pu -isq0*Lmd_pu isd0*Lmq_pu isd0*Lmq_pu -Pm0/(w0_pu^2)]/2/H;
matB = [zeros(6,7);[zeros(1,6),1/(2*H*w0_pu)]];

Asg = [-M7inv*(N7+R7)]+matA;
Bsg = M7inv+matB;
Csg = [eye(7);(isd0*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0) isq0*(Lmq_pu-Lmd_pu) isq0*Lmd_pu isq0*Lmd_pu -isd0*Lmq_pu -isd0*Lmq_pu 0];%;3/2*(isd0*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0+Lmd_pu*ikd0) 3/2*(isq0*(Lmq_pu-Lmd_pu)-ikq0*Lmq_pu) 3/2*isq0*Lmd_pu 3/2*isq0*Lmd_pu -3/2*isd0*Lmq_pu 0 0];
Dsg = zeros(8,7);

%sg_x={'SG_isq', 'SG_isd', 'SG_ifd', 'SG_ikd', 'SG_ikq1', 'SG_ikq2', 'SG_w'};
sg_x={is_q, is_d, if_d, ik_d, ik1_q, ik2_q, we};
sg_u={'SG_vsgq_pu', 'SG_vsgd_pu', 'SG_vfd', 'SG_vkd', 'SG_vkq1', 'SG_vkq2', 'SG_Pm'};
sg_y={'SG_isqg_pu', 'SG_isdg_pu', 'SG_ifd', 'SG_ikd', 'SG_ikq1', 'SG_ikq2', 'SG_w_pu', 'SG_Te'};
sg = ss(Asg,Bsg,Csg,Dsg,'StateName',sg_x,'inputname',sg_u,'outputname',sg_y);


% Change base of SG current: SG pu -> System pu
Aisg_pu=[0 0; 0 0];
Bisg_pu=[0 0; 0 0];
Cisg_pu=[0 0;0 0];
Disg_pu=[Ssg/Sb 0; 0 Ssg/Sb];
% Disg_pu=[Ssg/Sb*sqrt(3/2) 0; 0 Ssg/Sb*sqrt(3/2)];
isg_pu_x={''}; 
if num==num_slk
    isg_pu_u={'SG_isqg_pu','SG_isdg_pu'};
else
    isg_pu_u={'SG_isq_pu','SG_isd_pu'};
end
% isg_pu_u={'SG_isq_pu','SG_isd_pu'};
isg_pu_y={'isg_q','isg_d'};
isg_pu = ss(Aisg_pu,Bisg_pu,Cisg_pu,Disg_pu,'StateName',isg_pu_x,'inputname',isg_pu_u,'outputname',isg_pu_y);

% Espacio de estados wsg: pu -> real
Awsg_pu=[0];
Bwsg_pu=[0];
Cwsg_pu=[0];
Dwsg_pu=[wb];
wsg_pu_x={''};
wsg_pu_u={['SG_w_pu']};
wsg_pu_y={['SG',num2str(bus),'_w']};
wsg_pu = ss(Awsg_pu,Bwsg_pu,Cwsg_pu,Dwsg_pu,'StateName',wsg_pu_x,'inputname',wsg_pu_u,'outputname',wsg_pu_y);

% Espacio de estados angulo 
Aang=[0];
Bang=[1];
Cang=[1];
Dang=[0];
ang_x={theta};
% ang_x={['SG_th']};
ang_u={['SG',num2str(bus),'_w']};
ang_y={['SG_th']};
ang = ss(Aang,Bang,Cang,Dang,'StateName',ang_x,'inputname',ang_u,'outputname',ang_y);

if num~=num_slk
    % Angle different with slack 
    Adang=[0];
    Bdang=[1 -1];
    Cdang=[1];
    Ddang=[0 0];
    dang_x={e_theta};
    % dang_x={'SG_e_th'};
    dang_u={['SG',num2str(bus),'_w'],REF_w};
    dang_y={'SG_e_th'};
    dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
    
    % Reference antitransformation for SG current (local -> global)
    Aigx_g=[0];
    Bigx_g=[0 0 0];
    Cigx_g=[0;0];
    Digx_g=[cos(e_theta0) sin(e_theta0) -sin(e_theta0)*isq0+cos(e_theta0)*isd0;
          -sin(e_theta0) cos(e_theta0) -cos(e_theta0)*isq0-sin(e_theta0)*isd0];
    igx_g_x={''};
    igx_g_u={'SG_isqg_pu','SG_isdg_pu','SG_e_th'};
    igx_g_y={'SG_isq_pu','SG_isd_pu'};
    igx_g = ss(Aigx_g,Bigx_g,Cigx_g,Digx_g,'StateName',igx_g_x,'inputname',igx_g_u,'outputname',igx_g_y);
   
    % Reference transformation for SG voltage (global -> local)
    Avgx_g=[0];
    Bvgx_g=[0 0 0];
    Cvgx_g=[0;0];
    Dvgx_g=[cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*vsgq_0-cos(e_theta0)*vsgd_0;
          sin(e_theta0) cos(e_theta0) cos(e_theta0)*vsgq_0-sin(e_theta0)*vsgd_0];
    vgx_g_x={''};
    vgx_g_u={'vsg_q','vsg_d','SG_e_th'};
    vgx_g_y={'vsg_qg','vsg_dg'};
    vgx_g = ss(Avgx_g,Bvgx_g,Cvgx_g,Dvgx_g,'StateName',vgx_g_x,'inputname',vgx_g_u,'outputname',vgx_g_y);
end

% Build complete model
if num==num_slk 
    input_vars = {'vg_q','vg_d'};
    output_vars = {'ig_q','ig_d',['SG',num2str(bus),'_w']};
    SS_SG = connect(tr_ss,isnb_ss,snb_ss,sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,input_vars,output_vars); %
else
    input_vars = {'vg_q','vg_d',REF_w};
    output_vars = {'ig_q','ig_d',['SG',num2str(bus),'_w']};  
    SS_SG = connect(tr_ss,isnb_ss,snb_ss,sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,dang,vgx_g,igx_g,input_vars,output_vars); 
end

%%  adapt inputs/outputs

SS_SG.InputName(1) = {vnXq};
SS_SG.InputName(2) = {vnXd};

SS_SG.OutputName(1) = {iq};
SS_SG.OutputName(2) = {id};

if num==num_slk
    SS_SG.OutputName(3) = {REF_w};
end
