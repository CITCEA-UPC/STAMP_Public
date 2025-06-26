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
Pref     = ['SG' num2str(bus) '.Pref'];

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

% Omega
w_real  = ['SG',num2str(bus),'_w'];

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
    Ssg    = T_XX.Sb*1e6;          % SG rated power  
    
    T_data = T_pod(T_pod.bus == bus & sum(cell2mat(T_pod.element) == elementName,2),:); %identify bus & element
    run SG_param_tool_POD.m

%% Linearization point

    run lin_point_SG_tool.m            

%% SS_model_pu

s = tf('s');

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
[A,B,C,D] = tf2ss(1,[Exc.TR 1]);
Aexf=A;
Bexf=B;
Cexf=C;
Dexf=D;
exf_x={exc_filt};
% exf_x={'exflt'};
exf_u={'Vsg_mag'};
exf_y={'Vc'};
exf = ss(Aexf,Bexf,Cexf,Dexf,'StateName',exf_x,'inputname',exf_u,'outputname',exf_y);

% Exciter
switch T_data.exc{:}
    case 'ST4B'
        Vsi10 = 0;
        Vsi20 = Pm0*1;
        Vst0  = pss.Ks1*(Vsi10+(pss.Ks3-1)*pss.Ks2*Vsi20);

        Ve0  = sqrt(vsgq_g0^2+vsgd_g0^2)*Exc.KP;
        Ifd0 = ifd0*Lmd_pu;
        fIn0 = 1-0.577*Exc.KC*Ifd0/Ve0;
        %Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1)*Exc.KPR; %no PSS
        Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1 + Vst0)*Exc.KPR; 
        Vb0  = Ve0*fIn0;
        
        % with PSS
        excInput_ss = SS_ERROR('SG_Vst','Vc','V_excInput'); %PSS

        % Exciter block 1
        exc1_1 = tf([Exc.KPR Exc.KIR],[1 0]);
        exc1_2 = tf([1],[Exc.TA 1]);
        exc1_tf = exc1_1*exc1_2;
        [Aexc1,Bexc1,Cexc1,Dexc1] = tf2ss(exc1_tf.num{1,1},exc1_tf.den{1,1});
        exc1_x={['SG',num2str(bus),'_exc1_x1'],['SG',num2str(bus),'_exc1_x2']};
        %exc1_u={'Vc'}; %no PSS
        exc1_u={'V_excInput'};
        exc1_y={'Vm'};
        exc1_ss = ss(Aexc1,Bexc1,Cexc1,Dexc1,'StateName',exc1_x,'inputname',exc1_u,'outputname',exc1_y);

        % Exciter block 2
        exc2_ss = SS_PROD('Vm',Vm0,'Vb',Vb0,'SG_Vfd');

        % Exciter block 3 (base change)
        exc3_ss = SS_GAIN('SG_Vfd','SG_vfd',Rf_pu/Lmd_pu);

        % Exciter block 4
        exc4_ss = SS_PROD('Ve',Ve0,'fIn',fIn0,'Vb');

        % Exciter block 5
        exc5_ss = SS_GAIN('Vsg_mag','Ve',Exc.KP);

        % Exciter block 6
        exc6_ss = SS_PROD('Ve',-Exc.KC*Ifd0/Ve0^2,'SG_Ifd',Exc.KC/Ve0,'In');

        % Exciter block 7
        exc7_ss = SS_GAIN('In','fIn',-0.577);

        % Exciter block 8
        exc8_ss = SS_GAIN('SG_ifd','SG_Ifd',Lmd_pu);

        % Exciter ss
        %exc_u={'Vc','Vsg_mag','SG_ifd'}; %no PSS 
        exc_u={'Vc','Vsg_mag','SG_ifd','SG_Vst'}; %PSS 
        exc_y={'SG_vfd'};
        exc_ss = connect(excInput_ss,exc1_ss,exc2_ss,exc3_ss,exc4_ss,exc5_ss,exc6_ss,exc7_ss,exc8_ss,exc_u,exc_y);
        
    case 'ST1'
%         % with PSS
%         excInput_ss = SS_ERROR('Vc','SG_Vst','V_excInput');
%         tfexc = -((Exc.TC*s+1)/(Exc.TB*s+1)*Exc.KA/(Exc.TA*s+1))*Rf_pu/Lmd_pu;
%         [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
%         exc_x={exc_x1};
%         exc_u={'V_excInput'};
%         exc_y={'SG_vfd'};
%         exc_ss0 = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
%         exc_ss  = connect(excInput_ss,exc_ss0,{'Vc','SG_Vst'},{'SG_vfd'});

        % without PSS
        tfexc = -((Exc.TC*s+1)/(Exc.TB*s+1)*Exc.KA/(Exc.TA*s+1))*Rf_pu/Lmd_pu;
        [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
        exc_x={exc_x1};
        exc_u={'Vc'};
        exc_y={'SG_vfd'};
        exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);

    case 'AC4A'
        tfexc = -((Exc.TC*s+1)/(Exc.TB*s+1)*Exc.KA/(Exc.TA*s+1))*Rf_pu/Lmd_pu;
        [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
        exc_x={exc_x1, exc_x2};
        % exc_x={'Exc1', 'Exc2'};
        exc_u={'Vc'};
        exc_y={'SG_vfd'};
        exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
end

% PSS
    % Vsi1: Rotor speed deviation in [pu]

    % Vsi2: Electrical power [pu] == Te*w 
    Pe_ss    = SS_PROD('SG_Te',Pm0,'SG_w_pu',1,'SG_Pe');

    % PSS block 1
    pss1_1  = tf_WASHOUT(pss.Tw1);
    pss1_2  = tf_WASHOUT(pss.Tw2);
    pss1_3  = tf_LP(1,pss.T6); 
    pss1_tf = pss1_1*pss1_2*pss1_3;
    [Apss1,Bpss1,Cpss1,Dpss1] = tf2ss(pss1_tf.num{1},pss1_tf.den{1});
    pss1_x  = {['SG',num2str(bus),'.pss1_x1'],['SG',num2str(bus),'.pss1_x2']};
    pss1_u  = {'SG_w_pu'};
    pss1_y  = {'SG_Vsi1_out'};
    pss1_ss = ss(Apss1,Bpss1,Cpss1,Dpss1,'StateName',pss1_x,'inputname',pss1_u,'outputname',pss1_y);

    % PSS block 2
    pss2_1  = tf_WASHOUT(pss.Tw3);
    pss2_2  = tf_LP(pss.Ks2,pss.T7);  
    pss2_tf = pss2_1*pss2_2;
    [Apss2,Bpss2,Cpss2,Dpss2] = tf2ss(pss2_tf.num{1},pss2_tf.den{1});
    pss2_x  = {['SG',num2str(bus),'.pss2_x1'],['SG',num2str(bus),'.pss2_x2']};
    pss2_u  = {'SG_Pe'};
    pss2_y  = {'SG_Vsi2_out'};
    pss2_ss = ss(Apss2,Bpss2,Cpss2,Dpss2,'StateName',pss2_x,'inputname',pss2_u,'outputname',pss2_y);
    
    % PSS block 3
    pss3_ss = SS_ADD('SG_Vsi1_out','SG_Vsi2_out','SG_Vsi_sum');

    % PSS block 4
    pss4_tf = (tf([0 1],1)/(tf([0.1 1],1)^pss.M))^pss.N;
    [Apss4,Bpss4,Cpss4,Dpss4] = tf2ss(pss4_tf.num{1},pss4_tf.den{1});
    pss4_x = {};
    for idx = 1:pss.M*pss.N
    pss4_x{end+1} = ['SG',num2str(bus),'.pss4_x' num2str(idx)];
    end
    pss4_u  = {'SG_Vsi_sum'}; 
    pss4_y  = {'SG_Vsi_out'}; 
    pss4_ss = ss(Apss4,Bpss4,Cpss4,Dpss4,'StateName',pss4_x,'inputname',pss4_u,'outputname',pss4_y);
    
    % PSS block 5
    pss5_ss = SS_ERROR('SG_Vsi_out','SG_Vsi2_out','SG_Vst_in');

    % PSS block 6
    pss6_1 = tf_LEAD_LAG(pss.T1,pss.T2);
    pss6_2 = tf_LEAD_LAG(pss.T3,pss.T4);
    pss6_tf = pss.Ks1*pss6_1*pss6_2;
    [Apss6,Bpss6,Cpss6,Dpss6] = tf2ss(pss6_tf.num{1},pss6_tf.den{1});
    pss6_x  = {['SG',num2str(bus),'.pss6_x1'],['SG',num2str(bus),'.pss6_x2']};
    pss6_u  = {'SG_Vst_in'};
    pss6_y  = {'SG_Vst'};
    pss6_ss = ss(Apss6,Bpss6,Cpss6,Dpss6,'StateName',pss6_x,'inputname',pss6_u,'outputname',pss6_y);

pss_ss = connect(Pe_ss,pss1_ss,pss2_ss,pss3_ss,pss4_ss,pss5_ss,pss6_ss,{'SG_w_pu','SG_Te'},{'SG_Vst'});

% Governor
if gov.T1~= 0
    Agov = [0 1;-1/(gov.T1*gov.T3) -(gov.T1+gov.T3)/(gov.T1*gov.T3)];
    Bgov = [0 0 0;1 1/gov.R -1/gov.R];
    Cgov = [1/(gov.T1*gov.T3) gov.T2/(gov.T1*gov.T3)];
    Dgov = [0 gov.Dt -gov.Dt];
    
    gov_x={gov_x1,gov_x2};
    gov_u={Pref,'SG_wref','SG_w_pu'};
    gov_y={'SG_cv'};
    gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);
else
    Agov = [-1/gov.T3];
    Bgov = [1 1/gov.R -1/gov.R];
    Cgov = [1/gov.T3];
    Dgov = [0 gov.Dt -gov.Dt];
    
    gov_x={gov_x1};
    gov_u={Pref,'SG_wref','SG_w_pu'};
    gov_y={'SG_cv'};
    gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);
end

% Turbine
[At4,Bt4,Ct4,Dt4] = tf2ss(1,[Turb.T4 1]);
[At5,Bt5,Ct5,Dt5] = tf2ss(1,[Turb.T5 1]);
[At6,Bt6,Ct6,Dt6] = tf2ss(1,[Turb.T6 1]);
[At7,Bt7,Ct7,Dt7] = tf2ss(1,[Turb.T7 1]);

turb_t4 = tf(1,[Turb.T4 1]);
turb_t5 = tf(1,[Turb.T5 1]);
turb_t6 = tf(1,[Turb.T6 1]);
turb_t7 = tf(1,[Turb.T7 1]);

%turb_tf = turb_t4*(Turb.K1+Turb.K2+turb_t5*(Turb.K3+Turb.K4+turb_t6*(Turb.K5+Turb.K6+turb_t7*(Turb.K7+Turb.K8))));
turb_tf = (Turb.K7+Turb.K8)*(turb_t7*turb_t6*turb_t5*turb_t4)+(Turb.K5+Turb.K6)*(turb_t6*turb_t5*turb_t4)+(Turb.K3+Turb.K4)*(turb_t5*turb_t4)+(Turb.K1+Turb.K2)*(turb_t4);

[Aturb,Bturb,Cturb,Dturb] = tf2ss(turb_tf.num{1},turb_tf.den{1});
clear turb_x
for jj = 1:length(Aturb)
    turb_x(jj) = {[turbx num2str(jj)]};
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
wsg_pu_y={w_real};
wsg_pu = ss(Awsg_pu,Bwsg_pu,Cwsg_pu,Dwsg_pu,'StateName',wsg_pu_x,'inputname',wsg_pu_u,'outputname',wsg_pu_y);

% Espacio de estados angulo 
Aang=[0];
Bang=[1];
Cang=[1];
Dang=[0];
ang_x={theta};
% ang_x={['SG_th']};
ang_u={w_real};
ang_y={['SG_th']};
ang = ss(Aang,Bang,Cang,Dang,'StateName',ang_x,'inputname',ang_u,'outputname',ang_y);

if num~=num_slk
    % Angle different with slack 
    Adang=[0];
    Bdang=[1 -1];
    Cdang=[1];
    Ddang=[0 0];
    dang_x={e_theta};
    dang_u={w_real,REF_w};
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
    input_vars = {'vg_q','vg_d',Pref};
    output_vars = {'ig_q','ig_d',w_real};
    SS_SG = connect(tr_ss,isnb_ss,snb_ss,sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,input_vars,output_vars); %
else
    input_vars = {'vg_q','vg_d',REF_w,Pref};
    output_vars = {'ig_q','ig_d',w_real};  
    if T_data.pss{:}=="yes"
        SS_SG = connect(tr_ss,isnb_ss,snb_ss,sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,dang,vgx_g,igx_g,pss_ss,input_vars,output_vars); 
    else
        SS_SG = connect(tr_ss,isnb_ss,snb_ss,sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,dang,vgx_g,igx_g,input_vars,output_vars); 
    end
end

%%  adapt inputs/outputs

SS_SG.InputName(1) = {vnXq};
SS_SG.InputName(2) = {vnXd};

SS_SG.OutputName(1) = {iq};
SS_SG.OutputName(2) = {id};

if num==num_slk
    SS_SG.OutputName(3) = {REF_w};
end
