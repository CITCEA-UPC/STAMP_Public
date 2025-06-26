% GENERATE STATE-SPACE MODEL OF SYNCHRONOUS GENERATOR IN PU
% SG base: peak phase-to-ground
% System base: rms line-to-line

function l_blocks = generate_SG_pu(l_blocks,T_SG, lp_SG, T_global, num_slk, element_slk, REF_w)

    s = tf('s');
    
    for sg = 1:1:size(T_SG.bus,1) 
    
        ss_list = {};
        
        % Set names of state variables, inputs and outputs
        
        num = T_SG.number(sg); 
        bus = T_SG.bus(sg);
        area = T_SG.Area(sg);
        syncarea = T_SG.SyncArea(sg);
        
        % Exciter
        exc_x1   = ['SG' num2str(num) '.exc_x1'];
        exc_x2   = ['SG' num2str(num) '.exc_x2'];
        exc_filt = ['SG' num2str(num) '.exc_filtx'];
        
        % Governor
        gov_x1   = ['SG' num2str(num) '.gov_x1'];
        gov_x2   = ['SG' num2str(num) '.gov_x2'];
        Pref     = ['SG' num2str(num) '.Pref'];
        
        % Turbine   
        turbx    = ['SG' num2str(num) '.turbx'];
        
        % Electrical
        is_q    = ['SG' num2str(num) '.is_q'];
        is_d    = ['SG' num2str(num) '.is_d'];
        ik1_q   = ['SG' num2str(num) '.ik1_q']; 
        ik2_q   = ['SG' num2str(num) '.ik2_q'];   
        ik_d    = ['SG' num2str(num) '.ik_d'];           
        if_d    = ['SG' num2str(num) '.if_d'];  
        we_pu   = ['SG' num2str(num) '.w_pu']; 
        theta   = ['SG' num2str(num) '.th'];
        e_theta = ['SG' num2str(num) '.e_th'];
        Te      = ['SG' num2str(num) '.Te'];
        vk_d    = ['SG' num2str(num) '.vk_d']; 
        vk1_q   = ['SG' num2str(num) '.vk1_q']; 
        vk2_q   = ['SG' num2str(num) '.vk2_q']; 
        vf_d    = ['SG' num2str(num) '.vfd'];

        vsgq_pu = ['SG' num2str(num) '.vsgq_pu']; 
        vsgd_pu = ['SG' num2str(num) '.vsgd_pu'];  


        % Omega
        w_real  = ['SG',num2str(num),'.w'];
        
        % Trafo
        ig_q    = ['SG' num2str(num) '.ig_qx'];
        ig_d    = ['SG' num2str(num) '.ig_dx'];
        
        % voltages & currents in grid (global) ref
        vnXq = ['NET.vn' num2str(bus) 'q'];    
        vnXd = ['NET.vn' num2str(bus) 'd'];  
        iq   = ['SG' num2str(num) '.iq'];   
        id   = ['SG' num2str(num) '.id'];    
        
        %% Parameters
        
            Ssg  = T_SG.Sb(sg);       % SG rated power, SG power base  
            Sb   = T_global.Sb(T_global.Area == T_SG.Area(sg)); % System power base
            Zl2g = T_SG.Zbpu_l2g(sg);
            Sl2g = T_SG.Sbpu_l2g(sg);
            Vl2g = T_SG.Vbpu_l2g(sg);
            Vg2l = 1/(Vl2g*sqrt(3)/sqrt(2));
            Il2g = T_SG.Ibpu_l2g(sg);
            wb   = T_SG.wb(sg);
    
            Rtr    = T_SG.Rtr(sg);
            Ltr    = T_SG.Ltr(sg);
            Rsnb   = T_SG.Rsnb(sg);
            Rs_pu  = T_SG.Rs(sg);
            Rf_pu  = T_SG.Rf_pu(sg);
            R1d_pu = T_SG.R1d_pu(sg);
            R1q_pu = T_SG.R1q_pu(sg);
            R2q_pu = T_SG.R2q_pu(sg);
            Ll_pu  = T_SG.Ll_pu(sg);
            Lmq_pu = T_SG.Lmq_pu(sg);
            Lmd_pu = T_SG.Lmd_pu(sg);  
            L1q_pu = T_SG.L1q_pu(sg);
            L2q_pu = T_SG.L2q_pu(sg);
            L1d_pu = T_SG.L1d_pu(sg);
            Lfd_pu = T_SG.Lfd_pu(sg);
    
            H    = T_SG.H(sg);
            exc  = T_SG.exc{sg};
            mech = T_SG.mech{sg};
            pss  = T_SG.PSS{sg};
        
        %% Linearization point
              
            % Initial values for linear model 
            isq0    = lp_SG{sg}.isq0;  
            isd0    = lp_SG{sg}.isd0; 
            ifd0    = lp_SG{sg}.ifd0; 
            ikd0    = lp_SG{sg}.ikd0;
            ikq10   = lp_SG{sg}.ikq10;
            ikq20   = lp_SG{sg}.ikq20;
            vq0     = lp_SG{sg}.vq0; 
            vd0     = lp_SG{sg}.vd0; 
            vsgq_g0 = lp_SG{sg}.vsg_q0; 
            vsgd_g0 = lp_SG{sg}.vsg_d0; 
            w0_pu   = lp_SG{sg}.w0_pu;
            w0      = lp_SG{sg}.w0;
            e_theta0 = lp_SG{sg}.etheta0;
            Pm0     = lp_SG{sg}.Pm0;
            Efd0 = lp_SG{sg}.Efd0;
        
    %%  Trafo and Snubber
        
        % Transformer  
        Atr =   [-(Rtr)/(Ltr) -w0;
                w0 -(Rtr)/(Ltr)];        
        Btr =   [1/(Ltr*Zl2g), 0, -1/(Ltr*Zl2g), 0;
                0, 1/(Ltr*Zl2g), 0, -1/(Ltr*Zl2g)];                     
        Ctr  =  [1, 0; 
                 0, 1];        
        Dtr  =  [0, 0, 0, 0;
                0, 0, 0, 0];
    
        tr_x  = {ig_q, ig_d};
        tr_u  = {'vsg_q','vsg_d','vg_q','vg_d'};
        tr_y  = {'ig_q','ig_d'};
        tr_ss = ss(Atr,Btr,Ctr,Dtr,'StateName',tr_x,'inputname',tr_u,'outputname',tr_y);
    
        ss_list{end+1} = tr_ss;
        
    
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
    
        ss_list{end+1} = isnb_ss;
        
        
        % SG snubber
        Asnb = [0];        
        Bsnb = [0 0];             
        Csnb = [0;0];        
        Dsnb = [Rsnb*Zl2g 0;
                0 Rsnb*Zl2g];
        
        snb_x={''};
        snb_u={'isn_q','isn_d'};
        snb_y={'vsg_q','vsg_d'};
        snb_ss = ss(Asnb,Bsnb,Csnb,Dsnb,'StateName', snb_x,'inputname',snb_u,'outputname',snb_y);
    
        ss_list{end+1} = snb_ss;
        
    
        % Espacio de estados Vsg qd: system -> sg
        Avsg_pu=[0 0;0 0];
        Bvsg_pu=[0 0; 0 0];
        Cvsg_pu=[0 0;0 0];
        %Dvsg_pu=[1 0; 0 1]*(0.869565217391304); 
        Dvsg_pu=[1 0; 0 1]/Vl2g; 
        
        vsg_pu_x={''};
        if num==num_slk(area) && element_slk(area) == "SG"
            vsg_pu_u={'vsg_q','vsg_d'};
        else
            vsg_pu_u={'vsg_qg','vsg_dg'};
        end
        vsg_pu_y={vsgq_pu,vsgd_pu};
        vsg_pu = ss(Avsg_pu,Bvsg_pu,Cvsg_pu,Dvsg_pu,'StateName',vsg_pu_x,'inputname',vsg_pu_u,'outputname',vsg_pu_y);
    
        ss_list{end+1} = vsg_pu;
        
        %% EXCITER
    
       if T_SG.exciter{sg} ~= "no"   
    
            % SG voltage magnitude
            Avsg=[0];
            Bvsg=[0 0];
            Cvsg=[0];
            Dvsg=[vsgq_g0/sqrt(vsgq_g0^2+vsgd_g0^2) vsgd_g0/sqrt(vsgq_g0^2+vsgd_g0^2)];
    
            vsg_x={''};
            vsg_u={vsgq_pu,vsgd_pu};
            vsg_y={'Vsg_mag'};
            vsg = ss(Avsg,Bvsg,Cvsg,Dvsg,'StateName',vsg_x,'inputname',vsg_u,'outputname',vsg_y);
    
            ss_list{end+1} = vsg;
            
            % Exciter filter (voltage transducer)
            [A,B,C,D] = tf2ss(1,[exc.TR 1]);
            Aexf=A;
            Bexf=B;
            Cexf=C;
            Dexf=D;
            if exc.TR==0
                exf_x = {''};
            else
                exf_x={exc_filt};
            end
            exf_u={'Vsg_mag'};
            exf_y={'Vc'};
            exf = ss(Aexf,Bexf,Cexf,Dexf,'StateName',exf_x,'inputname',exf_u,'outputname',exf_y);
    
            ss_list{end+1} = exf;
            
            % Exciter control    
            
            switch T_SG.exciter{sg}
                case 'ST4B'                         
                    Ve0  = sqrt(vsgq_g0^2+vsgd_g0^2)*exc.KP;
                    Ifd0 = ifd0*Lmd_pu;
                    fIn0 = 1-0.577*exc.KC*Ifd0/Ve0;
                    if pss.hasPSS
                        Vsi10 = 0;
                        Vsi20 = Pm0*1;
                        Vst0  = pss.Ks1*(Vsi10+(pss.Ks3-1)*pss.Ks2*Vsi20);
                        Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1 + Vst0)*exc.KPR; %with PSS                        
                        excInput_ss = SS_ERROR('SG_Vst','Vc','V_excInput');
                    else
                        Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1)*exc.KPR; %no PSS
                        excInput_ss = SS_GAIN('Vc','V_excInput',-1);
                    end           
                    Vb0  = Ve0*fIn0;
                        
                    % Exciter block 1
                    exc1_1  = tf([exc.KPR exc.KIR],[1 0]);
                    exc1_2  = tf([1],[exc.TA 1]);
                    exc1_3  = tf([exc.KPM exc.KIM],[1 0]);
                    exc1_tf = exc1_1*exc1_2*exc1_3;
                    [Aexc1,Bexc1,Cexc1,Dexc1] = tf2ss(exc1_tf.num{1,1},exc1_tf.den{1,1});
                    if exc.KPM == 0 || exc.TA == 0 || exc.KIR == 0
                        exc1_x  = {['SG',num2str(num),'_exc1_x1'],['SG',num2str(num),'_exc1_x2']};
                    else
                        exc1_x  = {['SG',num2str(num),'_exc1_x1'],['SG',num2str(num),'_exc1_x2'],['SG',num2str(num),'_exc1_x3']};
                    end
                    exc1_u  = {'V_excInput'};                    
                    exc1_y  = {'Vm'};
                    exc1_ss = ss(Aexc1,Bexc1,Cexc1,Dexc1,'StateName',exc1_x,'inputname',exc1_u,'outputname',exc1_y);            
                    % Exciter block 2
                    exc2_ss = SS_PROD('Vm',Vm0,'Vb',Vb0,'SG_Vfd');           
                    % Exciter block 3 (base change)
                    exc3_ss = SS_GAIN('SG_Vfd',vf_d, Rf_pu/Lmd_pu);            
                    % Exciter block 4
                    exc4_ss = SS_PROD('Ve',Ve0,'fIn',fIn0,'Vb');            
                    % Exciter block 5
                    exc5_ss = SS_GAIN('Vsg_mag','Ve',exc.KP);            
                    % Exciter block 6
                    exc6_ss = SS_PROD('Ve',-exc.KC*Ifd0/Ve0^2,'SG_Ifd',exc.KC/Ve0,'In');            
                    % Exciter block 7
                    exc7_ss = SS_GAIN('In','fIn',-0.577);            
                    % Exciter block 8
                    exc8_ss = SS_GAIN('SG_ifd','SG_Ifd',Lmd_pu);
            
                    % Exciter ss
                    if pss.hasPSS
                        exc_u = {'Vc','Vsg_mag','SG_ifd','SG_Vst'}; %PSS 
                        exc_y = {vf_d};
                    else
                        exc_u = {'Vc','Vsg_mag','SG_ifd'}; %no PSS 
                        exc_y = {vf_d};
                    end
                    exc_ss = connect(excInput_ss,exc1_ss,exc2_ss,exc3_ss,exc4_ss,exc5_ss,exc6_ss,exc7_ss,exc8_ss,exc_u,exc_y);
        
                case 'ST4C'                         
                    Ve0  = sqrt(vsgq_g0^2+vsgd_g0^2)*exc.KP;
                    Ifd0 = ifd0*Lmd_pu;
                    fIn0 = 1-0.577*exc.KC*Ifd0/Ve0;
                    if pss.hasPSS
                        Vsi10 = 0;
                        Vsi20 = Pm0*1;
                        Vst0  = pss.Ks1*(Vsi10+(pss.Ks3-1)*pss.Ks2*Vsi20);
                        Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1 + Vst0)*exc.KPR; %with PSS                        
                        excInput_ss = SS_ERROR('SG_Vst','Vc','V_excInput');
                    else
                        Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1)*exc.KPR; %no PSS
                        Vm0=0;
                        excInput_ss = SS_GAIN('Vc','V_excInput',-1);
                    end           
                    Vb0  = Ve0*fIn0;
                        
                    % Exciter block 1
                    exc1_1  = tf([exc.KPR exc.KIR],[1 0]);
                    [Aexc1,Bexc1,Cexc1,Dexc1] = tf2ss(exc1_1.num{1,1},exc1_1.den{1,1});
                    exc1_x  = {['SG',num2str(num),'_exc1_x1']};
                    exc1_u  = {'V_excInput'};                    
                    exc1_y  = {'Vr'};
                    exc1_ss = ss(Aexc1,Bexc1,Cexc1,Dexc1,'StateName',exc1_x,'inputname',exc1_u,'outputname',exc1_y);  
                   
                    % Windup
                    exc_windup = tf([exc.KG],[exc.TG 1]);
                    [Aexc_windup,Bexc_windup,Cexc_windup,Dexc_windup] = tf2ss(exc_windup.num{1,1},exc_windup.den{1,1});
                    if exc.TG==0
                        exc_windup_x  = {''};
                    else
                        exc_windup_x  = {['SG',num2str(num),'_exc1_x2']};
                    end
                    exc_windup_u  = {'SG_Vfd'};                    
                    exc_windup_y  = {'Vgmax'};
                    exc_windup_ss = ss(Aexc_windup,Bexc_windup,Cexc_windup,Dexc_windup,'StateName',exc_windup_x,'inputname',exc_windup_u,'outputname',exc_windup_y);  
                   
                    excInput2_ss = SS_ERROR('Vr','Vgmax','Vr_plus');

                    exc1_1p  = tf([exc.KPM exc.KIM],[1 0]);
                    exc1_2  = tf([1],[exc.TA 1]);
                    exc1_tf = exc1_1p*exc1_2;
                    [Aexc1,Bexc1,Cexc1,Dexc1] = tf2ss(exc1_tf.num{1,1},exc1_tf.den{1,1});
                    if exc.KIM == 0
                        exc1_x  = {['SG',num2str(num),'_exc1p_x1']};
                    else
                        exc1_x  = {['SG',num2str(num),'_exc1p_x1'],['SG',num2str(num),'_exc1p_x2']};
                    end
                    exc1_u  = {'Vr_plus'};                    
                    exc1_y  = {'Vm'};
                    exc1pp_ss = ss(Aexc1,Bexc1,Cexc1,Dexc1,'StateName',exc1_x,'inputname',exc1_u,'outputname',exc1_y);            
                    % Exciter block 2
                    exc2_ss = SS_PROD('Vm',Vm0,'Vb',Vb0,'SG_Vfd');           
                    % Exciter block 3 (base change)
                    exc3_ss = SS_GAIN('SG_Vfd',vf_d, Rf_pu/Lmd_pu);            
                    % Exciter block 4
                    exc4_ss = SS_PROD('Ve',Ve0,'fIn',fIn0,'Vb');            
                    % Exciter block 5
                    exc5_ss = SS_GAIN('Vsg_mag','Ve',exc.KP);            
                    % Exciter block 6
                    exc6_ss = SS_PROD('Ve',-exc.KC*Ifd0/Ve0^2,'SG_Ifd',exc.KC/Ve0,'In');            
                    % Exciter block 7
                    exc7_ss = SS_GAIN('In','fIn',-0.577);            
                    % Exciter block 8
                    exc8_ss = SS_GAIN('SG_ifd','SG_Ifd',Lmd_pu);
            
                    % Exciter ss
                    if pss.hasPSS
                        exc_u = {'Vc','Vsg_mag','SG_ifd','SG_Vst'}; %PSS 
                        exc_y = {vf_d};
                    else
                        exc_u = {'Vc','Vsg_mag','SG_ifd'}; %no PSS 
                        exc_y = {vf_d};
                    end
                    exc_ss = connect(excInput_ss,excInput2_ss,exc1_ss,exc1pp_ss,exc_windup_ss,exc2_ss,exc3_ss,exc4_ss,exc5_ss,exc6_ss,exc7_ss,exc8_ss,exc_u,exc_y);

                case 'ST1'

                        tfexc = -((exc.TC*s+1)/(exc.TB*s+1)*exc.KA/(exc.TA*s+1))*Rf_pu/Lmd_pu;
                        [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
                        if exc.TA
                            exc_x = {exc_x1, exc_x2};
                        else
                            exc_x = {exc_x1};
                        end
                        exc_y = {vf_d};
        
                    if pss.hasPSS % with PSS       
                        excInput_ss = SS_ERROR('Vc','SG_Vst','V_excInput');
                        exc_u   = {'V_excInput'};
                        exc_ss0 = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
                        exc_ss  = connect(excInput_ss,exc_ss0,{'Vc','SG_Vst'},exc_y);
            
                    else % without PSS  
                        exc_u  = {'Vc'};
                        exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
                    end
                
                case 'AC4A'

                    tfexc = -((exc.TC*s+1)/(exc.TB*s+1)*exc.KA/(exc.TA*s+1))*Rf_pu/Lmd_pu;
                    [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
                    exc_x = {exc_x1, exc_x2};
                    exc_y = {vf_d};
                    
                    if pss.hasPSS % with PSS 
                        excInput_ss = SS_ERROR('Vc','SG_Vst','V_excInput');
                        exc_u   = {'V_excInput'};
                        exc_ss0 = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
                        exc_ss  = connect(excInput_ss,exc_ss0,{'Vc','SG_Vst'},exc_y);
                    else % without PSS 
                        exc_u  = {'Vc'};
                        exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);                    
                    end

                case 'AC8C'
                    Ve0  = sqrt(vsgq_g0^2+vsgd_g0^2)*exc.KP;
                    Ifd0 = ifd0*Lmd_pu;
                    fIn0 = 1-0.577*exc.KC*Ifd0/Ve0;
                    fIn0 = 0;
                    ks = 0.044/5.55;
                    ACrot_state = -(exc.KD*Ifd0)/(ks + exc.KE);
                    FE0 = 1-(Ifd0)/ACrot_state*exc.KC*0.577;
                    Vfe0 = ks*ACrot_state + exc.KE*ACrot_state + exc.KD*Ifd0;
                    if pss.hasPSS
                        Vsi10 = 0;
                        Vsi20 = Pm0*1;
                        Vst0  = pss.Ks1*(Vsi10+(pss.Ks3-1)*pss.Ks2*Vsi20);
                        %Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1 + Vst0)*exc.KPR %with PSS
                        Vm0 = 0;
                        excInput_ss = SS_ERROR('SG_Vst','Vc','V_excInput');
                    else
                        %Vm0  = (-sqrt(vsgq_g0^2+vsgd_g0^2) + 1)*exc.KPR %no PSS
                        Vm0 = 0;
                        excInput_ss = SS_GAIN('Vc','V_excInput',-1);
                    end           
                    Vb0  = Ve0*fIn0;
                    Vb0=0;
                        
                    % Exciter block 1
                    exc1_1  = tf([exc.KPR*exc.TDR+exc.KDR exc.KPR+exc.KIR*exc.TDR exc.KIR],[exc.TDR 1 0]);
                    exc1_2  = tf([exc.KA],[exc.TA 1]);
                    exc1_tf = exc1_1*exc1_2;
                    [Aexc1,Bexc1,Cexc1,Dexc1] = tf2ss(exc1_tf.num{1,1},exc1_tf.den{1,1});
                    if exc.TDR == 0 || exc.TA == 0 || exc.KIR == 0
                        exc1_x  = {['SG',num2str(num),'_exc1_x1'],['SG',num2str(num),'_exc1_x2']};
                    else
                        exc1_x  = {['SG',num2str(num),'_exc1_x1'],['SG',num2str(num),'_exc1_x2'],['SG',num2str(num),'_exc1_x3']};
                    end
                    exc1_u  = {'V_excInput'};                    
                    exc1_y  = {'Vm'};
                    exc1_ss = ss(Aexc1,Bexc1,Cexc1,Dexc1,'StateName',exc1_x,'inputname',exc1_u,'outputname',exc1_y);           
                    % Exciter block 2
                    %exc2_ss = SS_PROD('Vm',Vm0,'Vb',Vb0,'SG_Vfd_preACrotating');
                    %!!!!!!! OJO AQUI!!!!!!!
                    exc2_ss = SS_PROD('Vm',Vm0,'Vb',Vb0,'SG_Vfd_preACrotating');
                    ac_rotating_machine = SC_SS_ACROTATINGMACHINE(exc.KC,exc.KD,exc.KE,exc.TE,Ifd0,ACrot_state,FE0,{'SG_Vfd_preACrotating' 'SG_Ifd'},{'SG_Vfd','VFE'},num);
                    % Exciter block 3 (base change)
                    exc3_ss = SS_GAIN('SG_Vfd',vf_d, Rf_pu/Lmd_pu);            
                    % Exciter block 4
                    exc4_ss = SS_PROD('Ve',Ve0,'fIn',fIn0,'Vb');            
                    % Exciter block 5
                    exc5_ss = SS_GAIN('Vsg_mag','Ve',exc.KP);            
                    % Exciter block 6
                    exc6_ss = SS_PROD('Ve',-exc.KC*Vfe0/Ve0^2,'VFE',exc.KC/Ve0,'In');            
                    % Exciter block 7
                    exc7_ss = SS_GAIN('In','fIn',-0.577);            
                    % Exciter block 8
                    exc8_ss = SS_GAIN('SG_ifd','SG_Ifd',Lmd_pu);

                    % ss_prova = connect(exc4_ss,exc5_ss,exc6_ss,exc7_ss,'Vsg_mag','Vb')

                    % Exciter ss
                    if pss.hasPSS
                        exc_u = {'Vc','Vsg_mag','SG_ifd','SG_Vst'}; %PSS 
                        exc_y = {vf_d};
                    else
                        exc_u = {'Vc','Vsg_mag','SG_ifd'}; %no PSS 
                        exc_y = {vf_d};
                    end
                    exc_ss = connect(excInput_ss,exc1_ss,exc2_ss,exc3_ss,exc4_ss,exc5_ss,exc6_ss,exc7_ss,exc8_ss,ac_rotating_machine,exc_u,exc_y);

            end

            ss_list{end+1} = exc_ss;

       end
        
     % PSS  

       if T_SG.pss{sg} == "2A" 
            % Vsi1: Rotor speed deviation in [pu]    
            % Vsi2: Electrical power [pu] == Te*w 
            Pe_ss    = SS_PROD(Te,Pm0,we_pu,1,'SG_Pe');
        
            % PSS block 1
            pss1_1  = tf_WASHOUT(pss.Tw1);
            pss1_2  = tf_WASHOUT(pss.Tw2);
            pss1_3  = tf_LP(1,pss.T6); 
            pss1_tf = pss1_1*pss1_2*pss1_3;
            [Apss1,Bpss1,Cpss1,Dpss1] = tf2ss(pss1_tf.num{1},pss1_tf.den{1});
            pss1_x  = {['SG',num2str(num),'.pss1_x1'],['SG',num2str(num),'.pss1_x2']};
            pss1_u  = {we_pu};
            pss1_y  = {'SG_Vsi1_out'};
            pss1_ss = ss(Apss1,Bpss1,Cpss1,Dpss1,'StateName',pss1_x,'inputname',pss1_u,'outputname',pss1_y);
        
            % PSS block 2
            pss2_1  = tf_WASHOUT(pss.Tw3);
            pss2_2  = tf_LP(pss.Ks2,pss.T7);  
            pss2_tf = pss2_1*pss2_2;
            [Apss2,Bpss2,Cpss2,Dpss2] = tf2ss(pss2_tf.num{1},pss2_tf.den{1});
            pss2_x  = {['SG',num2str(num),'.pss2_x1'],['SG',num2str(num),'.pss2_x2']};
            pss2_u  = {'SG_Pe'};
            pss2_y  = {'SG_Vsi2_out'};
            pss2_ss = ss(Apss2,Bpss2,Cpss2,Dpss2,'StateName',pss2_x,'inputname',pss2_u,'outputname',pss2_y);
            
            % PSS block 3
            pss3_ss = SS_ADD('SG_Vsi1_out','SG_Vsi2_out','SG_Vsi_sum');
        
            % PSS block 4
            pss4_tf = (tf([pss.T8 1],1)/(tf([pss.T9 1],1)^pss.M))^pss.N;
            [Apss4,Bpss4,Cpss4,Dpss4] = tf2ss(pss4_tf.num{1},pss4_tf.den{1});
            pss4_x = {};
            for idx = 1:pss.M*pss.N
            pss4_x{end+1} = ['SG',num2str(num),'.pss4_x' num2str(idx)];
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
            pss6_x  = {['SG',num2str(num),'.pss6_x1'],['SG',num2str(num),'.pss6_x2']};
            pss6_u  = {'SG_Vst_in'};
            pss6_y  = {'SG_Vst'};
            pss6_ss = ss(Apss6,Bpss6,Cpss6,Dpss6,'StateName',pss6_x,'inputname',pss6_u,'outputname',pss6_y);
        
            pss_ss = connect(Pe_ss,pss1_ss,pss2_ss,pss3_ss,pss4_ss,pss5_ss,pss6_ss,{we_pu,Te},{'SG_Vst'});
    
            ss_list{end+1} = pss_ss;
        end
    
    %%  GOVERNOR, TURBINE & ROTOR SHAFT
    
    switch T_SG.govturb{sg}
    
        case 'IEEEG1'

            % Governor

            if mech.T1~= 0
                Agov = [0 1;-1/(mech.T1*mech.T3) -(mech.T1+mech.T3)/(mech.T1*mech.T3)];
                Bgov = [0 0 0;1 1/mech.R -1/mech.R];
                Cgov = [1/(mech.T1*mech.T3) mech.T2/(mech.T1*mech.T3)];
                Dgov = [0 mech.Dt -mech.Dt];
                
                gov_x={gov_x1,gov_x2};
                gov_u={Pref,'SG_wref',we_pu};
                gov_y={'SG_cv'};
                gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);
            else
                Agov = [-1/mech.T3];
                Bgov = [1 1/mech.R -1/mech.R];
                Cgov = [1/mech.T3];
                Dgov = [0 mech.Dt -mech.Dt];
                
                gov_x={gov_x1};
                gov_u={Pref,'SG_wref',we_pu};
                gov_y={'SG_cv'};
                gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);
            end

            ss_list{end+1} = gov_ss;
            
            % Turbine   

            turb_t4 = tf(1,[mech.T4 1]);
            turb_t5 = tf(1,[mech.T5 1]);
            turb_t6 = tf(1,[mech.T6 1]);
            turb_t7 = tf(1,[mech.T7 1]);            
            turb_tf = (mech.K7+mech.K8)*(turb_t7*turb_t6*turb_t5*turb_t4)+(mech.K5+mech.K6)*(turb_t6*turb_t5*turb_t4)+(mech.K3+mech.K4)*(turb_t5*turb_t4)+(mech.K1+mech.K2)*(turb_t4);            
            [Aturb,Bturb,Cturb,Dturb] = tf2ss(turb_tf.num{1},turb_tf.den{1});

            for jj = 1:length(Aturb)
                turb_x(jj) = {[turbx num2str(jj)]};
            end
            turb_u={'SG_cv'};
            turb_y={'SG_Pm'};
            turb_ss = ss(Aturb,Bturb,Cturb,Dturb,'StateName',turb_x,'inputname',turb_u,'outputname',turb_y);
    
            ss_list{end+1} = turb_ss;

            
        case 'TANDEM-MULTI'

            % Governor
            ss_w_err      = SS_ERROR('SG_wref', we_pu, 'SG_w_err');    
            ss_w_droop    = SS_GAIN('SG_w_err', 'SG_Pm_err', 1/mech.R);     
            ss_P_err      = SS_ADD(Pref,'SG_Pm_err', 'SG_cv');    
            gov_in        = {'SG_wref',we_pu, Pref};
            gov_out       = {'SG_cv'};
            gov_ss = connect(ss_w_err, ss_w_droop, ss_P_err, gov_in, gov_out);

            ss_list{end+1} = gov_ss;

            % Turbine multi-mass
            Yturb_5 = ['SG' num2str(num) '.Yturb_5'];
            Yturb_4 = ['SG' num2str(num) '.Yturb_4'];
            Yturb_3 = ['SG' num2str(num) '.Yturb_3'];
            Tt_2    = ['SG' num2str(num) '.Tt_2'];
            Tt_3    = ['SG' num2str(num) '.Tt_3'];
            Tt_4    = ['SG' num2str(num) '.Tt_4'];
            Tt_5    = ['SG' num2str(num) '.Tt_5'];
            ss_turb5         = SS_TURB(mech.T5, mech.F5, 'SG_cv', 5, num); % STEAM CHEST (#5)     
            ss_turb4         = SS_TURB(mech.T4, mech.F4, Yturb_5, 4, num); % REHEATER    (#4)      
            ss_turb3         = SS_TURB(mech.T3, mech.F3, Yturb_4, 3, num); % REHEATER    (#3)       
            ss_turb2         = SS_TURB(mech.T2, mech.F2, Yturb_3, 2, num); % REHEATER    (#2)

            turb_in          = {'SG_cv'};
            turb_out         = {Tt_2, Tt_3, Tt_4, Tt_5};
            turb_ss          = connect(ss_turb5, ss_turb4, ss_turb3, ss_turb2, turb_in, turb_out);

            ss_list{end+1} = turb_ss;

            % Multi-mass shaft

            shaft_ss  = SS_SHFTMM(mech.H1,mech.H2,mech.H3,mech.H4,mech.H5,mech.K12,mech.K23,mech.K34,mech.K45,mech.D1,mech.D2,mech.D3,mech.D4,mech.D5,T_SG.wb(sg),num);

            ss_list{end+1} = shaft_ss;

        case 'TANDEM-SINGLE'

            % Governor
            ss_w_err      = SS_ERROR('SG_wref', we_pu, 'SG_w_err');    
            ss_w_droop    = SS_GAIN('SG_w_err', 'SG_Pm_err', 1/mech.R);     
            ss_P_err      = SS_ADD(Pref,'SG_Pm_err', 'SG_cv');    
            gov_in        = {'SG_wref',we_pu, Pref};
            gov_out       = {'SG_cv'};
            gov_ss = connect(ss_w_err, ss_w_droop, ss_P_err, gov_in, gov_out);

            ss_list{end+1} = gov_ss;

            % Turbine single-mass
            turb_ss   = SS_TURBSM(mech.K_hp, mech.tau_lp, 'SG_cv', 'SG_Pm', num);   

            ss_list{end+1} = turb_ss;
       
    end
    
    %% ELECTRIC CIRCUIT
        
    if T_SG.govturb{sg} == "TANDEM-MULTI"

        % MULTI-MASS SG: Inertia equation outside electrical machine

        sem_u = {vsgd_pu vk_d  vf_d  vsgq_pu  vk1_q  vk2_q  we_pu};
        sem_y = {'SG_isdg_pu'  'SG_ikd'  'SG_ifd'  'SG_isqg_pu'  'SG_ikq1'  'SG_ikq2' Te};
        ss_sg = SS_SEM(T_SG(sg,:), w0_pu, isq0, isd0, ikq10, ikq20, ifd0, ikd0, T_SG.wb(sg), num, sem_u, sem_y);

    else

        % SINGLE-MASS SG: Inertia equation inside electrical machine

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
        Csg = [eye(7);(isd0*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0) isq0*(Lmq_pu-Lmd_pu) isq0*Lmd_pu isq0*Lmd_pu -isd0*Lmq_pu -isd0*Lmq_pu 0];
        Dsg = zeros(8,7);
       
        sg_x={is_q, is_d, if_d, ik_d, ik1_q, ik2_q, we_pu};
        sg_u={vsgq_pu, vsgd_pu, vf_d, vk_d, vk1_q, vk2_q, 'SG_Pm'};
        sg_y={'SG_isqg_pu', 'SG_isdg_pu', 'SG_ifd', 'SG_ikd', 'SG_ikq1', 'SG_ikq2', we_pu, Te};
        ss_sg = ss(Asg,Bsg,Csg,Dsg,'StateName',sg_x,'inputname',sg_u,'outputname',sg_y);    

    end

    ss_list{end+1} = ss_sg;
        
        %% LOCAL TO GLOBAL ROTATION (INV) - POC current
    
        % Change base of SG current: SG pu -> System pu
        Aisg_pu=[0 0; 0 0];
        Bisg_pu=[0 0; 0 0];
        Cisg_pu=[0 0;0 0];
        Disg_pu=[1 0; 0 1]*Il2g;
        isg_pu_x={''}; 
        if num==num_slk(area) && element_slk(area) == "SG"
            isg_pu_u={'SG_isqg_pu','SG_isdg_pu'};
        else
            isg_pu_u={'SG_isq_pu','SG_isd_pu'};
        end
        isg_pu_y={'isg_q','isg_d'};
        isg_pu = ss(Aisg_pu,Bisg_pu,Cisg_pu,Disg_pu,'StateName',isg_pu_x,'inputname',isg_pu_u,'outputname',isg_pu_y);
    
        ss_list{end+1} = isg_pu;
    
        %% PU to REAL ROTOR SPEED (w)
        
        % Espacio de estados wsg: pu -> real
        Awsg_pu=[0];
        Bwsg_pu=[0];
        Cwsg_pu=[0];
        Dwsg_pu=[wb];
        wsg_pu_x={''};
        wsg_pu_u={we_pu};
        wsg_pu_y={w_real};
        wsg_pu = ss(Awsg_pu,Bwsg_pu,Cwsg_pu,Dwsg_pu,'StateName',wsg_pu_x,'inputname',wsg_pu_u,'outputname',wsg_pu_y);
    
        ss_list{end+1} = wsg_pu;
        
        %% ANGLE DEVIATION AND ROTATIONS
    
%         % Espacio de estados angulo 
%         Aang=[0];
%         Bang=[1];
%         Cang=[1];
%         Dang=[0];
%         ang_x={theta};
%         ang_u={w_real};
%         ang_y={'SG_th'};
%         ang = ss(Aang,Bang,Cang,Dang,'StateName',ang_x,'inputname',ang_u,'outputname',ang_y);
%     
%         ss_list{end+1} = ang;
        
        if ~(num==num_slk(area) && element_slk(area) == "SG")
            % Angle different with slack 
            Adang=[0];
            Bdang=[1 -1];
            Cdang=[1];
            Ddang=[0 0];
            dang_x={e_theta};
            dang_u={w_real, [REF_w num2str(syncarea)]};
            dang_y={'SG_e_th'};
            dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
    
            ss_list{end+1} = dang;
            
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
    
            ss_list{end+1} = igx_g;
            
            % Reference transformation for SG voltage (global -> local)
            Avgx_g=[0];
            Bvgx_g=[0 0 0];
            Cvgx_g=[0;0];
            Dvgx_g=[cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*vq0-cos(e_theta0)*vd0;
                    sin(e_theta0) cos(e_theta0) cos(e_theta0)*vq0-sin(e_theta0)*vd0]; 
            vgx_g_x={''};
            vgx_g_u={'vsg_q','vsg_d','SG_e_th'};
            vgx_g_y={'vsg_qg','vsg_dg'};
            vgx_g = ss(Avgx_g,Bvgx_g,Cvgx_g,Dvgx_g,'StateName',vgx_g_x,'inputname',vgx_g_u,'outputname',vgx_g_y);
    
            ss_list{end+1} = vgx_g;
        end
        
        % Build complete model
        if num==num_slk(area) && element_slk(area) == "SG"
            input_vars = {'vg_q','vg_d'};
            output_vars = {'ig_q','ig_d',w_real};
        else
            input_vars = {'vg_q','vg_d',[REF_w num2str(syncarea)]};
            output_vars = {'ig_q','ig_d',w_real};  
        end

        if T_SG.govturb{sg} ~= "no"
            input_vars{end+1} = Pref;
        end
    
        SS_SG = connect(ss_list{:},input_vars,output_vars); 
        % SS_SG = connect(tr_ss,isnb_ss,snb_ss,ss_sg,vsg_pu,vsg,exf,exc_ss,gov_ss,turb_ss,isg_pu,wsg_pu,ang,dang,vgx_g,igx_g,input_vars,output_vars); %full
        
        %%  adapt inputs/outputs
        
        SS_SG.InputName(1) = {vnXq};
        SS_SG.InputName(2) = {vnXd};
        
        SS_SG.OutputName(1) = {iq};
        SS_SG.OutputName(2) = {id};

        
        if num==num_slk(area) && element_slk{area} == "SG"
            SS_SG.OutputName(3) = {[REF_w num2str(syncarea)]};
        end
    
        %% append ss to l_blocks
        l_blocks{end+1} = SS_SG; 
    
    end

end