% GENERATE STATE-SPACE MODEL OF SYNCHRONOUS GENERATOR IN PU
% SG base: peak phase-to-ground
% System base: rms line-to-line

function l_blocks = generate_VSC_pu(l_blocks,T_VSC, lp_VSC, T_global, num_slk, element_slk, REF_w)

    s = tf('s');
    
    for vsc = 1:1:size(T_VSC.bus,1) 
    
        ss_list = {};      

        mode = T_VSC.mode{vsc};

        % Base values and conversions
        Svsc  = T_VSC.Sb(vsc);       % SG rated power, SG power base  
        Sb   = T_global.Sb(T_global.Area == T_VSC.Area(vsc)); % System power base
        Zl2g = T_VSC.Zbpu_l2g(vsc);
        Sl2g = T_VSC.Sbpu_l2g(vsc);
        Vl2g = T_VSC.Vbpu_l2g(vsc);
        Il2g = T_VSC.Ibpu_l2g(vsc);
        wb   = T_VSC.wb(vsc);

        switch mode

            % -------------------------------------------------------------
            case 'GFOL'   
            % -------------------------------------------------------------

                % ---------------------------------------------------------
                % Set names of state variables, inputs and outputs     
                % ---------------------------------------------------------

                num = T_VSC.number(vsc); 
                bus = T_VSC.bus(vsc);
                    
                % Frequency droop
                fdroop_x     = ['GFOL' num2str(num) '.w_filt_x']; 
                P_ref         = ['GFOL' num2str(num) '.P_ref']; 
                omega_ref     = ['GFOL' num2str(num) '.omega_ref']; 
                
                % Voltage droop
                udroop_x   = ['GFOL' num2str(num) '.q_filt_x']; 
                Q_ref      = ['GFOL' num2str(num) '.Q_ref']; 
                Umag_ref   = ['GFOL' num2str(num) '.Umag_ref']; 
                
                % LC:
                is_q   = ['GFOL' num2str(num) '.is_q']; 
                is_d   = ['GFOL' num2str(num) '.is_d']; 
                ucap_q = ['GFOL' num2str(num) '.ucap_q']; 
                ucap_d = ['GFOL' num2str(num) '.ucap_d'];                 

                % Trafo
                ig_q    = ['GFOL' num2str(num) '.ig_q'];
                ig_d    = ['GFOL' num2str(num) '.ig_d'];
                
                % Power control:
                p_x = ['GFOL' num2str(num) '.Ke_P'];  
                q_x = ['GFOL' num2str(num) '.Ke_Q']; 
                
                % AC side current control
                is_q_x1   = ['GFOL' num2str(num) '.Ke_is_q'];  
                is_q_x2   = ['GFOL' num2str(num) '.Ke_is_d']; 
                is_qc_ref = ['GFOL' num2str(num) '.is_qc_ref'];
                is_dc_ref = ['GFOL' num2str(num) '.is_dc_ref']; 
                
                % omega to angle VSC (1/s)
                angle_vsc_x = ['GFOL' num2str(num) '.angle_vsc_x']; 
                w_vsc       = ['GFOL' num2str(num) '.w']; 
                
                % PLL
                pll_x       = ['GFOL' num2str(num) '.pll_x']; 
                
                % omega to angle grid (1/s)
                etheta_x = ['GFOL' num2str(num) '.etheta_x']; 
                
                % in/out voltages & currents in grid (global) ref
                vnXq = ['NET.vn' num2str(bus) 'q'];    
                vnXd = ['NET.vn' num2str(bus) 'd'];    
                iq   = ['VSC' num2str(num) '.iq'];    
                id   = ['VSC' num2str(num) '.id'];   

                % ---------------------------------------------------------
                % Parameters
                % ---------------------------------------------------------

                % Transformer
                Rtr    = T_VSC.Rtr(vsc);
                Ltr    = T_VSC.Ltr(vsc);
                % RL filter
                Rc = T_VSC.Rc(vsc);
                Lc = T_VSC.Lc(vsc);
                Cac = T_VSC.Cac(vsc);
                Rac = T_VSC.Rac(vsc);
                % Currrent control
                kp_s = T_VSC.kp_s(vsc);
                ki_s = T_VSC.ki_s(vsc);
                % PLL
                kp_pll = T_VSC.kp_pll(vsc);
                ki_pll = T_VSC.ki_pll(vsc);
                % Power loops
                kp_P  = T_VSC.kp_P(vsc);
                ki_P  = T_VSC.ki_P(vsc);
                kp_Q  = T_VSC.kp_Q(vsc);
                ki_Q  = T_VSC.ki_Q(vsc);
                tau_droop_f = T_VSC.tau_droop_f(vsc);
                k_droop_f   = T_VSC.k_droop_f(vsc);
                tau_droop_u = T_VSC.tau_droop_u(vsc);
                k_droop_u   = T_VSC.k_droop_u(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                ucap_q0    = lp_VSC{vsc}.ucap_q0;
                ucap_d0    = lp_VSC{vsc}.ucap_d0;     
                vc_qc0  = lp_VSC{vsc}.vc_qc0; 
                vc_dc0  = lp_VSC{vsc}.vc_dc0; 
                w0      = lp_VSC{vsc}.w0; 
                e_theta0 = lp_VSC{vsc}.etheta0; 


                % ---------------------------------------------------------
                % State-Space Model GFOL
                % ---------------------------------------------------------

                % Transforms 
                
                % REF INVERSE transform: vc_c to vc (local -> global)
                Avc_l2g  = [0];
                Bvc_l2g  = [0 0 0];
                Cvc_l2g  = [0;0];
                Dvc_l2g  = [cos(e_theta0) sin(e_theta0) -sin(e_theta0)*vc_qc0+cos(e_theta0)*vc_dc0;
                           -sin(e_theta0) cos(e_theta0) -cos(e_theta0)*vc_qc0-sin(e_theta0)*vc_dc0];
                vc_l2g_x = {''};
                vc_l2g_u = {'vc_qc','vc_dc' 'e_theta'};
                vc_l2g_y = {'vc_q','vc_d'};
                vc_l2g   = ss(Avc_l2g,Bvc_l2g,Cvc_l2g,Dvc_l2g,'StateName',vc_l2g_x,'inputname',vc_l2g_u,'outputname',vc_l2g_y);

                ss_list{end+1} = vc_l2g ;
                
                % REF transform: is to is_c (global -> local)
                Ais_g2l = [0];
                Bis_g2l = [0 0 0];
                Cis_g2l = [0;0];
                Dis_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*is_q0-cos(e_theta0)*is_d0;
                          sin(e_theta0) cos(e_theta0) cos(e_theta0)*is_q0-sin(e_theta0)*is_d0];
                is_g2l_x = {''};
                is_g2l_u = {is_q is_d 'e_theta'};
                is_g2l_y = {'is_qc' 'is_dc'};
                is_g2l   = ss(Ais_g2l,Bis_g2l,Cis_g2l,Dis_g2l,'StateName',is_g2l_x,'inputname',is_g2l_u,'outputname',is_g2l_y);

                ss_list{end+1} = is_g2l;
                
                % REF transform: u to u_c (global -> local)
                Au_g2l = [0];
                Bu_g2l = [0 0 0];
                Cu_g2l = [0;0];
                Du_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*u_q0-cos(e_theta0)*u_d0;
                          sin(e_theta0) cos(e_theta0) cos(e_theta0)*u_q0-sin(e_theta0)*u_d0];
                u_g2l_x = {''};
                u_g2l_u = {'u_q','u_d' 'e_theta'};
                u_g2l_y = {'u_qc','u_dc'};
                u_g2l   = ss(Au_g2l,Bu_g2l,Cu_g2l,Du_g2l,'StateName',u_g2l_x,'inputname',u_g2l_u,'outputname',u_g2l_y);

                ss_list{end+1} = u_g2l;

                % Change base of voltage: system -> vsc
                Avsc_pu=[0 0;0 0];
                Bvsc_pu=[0 0; 0 0];
                Cvsc_pu=[0 0;0 0];
                Dvsc_pu=[1 0; 0 1]/Vl2g;                 
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};
                vvsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vvsc_pu_x,'inputname',vvsc_pu_u,'outputname',vvsc_pu_y);
            
                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu -> System pu

                if T_VSC.Cac(vsc) % RLC filter
                    
                    Avsc_pu=[0 0; 0 0];
                    Bvsc_pu=[0 0; 0 0];
                    Cvsc_pu=[0 0;0 0];
                    Dvsc_pu=[1 0; 0 1]*Il2g;
                    vsc_pu_x={''}; 
                    vsc_pu_u={ig_q,ig_d};
                    vsc_pu_y={iq, id};

                else % RL filter
                    % Change base of current: VSC pu -> System pu
                    Avsc_pu=[0 0; 0 0];
                    Bvsc_pu=[0 0; 0 0];
                    Cvsc_pu=[0 0;0 0];
                    Dvsc_pu=[1 0; 0 1]*Il2g;
                    vsc_pu_x={''}; 
                    vsc_pu_u={is_q,is_d};
                    vsc_pu_y={iq, id};
                end

                vsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vsc_pu_x,'inputname',vsc_pu_u,'outputname',vsc_pu_y);    
                ss_list{end+1} = vsc_pu;
                                
                % PLL:
                Apll=[0];
                Bpll=[1];
                Cpll=[-ki_pll];
                Dpll=[-kp_pll];
                pll_x={pll_x};
                pll_u={'u_dc'};
                pll_y={'w_vsc_pu'};
                pll = ss(Apll,Bpll,Cpll,Dpll,'StateName',pll_x,'inputname',pll_u,'outputname',pll_y);

                ss_list{end+1} = pll;

                % Espacio de estados wvsc: pu -> real
                Aw_pu=[0];
                Bw_pu=[0];
                Cw_pu=[0];
                Dw_pu=[wb];
                w_pu_x={''};
                w_pu_u={'w_vsc_pu'};
                w_pu_y={w_vsc};
                w_pu = ss(Aw_pu,Bw_pu,Cw_pu,Dw_pu,'StateName',w_pu_x,'inputname',w_pu_u,'outputname',w_pu_y);
            
                ss_list{end+1} = w_pu;
                
                % Angle deviation from system reference
                Adang=[0];
                Bdang=[1 -1];
                Cdang=[1];
                Ddang=[0 0];
                dang_x={etheta_x};
                dang_u={w_vsc,REF_w};
                dang_y={'e_theta'};
                dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);

                ss_list{end+1} = dang;

                % Frequency droop with low-pass filter on omega:
                Afdroop=[-1/tau_droop_f];
                Bfdroop=[0 1];
                Cfdroop=[-k_droop_f/tau_droop_f/wb];
                Dfdroop=[+k_droop_f/wb 0];
                fdroop_x={fdroop_x};
                fdroop_u={omega_ref w_vsc};
                fdroop_y={P_ref};
                fdroop = ss(Afdroop,Bfdroop,Cfdroop,Dfdroop,'StateName',fdroop_x,'inputname',fdroop_u,'outputname',fdroop_y);

                ss_list{end+1} = fdroop;
                
                % voltage magnitude
                Au   = [0];
                Bu   = [0 0];
                Cu   = [0];
                Du   = [u_q0/(sqrt(u_q0^2+u_d0^2)) u_d0/(sqrt(u_q0^2+u_d0^2))];
                Au_x = {''};
                Au_u = {'u_q' 'u_d'};
                Au_y = {'Umag'};
                ss_u = ss(Au,Bu,Cu,Du,'StateName',Au_x,'inputname',Au_u,'outputname',Au_y);

                ss_list{end+1} = ss_u;
                
                % Voltage droop with low-pass filter in v:
                Audroop  = [-1/tau_droop_u];
                Budroop  = [0 1];
                Cudroop  = [-k_droop_u/tau_droop_u];
                Dudroop  = [+k_droop_u 0];
                udroop_x = {udroop_x};
                udroop_u = {Umag_ref 'Umag'};
                udroop_y = {Q_ref};
                udroop   = ss(Audroop,Budroop,Cudroop,Dudroop,'StateName',udroop_x,'inputname',udroop_u,'outputname',udroop_y);

                ss_list{end+1} = udroop;

                % PQ control
                
                if T_VSC.Cac(vsc) % RLC filter

                    % P control
                    Ap=[0];
                    Bp=[1 -3/2*u_q0 -3/2*u_d0 -3/2*ig_q0 -3/2*ig_d0]; 
                    Cp=[ki_P];
                    Dp=[kp_P -3/2*u_q0*kp_P -3/2*u_d0*kp_P -3/2*ig_q0*kp_P -3/2*ig_d0*kp_P];
                    p_x={p_x};
                    p_u={P_ref ig_q ig_d 'u_q' 'u_d'};
                    p_y={is_qc_ref};
                    ss_p = ss(Ap,Bp,Cp,Dp,'StateName',p_x,'inputname',p_u,'outputname',p_y);
    
                    ss_list{end+1} = ss_p;
                    
                    % Q control
                    Aq=[0];
                    Bq=[1 3/2*u_d0 -3/2*u_q0 -3/2*ig_d0 3/2*ig_q0];
                    Cq=[ki_Q];
                    Dq=[kp_Q 3/2*u_d0*kp_Q -3/2*u_q0*kp_Q -3/2*ig_d0*kp_Q  3/2*ig_q0*kp_Q];
                    q_x={q_x};
                    q_u={Q_ref ig_q ig_d 'u_q' 'u_d'};
                    q_y={is_dc_ref};
                    ss_q = ss(Aq,Bq,Cq,Dq,'StateName',q_x,'inputname',q_u,'outputname',q_y);
    
                    ss_list{end+1} = ss_q;

                else % RL filter

                    % P control
                    Ap=[0];
                    Bp=[1 -3/2*u_q0 -3/2*u_d0 -3/2*is_q0 -3/2*is_d0]; 
                    Cp=[ki_P];
                    Dp=[kp_P -3/2*u_q0*kp_P -3/2*u_d0*kp_P -3/2*is_q0*kp_P -3/2*is_d0*kp_P];
                    p_x={p_x};
                    p_u={P_ref is_q is_d 'u_q' 'u_d'};
                    p_y={is_qc_ref};
                    ss_p = ss(Ap,Bp,Cp,Dp,'StateName',p_x,'inputname',p_u,'outputname',p_y);
    
                    ss_list{end+1} = ss_p;
                    
                    % Q control
                    Aq=[0];
                    Bq=[1 3/2*u_d0 -3/2*u_q0 -3/2*is_d0 3/2*is_q0];
                    Cq=[ki_Q];
                    Dq=[kp_Q 3/2*u_d0*kp_Q -3/2*u_q0*kp_Q -3/2*is_d0*kp_Q  3/2*is_q0*kp_Q];
                    q_x={q_x};
                    q_u={Q_ref is_q is_d 'u_q' 'u_d'};
                    q_y={is_dc_ref};
                    ss_q = ss(Aq,Bq,Cq,Dq,'StateName',q_x,'inputname',q_u,'outputname',q_y);
    
                    ss_list{end+1} = ss_q;

                end
                                
                % AC side current control
                Ais = [0 0;
                       0 0];
                Bis = [1 0 -1 0 0 0;
                      0 1 0 -1 0 0];
                Cis = [+ki_s 0;
                      0 +ki_s];
                Dis = [+kp_s 0     -kp_s  +wb*Lc 1 0;
                       0     +kp_s -wb*Lc -kp_s  0 1];
                is_x = {is_q_x1 is_q_x2};
                is_u = {is_qc_ref  is_dc_ref 'is_qc' 'is_dc' 'u_qc' 'u_dc'};
                is_y = {'vc_qc' 'vc_dc'};
                is   = ss(Ais,Bis,Cis,Dis,'StateName',is_x,'inputname',is_u,'outputname',is_y);

                ss_list{end+1} =  is;


                % RL/RLC filter and trafo

                if T_VSC.Cac(vsc) % RLC filter

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
                    tr_y = {ig_q, ig_d};
                    tr_ss = ss(Atr,Btr,Ctr,Dtr,'StateName',tr_x,'inputname',tr_u,'outputname',tr_y);
    
                    ss_list{end+1} = tr_ss;
    
                    % LC:
                    Alc =  [(-Rc-Rac)/Lc -wb -1/Lc 0;
                               wb (-Rc-Rac)/Lc 0 -1/Lc;
                               1/Cac 0 0 -wb;
                               0 1/Cac wb 0];
                    Blc =  [1/Lc 0 Rac/Lc 0 -is_d0; 
                               0 1/Lc 0 Rac/Lc +is_q0;
                               0 0 -1/Cac 0 -ucap_d0; 
                               0 0 0 -1/Cac +ucap_q0];
                    Clc  = [1 0 0 0;
                               0 1 0 0;
                               Rac 0 1 0;
                               0 Rac 0 1];
                    Dlc =  [0 0 0 0 0;
                               0 0 0 0 0;
                               0 0 -Rac 0 0;
                               0 0 0 -Rac 0];
                    lc_x = {is_q is_d ucap_q ucap_d};
                    lc_u = {'vc_q' 'vc_d' ig_q ig_d REF_w};
                    lc_y = {is_q is_d 'u_q' 'u_d'};
                    Lc_ss = ss(Alc,Blc,Clc,Dlc,'StateName',lc_x,'inputname',lc_u,'outputname',lc_y);
    
                    ss_list{end+1} = Lc_ss;                    

                else % RL filter

                    % plant: RL filter and trafo                
                    Arl=[-(Rc+Rtr)/(Lc+Ltr) -wb;
                         wb -(Rc+Rtr)/(Lc+Ltr)];
                    Brl=[+1/(Lc+Ltr) 0 -1/(Lc+Ltr) 0;
                         0 +1/(Lc+Ltr) 0 -1/(Lc+Ltr)];
                    Crl=[1 0;
                         0 1;
                         (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr) 0;
                         0 (Lc*Rtr-Ltr*(Rc))/(Lc+Ltr)];
                    Drl=[0 0 0 0;
                         0 0 0 0;
 	                     Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr) 0;
                         0 Ltr/(Lc+Ltr) 0 Lc/(Lc+Ltr)];
                    rl_x={is_q is_d};
                    rl_u={'vc_q' 'vc_d' 'vg_q' 'vg_d'};
                    rl_y={is_q is_d 'u_q' 'u_d'};
                    rl = ss(Arl,Brl,Crl,Drl,'StateName',rl_x,'inputname',rl_u,'outputname',rl_y);
    
                    ss_list{end+1} = rl;

                end            

                % Build complete model
                input_vars = {'vg_sys_q','vg_sys_d',REF_w}; 
                output_vars = {iq,id,w_vsc};                  
                SS_GFOL = connect(ss_list{:},input_vars,output_vars); 

                %  adapt inputs/outputs
                SS_GFOL.InputName(1) = {vnXq};
                SS_GFOL.InputName(2) = {vnXd};

                % append ss to l_blocks
                l_blocks{end+1} = SS_GFOL; 

            % -------------------------------------------------------------
            case 'GFOR'
            % -------------------------------------------------------------
    
                % ---------------------------------------------------------
                % Set names of state variables, inputs and outputs     
                % ---------------------------------------------------------

                num = T_VSC.number(vsc); %number of the USER element
                bus = T_VSC.bus(vsc);
                
                % Frequency droop
                fdroop_x1 = ['GFOR' num2str(num) '.p_filt_x']; 
                P_ref     = ['GFOR' num2str(num) '.P_ref']; 
                
                % Voltage droop
                udroop_x1  = ['GFOR' num2str(num) '.q_filt_x']; 
                Q_ref      = ['GFOR' num2str(num) '.Q_ref']; 
                
                % LC:
                is_q   = ['GFOR' num2str(num) '.is_q']; 
                is_d   = ['GFOR' num2str(num) '.is_d']; 
                ucap_q = ['GFOR' num2str(num) '.ucap_q']; 
                ucap_d = ['GFOR' num2str(num) '.ucap_d']; 
                
                % AC side voltage control:
                u_q_x1 = ['GFOR' num2str(num) '.Ke_u_q'];  
                u_d_x2 = ['GFOR' num2str(num) '.Ke_u_d']; 
                u_qc_ref = ['GFOR' num2str(num) '.u_qc_ref'];
                u_dc_ref = ['GFOR' num2str(num) '.u_dc_ref']; 
                
                % AC side current control
                is_q_x1   = ['GFOR' num2str(num) '.Ke_is_q'];  
                is_q_x2   = ['GFOR' num2str(num) '.Ke_is_d']; 
                is_qc_ref = ['GFOR' num2str(num) '.is_qc_ref'];
                is_dc_ref = ['GFOR' num2str(num) '.is_dc_ref']; 
                
                % omega to angle VSC (1/s)
                angle_vsc_x = ['GFOR' num2str(num) '.angle_vsc_x']; 
                w_vsc       = ['GFOR' num2str(num) '.w']; 
                
                % omega to angle grid (1/s)
                etheta_x = ['GFOR' num2str(num) '.etheta_x']; 
                
                % AC voltage feedforward filter 
                f_igd_x1 = ['GFOR' num2str(num) '.igd_ff_x']; 
                f_igq_x1 = ['GFOR' num2str(num) '.igq_ff_x']; 
                
                % Trafo
                ig_q    = ['GFOR' num2str(num) '.ig_q'];
                ig_d    = ['GFOR' num2str(num) '.ig_d'];
                
                % in/out voltages & currents in grid (global) ref
                vnXq = ['NET.vn' num2str(bus) 'q'];    
                vnXd = ['NET.vn' num2str(bus) 'd'];    
                iq   = ['VSC' num2str(num) '.iq'];    
                id   = ['VSC' num2str(num) '.id'];    

                % ---------------------------------------------------------
                % Parameters
                % ---------------------------------------------------------

                % Transformer
                Rtr    = T_VSC.Rtr(vsc);
                Ltr    = T_VSC.Ltr(vsc);
                % RL filter
                Rc = T_VSC.Rc(vsc);
                Lc = T_VSC.Lc(vsc);
                Cac = T_VSC.Cac(vsc);
                Rac = T_VSC.Rac(vsc);
                % Currrent control
                kp_s = T_VSC.kp_s(vsc);
                ki_s = T_VSC.ki_s(vsc);
                % AC voltage control
                kp_vac = T_VSC.kp_vac(vsc);
                ki_vac = T_VSC.ki_vac(vsc);   
                % Feedforward fitlers
                tau_u = T_VSC.tau_u(vsc);
                tau_ig = T_VSC.tau_ig(vsc);
                % Droop parameters
                tau_droop_f = T_VSC.tau_droop_f(vsc);
                k_droop_f   = T_VSC.k_droop_f(vsc);
                tau_droop_u = T_VSC.tau_droop_u(vsc);
                k_droop_u   = T_VSC.k_droop_u(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                ucap_q0    = lp_VSC{vsc}.ucap_q0;
                ucap_d0    = lp_VSC{vsc}.ucap_d0;               
                vc_qc0  = lp_VSC{vsc}.vc_qc0; 
                vc_dc0  = lp_VSC{vsc}.vc_dc0; 
                w0      = lp_VSC{vsc}.w0; 
                e_theta0 = lp_VSC{vsc}.etheta0; 

                % ---------------------------------------------------------
                % State-Space Model GFOR
                % ---------------------------------------------------------

                % Transforms 
                
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
                
                ss_list{end+1} = vc_l2g;

                % REF transform: ig to ig_c
                Aig_g2l = [0];
                Big_g2l = [0 0 0];
                Cig_g2l = [0;0];
                Dig_g2l = [cos(e_theta0) -sin(e_theta0) -sin(e_theta0)*ig_q0-cos(e_theta0)*ig_d0;
                          sin(e_theta0) cos(e_theta0) cos(e_theta0)*ig_q0-sin(e_theta0)*ig_d0];
                ig_g2l_x = {''};
                ig_g2l_u = {ig_q,ig_d 'e_theta'};
                ig_g2l_y = {'ig_qc','ig_dc'};
                ig_g2l   = ss(Aig_g2l,Big_g2l,Cig_g2l,Dig_g2l,'StateName',ig_g2l_x,'inputname',ig_g2l_u,'outputname',ig_g2l_y);
                
                ss_list{end+1} = ig_g2l;                

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
                
                ss_list{end+1} = is_g2l;

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
            
                ss_list{end+1} = u_g2l;

                % Change base of voltage: system -> vsc
                Avsc_pu=[0 0;0 0];
                Bvsc_pu=[0 0; 0 0];
                Cvsc_pu=[0 0;0 0];
                Dvsc_pu=[1 0; 0 1]/Vl2g;                 
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};
                vvsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vvsc_pu_x,'inputname',vvsc_pu_u,'outputname',vvsc_pu_y);
            
                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu -> System pu
                Avsc_pu=[0 0; 0 0];
                Bvsc_pu=[0 0; 0 0];
                Cvsc_pu=[0 0;0 0];
                Dvsc_pu=[1 0; 0 1]*Il2g;
                vsc_pu_x={''}; 
                vsc_pu_u={ig_q,ig_d};
                vsc_pu_y={iq, id};
                vsc_pu = ss(Avsc_pu,Bvsc_pu,Cvsc_pu,Dvsc_pu,'StateName',vsc_pu_x,'inputname',vsc_pu_u,'outputname',vsc_pu_y);

                ss_list{end+1} = vsc_pu;

                % Angle deviation               
                if ~(num==num_slk && element_slk == "GFOR")
                    % Angle deviation from system reference
                    Adang=[0];
                    Bdang=[1 -1];
                    Cdang=[1];
                    Ddang=[0 0];
                    dang_x={etheta_x};
                    dang_u={w_vsc,REF_w};
                    dang_y={'e_theta'};
                    dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
                    ss_list{end+1} = dang;
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
                    ss_list{end+1} = dang;
                end
                
                % Frequency droop with low-pass filter in Pac:
                Afdroop=[-1/tau_droop_f];
                Bfdroop=[0 3/2*ig_q0 3/2*ig_d0 3/2*u_q0 3/2*u_d0];
                Cfdroop=[-k_droop_f/tau_droop_f*wb];
                Dfdroop=[+k_droop_f*wb 0 0 0 0];
                fdroop_x={fdroop_x1};
                fdroop_u={P_ref 'u_q' 'u_d' ig_q ig_d};
                fdroop_y={w_vsc};
                fdroop = ss(Afdroop,Bfdroop,Cfdroop,Dfdroop,'StateName',fdroop_x,'inputname',fdroop_u,'outputname',fdroop_y);
                ss_list{end+1} = fdroop;      

                % Voltage droop with low-pass filter in Qac:
                Audroop=[-1/tau_droop_u];
                Budroop=[0 -3/2*ig_d0 3/2*ig_q0 3/2*u_d0 -3/2*u_q0];
                Cudroop=[k_droop_u/tau_droop_u];
                Dudroop=[+k_droop_u 0 0 0 0];
                udroop_x={udroop_x1};
                udroop_u={Q_ref 'u_q' 'u_d' ig_q ig_d};
                udroop_y={u_qc_ref};
                udroop = ss(Audroop,Budroop,Cudroop,Dudroop,'StateName',udroop_x,'inputname',udroop_u,'outputname',udroop_y);
                ss_list{end+1} = udroop;
                
                % AC side voltage control:
                Au  = [0 0; 0 0];
                Bu  = [1 0 -1 0 0 0;
                       0 1 0 -1 0 0];
                Cu  = [+ki_vac 0;
                        0 +ki_vac];
                Du  = [+kp_vac 0 -kp_vac +wb*Cac 1 0;
                          0 +kp_vac -wb*Cac -kp_vac 0 1];
                u_x = {u_q_x1, u_d_x2};
                u_u = {u_qc_ref,u_dc_ref,'u_qc','u_dc','ig_qc_f','ig_dc_f'};
                u_y = {is_qc_ref ,is_dc_ref};
                ss_u   = ss(Au,Bu,Cu,Du,'StateName',u_x,'inputname',u_u,'outputname',u_y);
                ss_list{end+1} = ss_u;
                
                % AC side current control
                Ais = [0 0; 0 0];
                Bis = [1 0 -1 0 0 0;
                       0 1 0 -1 0 0];
                Cis = [+ki_s 0;
                        0 +ki_s];
                Dis = [+kp_s 0     -kp_s  +wb*Lc 1 0;
                          0     +kp_s -wb*Lc -kp_s  0 1];
                is_x = {is_q_x1 is_q_x2};
                is_u = {is_qc_ref  is_dc_ref 'is_qc' 'is_dc' 'u_qc_f' 'u_dc_f'};
                is_y = {'vc_qc' 'vc_dc'};
                is   = ss(Ais,Bis,Cis,Dis,'StateName',is_x,'inputname',is_u,'outputname',is_y);
                ss_list{end+1} = is;
                
                % AC voltage feedforward filter 
                num_ig=1;
                den_ig=[tau_ig 1];
                [Af_ig,Bf_ig,Cf_ig,Df_ig]=tf2ss(num_ig,den_ig);
                f_igd_x={f_igd_x1};
                f_igd_u={'ig_dc'};
                f_igd_y={'ig_dc_f'};
                f_igd = ss(Af_ig,Bf_ig,Cf_ig,Df_ig,'StateName',f_igd_x,'inputname',f_igd_u,'outputname',f_igd_y);
                ss_list{end+1} = f_igd;
                
                f_igq_x={f_igq_x1};
                f_igq_u={'ig_qc'};
                f_igq_y={'ig_qc_f'};
                f_igq = ss(Af_ig,Bf_ig,Cf_ig,Df_ig,'StateName',f_igq_x,'inputname',f_igq_u,'outputname',f_igq_y);
                ss_list{end+1} = f_igq;
                
                % current feedforward filter 
                num_u=1;
                den_u=1;
                [Af_u,Bf_u,Cf_u,Df_u]=tf2ss(num_u,den_u);
                f_ud_x={''};
                f_ud_u={'u_dc'};
                f_ud_y={'u_dc_f'};
                f_ud = ss(Af_u,Bf_u,Cf_u,Df_u,'StateName',f_ud_x,'inputname',f_ud_u,'outputname',f_ud_y);
                ss_list{end+1} = f_ud;
                
                f_uq_x={''};
                f_uq_u={'u_qc'};
                f_uq_y={'u_qc_f'};
                f_uq = ss(Af_u,Bf_u,Cf_u,Df_u,'StateName',f_uq_x,'inputname',f_uq_u,'outputname',f_uq_y);
                ss_list{end+1} = f_uq;

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
                tr_y = {ig_q, ig_d};
                tr_ss = ss(Atr,Btr,Ctr,Dtr,'StateName',tr_x,'inputname',tr_u,'outputname',tr_y);

                ss_list{end+1} = tr_ss;

                % LC:
                Alc =  [(-Rc-Rac)/Lc -wb -1/Lc 0;
                           wb (-Rc-Rac)/Lc 0 -1/Lc;
                           1/Cac 0 0 -wb;
                           0 1/Cac wb 0];
                Blc =  [1/Lc 0 Rac/Lc 0 -is_d0; 
                           0 1/Lc 0 Rac/Lc +is_q0;
                           0 0 -1/Cac 0 -ucap_d0; 
                           0 0 0 -1/Cac +ucap_q0];
                Clc  = [1 0 0 0;
                           0 1 0 0;
                           Rac 0 1 0;
                           0 Rac 0 1];
                Dlc =  [0 0 0 0 0;
                           0 0 0 0 0;
                           0 0 -Rac 0 0;
                           0 0 0 -Rac 0];
                lc_x    = {is_q is_d ucap_q ucap_d};
                if ~(num==num_slk && element_slk == "GFOR")
                    lc_u = {'vc_q' 'vc_d' ig_q ig_d REF_w};
                else
                    lc_u = {'vc_q' 'vc_d' ig_q ig_d w_vsc};
                end
                lc_y = {is_q is_d 'u_q' 'u_d'};
                Lc_ss = ss(Alc,Blc,Clc,Dlc,'StateName',lc_x,'inputname',lc_u,'outputname',lc_y);
                ss_list{end+1} = Lc_ss;
                
                % Build complete model
                if num==num_slk && element_slk == "GFOR"
                    input_vars = {'vg_sys_q','vg_sys_d'};
                else
                    input_vars = {'vg_sys_q','vg_sys_d',REF_w};
                end
                output_vars = {iq,id,w_vsc}; 

                SS_GFOR = connect(ss_list{:},input_vars,output_vars);  
                                
                %  adapt inputs/outputs
                SS_GFOR.InputName(1) = {vnXq};
                SS_GFOR.InputName(2) = {vnXd};
                if num==num_slk && element_slk == "GFOR"
                    SS_GFOR.OutputName(3) = {REF_w};
                end

                % append ss to l_blocks
                l_blocks{end+1} = SS_GFOR; 


            case 'STATCOM'
            % WRITE SS
        end



    end
end