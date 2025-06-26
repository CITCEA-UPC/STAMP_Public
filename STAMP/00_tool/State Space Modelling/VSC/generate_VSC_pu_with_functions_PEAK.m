% GENERATE STATE-SPACE MODEL OF SYNCHRONOUS GENERATOR IN PU
% SG base: peak phase-to-ground
% System base: rms line-to-line

function l_blocks = generate_VSC_pu_with_functions_PEAK(l_blocks,T_VSC, lp_VSC, T_global, num_slk, element_slk, REF_w)

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
        area = T_VSC.Area(vsc);
        syncarea = T_VSC.SyncArea(vsc);

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

                % Commutation delay
                cmd_qx1   = ['GFOL' num2str(num) '.cmdq1'];  
                cmd_qx2   = ['GFOL' num2str(num) '.cmdq2']; 
                cmd_qx3   = ['GFOL' num2str(num) '.cmdq3'];
                cmd_dx1   = ['GFOL' num2str(num) '.cmdd1'];  
                cmd_dx2   = ['GFOL' num2str(num) '.cmdd2']; 
                cmd_dx3   = ['GFOL' num2str(num) '.cmdd3']; 

                % Measurement delay
                if T_VSC.tau_md(vsc)==0
                isq_md_x  =  [];
                uq_md_x   =  [];
                igq_md_x  =  [];
                isd_md_x  =  [];
                ud_md_x   =  [];
                igd_md_x  =  [];
                else
                isq_md_x  =  ['GFOL' num2str(num) '.isq_md'];
                uq_md_x   =  ['GFOL' num2str(num) '.uq_md'];
                igq_md_x  =  ['GFOL' num2str(num) '.igq_md'];
                isd_md_x  =  ['GFOL' num2str(num) '.isd_md'];
                ud_md_x   =  ['GFOL' num2str(num) '.ud_md'];
                igd_md_x  =  ['GFOL' num2str(num) '.igd_md'];
                end

                % Measurement ZOH
                if T_VSC.tau_zoh(vsc)==-1
                isq_zoh_x = [];
                uq_zoh_x = [];
                vdiffq_zoh_x = [];
                igq_zoh_x = [];
                isd_zoh_x = [];
                ud_zoh_x = [];
                igd_zoh_x = [];
                vdiffd_zoh_x = [];
                else
                isq_zoh_x1  =  ['GFOL' num2str(num) '.isq_zoh1'];
                isq_zoh_x2  =  ['GFOL' num2str(num) '.isq_zoh2'];
                isq_zoh_x = {isq_zoh_x1;isq_zoh_x2};
                uq_zoh_x1   =  ['GFOL' num2str(num) '.uq_zoh1'];
                uq_zoh_x2   =  ['GFOL' num2str(num) '.uq_zoh2'];
                uq_zoh_x = {uq_zoh_x1;uq_zoh_x2};
                vdiffq_zoh_x1   =  ['GFOL' num2str(num) '.vdiffq_zoh1'];
                vdiffq_zoh_x2   =  ['GFOL' num2str(num) '.vdiffq_zoh2'];
                vdiffq_zoh_x = {vdiffq_zoh_x1,vdiffq_zoh_x2};
                igq_zoh_x1  =  ['GFOL' num2str(num) '.igq_zoh1'];
                igq_zoh_x2  =  ['GFOL' num2str(num) '.igq_zoh2'];
                igq_zoh_x = {igq_zoh_x1;igq_zoh_x2};
                isd_zoh_x1  =  ['GFOL' num2str(num) '.isd_zoh1'];
                isd_zoh_x2  =  ['GFOL' num2str(num) '.isd_zoh2'];
                isd_zoh_x = {isd_zoh_x1;isd_zoh_x2};
                ud_zoh_x1   =  ['GFOL' num2str(num) '.ud_zoh1'];
                ud_zoh_x2   =  ['GFOL' num2str(num) '.ud_zoh2'];
                ud_zoh_x = {ud_zoh_x1;ud_zoh_x2};
                igd_zoh_x1  =  ['GFOL' num2str(num) '.igd_zoh1'];
                igd_zoh_x2  =  ['GFOL' num2str(num) '.igd_zoh2'];
                igd_zoh_x = {igd_zoh_x1;igd_zoh_x2};
                vdiffd_zoh_x1   =  ['GFOL' num2str(num) '.vdiffd_zoh1'];
                vdiffd_zoh_x2   =  ['GFOL' num2str(num) '.vdiffd_zoh2'];
                vdiffd_zoh_x = {vdiffd_zoh_x1;vdiffd_zoh_x2};
                end
                
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
                % Measurement delay
                tau_md = T_VSC.tau_md(vsc);
                % Commutation delay
                tau_cmd = T_VSC.tau_cmd(vsc);
                % ZOH delay
                tau_zoh = T_VSC.tau_zoh(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                ig_qc0   = lp_VSC{vsc}.ig_qc0; 
                ig_dc0   = lp_VSC{vsc}.ig_dc0;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                is_qc0   = lp_VSC{vsc}.is_qc0; 
                is_dc0   = lp_VSC{vsc}.is_dc0;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                u_qc0    = lp_VSC{vsc}.u_qc0;
                u_dc0    = lp_VSC{vsc}.u_dc0;
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
                vc_l2g_x = {''};
                vc_l2g_u = {'vc_qc','vc_dc','e_theta'};
                vc_l2g_y = {'vc_q','vc_d'};
                vc_l2g   = build_local2global(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0,vc_qc0,vc_dc0);

                ss_list{end+1} = vc_l2g ;
                
                % REF transform: is to is_c (global -> local)
                is_g2l_x = {''};
                is_g2l_u = {is_q, is_d, 'e_theta'};
                is_g2l_y = {'is_qc_pre_md' 'is_dc_pre_md'};
                is_g2l   = build_global2local(is_g2l_x,is_g2l_u,is_g2l_y,e_theta0,is_q0,is_d0);

                ss_list{end+1} = is_g2l;

                %isq measurement delay
                isq_md_u = is_g2l_y{1};
                isq_md_y = {'is_qc_pre_zoh'};
                isq_measurement_delay = build_measurement_delay(isq_md_x,isq_md_u,isq_md_y,tau_md);

                ss_list{end+1} = isq_measurement_delay;

                %isd measurement delay
                isd_md_u = is_g2l_y{2};
                isd_md_y = {'is_dc_pre_zoh'};
                isd_measurement_delay = build_measurement_delay(isd_md_x,isd_md_u,isd_md_y,tau_md);

                ss_list{end+1} = isd_measurement_delay;

                %isq ZOH delay
                isq_zoh_u = isq_md_y;
                isq_zoh_y = {'is_qc'};
                isq_zoh_delay = build_zoh2_2order(isq_zoh_x,isq_zoh_u,isq_zoh_y,tau_zoh);

                ss_list{end+1} = isq_zoh_delay;

                %isd ZOH delay
                isd_zoh_u = isd_md_y;
                isd_zoh_y = {'is_dc'};
                isd_zoh_delay = build_zoh2_2order(isd_zoh_x,isd_zoh_u,isd_zoh_y,tau_zoh);

                ss_list{end+1} = isd_zoh_delay;

                % REF transform: ig to ig_c (global -> local)
                ig_g2l_x = {''};
                ig_g2l_u = {ig_q, ig_d, 'e_theta'};
                ig_g2l_y = {'ig_qc_pre_md' 'ig_dc_pre_md'};
                ig_g2l   = build_global2local(ig_g2l_x,ig_g2l_u,ig_g2l_y,e_theta0,ig_q0,ig_d0);

                ss_list{end+1} = ig_g2l;

                %igq measurement delay
                igq_md_u = ig_g2l_y{1};
                igq_md_y = {'ig_qc_pre_zoh'};
                igq_measurement_delay = build_measurement_delay(igq_md_x,igq_md_u,igq_md_y,tau_md);

                ss_list{end+1} = igq_measurement_delay;

                %igd measurement delay
                igd_md_u = ig_g2l_y{2};
                igd_md_y = {'ig_dc_pre_zoh'};
                igd_measurement_delay = build_measurement_delay(igd_md_x,igd_md_u,igd_md_y,tau_md);

                ss_list{end+1} = igd_measurement_delay;

                %igq ZOH delay
                igq_zoh_u = igq_md_y;
                igq_zoh_y = {'ig_qc'};
                igq_zoh_delay = build_zoh2_2order(igq_zoh_x,igq_zoh_u,igq_zoh_y,tau_zoh);

                ss_list{end+1} = igq_zoh_delay;

                %igd ZOH delay
                igd_zoh_u = igd_md_y;
                igd_zoh_y = {'ig_dc'};
                igd_zoh_delay = build_zoh2_2order(igd_zoh_x,igd_zoh_u,igd_zoh_y,tau_zoh);

                ss_list{end+1} = igd_zoh_delay;
                              
                % REF transform: u to u_c (global -> local)
                u_g2l_x = {''};
                u_g2l_u = {'u_q','u_d','e_theta'};
                u_g2l_y = {'u_qc_pre_md','u_dc_pre_md'};
                u_g2l   = build_global2local(u_g2l_x,u_g2l_u,u_g2l_y,e_theta0,u_q0,u_d0);

                ss_list{end+1} = u_g2l;

                %uq measurement delay
                uq_md_u = u_g2l_y{1};
                uq_md_y = {'u_qc_pre_zoh'};
                uq_measurement_delay = build_measurement_delay(uq_md_x,uq_md_u,uq_md_y,tau_md);
                ss_list{end+1} = uq_measurement_delay;

                %ud measurement delay
                ud_md_u = u_g2l_y{2};
                ud_md_y = {'u_dc_pre_zoh'};
                ud_measurement_delay = build_measurement_delay(ud_md_x,ud_md_u,ud_md_y,tau_md);
                ss_list{end+1} = ud_measurement_delay;

                %uq ZOH delay
                uq_zoh_u = uq_md_y;
                uq_zoh_y = {'u_qc'};
                uq_zoh_delay = build_zoh2_2order(uq_zoh_x,uq_zoh_u,uq_zoh_y,tau_zoh);
                ss_list{end+1} = uq_zoh_delay;

                %ud ZOH delay
                ud_zoh_u = ud_md_y;
                ud_zoh_y = {'u_dc'};
                ud_zoh_delay = build_zoh2_2order(ud_zoh_x,ud_zoh_u,ud_zoh_y,tau_zoh);
                ss_list{end+1} = ud_zoh_delay;

                % Change base of voltage: system -> vsc              
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};
                %vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,Vl2g);
                vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,1);
                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu -> System pu

                if T_VSC.Cac(vsc) % RLC filter
                    vsc_pu_x={''}; 
                    vsc_pu_u={ig_q,ig_d};
                    vsc_pu_y={iq, id};
                else % RL filter
                    % Change base of current: VSC pu -> System pu
                    vsc_pu_x={''}; 
                    vsc_pu_u={is_q,is_d};
                    vsc_pu_y={iq, id};
                end

                %vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Il2g);
                vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Sl2g);
                ss_list{end+1} = vsc_pu;
                                
                % PLL:
                pll_x={pll_x};
                %pll_u={'u_dc_pre_zoh'};
                pll_u={'u_dc'};
                %pll_u={'vc_d'};
                pll_y={'w_vsc_pu'};
                pll = build_pll(pll_x,pll_u,pll_y,kp_pll,ki_pll);

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
                dang_x={etheta_x};
                dang_u1={w_vsc,[REF_w num2str(syncarea)]};
                dang_u2={w_vsc};
                dang_y={'e_theta'};
                dang = build_angle_deviation(dang_x,dang_u1,dang_u2,dang_y,num,num_slk,element_slk,syncarea);

                ss_list{end+1} = dang;

                % Frequency droop with low-pass filter on omega:
                fdroop_x={fdroop_x};
                fdroop_u={omega_ref,w_vsc};
                fdroop_y={P_ref};
                fdroop = build_frequency_droop(fdroop_x,fdroop_u,fdroop_y,k_droop_f,tau_droop_f,wb);

                ss_list{end+1} = fdroop;
                
                % voltage magnitude
                x = {''};
                u = {'u_qc' 'u_dc'};
                y = {'Umag'};
                ss_u = build_voltage_magnitude(x,u,y,u_qc0,u_dc0);

                ss_list{end+1} = ss_u;
                
                % Voltage droop with low-pass filter in v:
                udroop_x = {udroop_x};
                udroop_u = {Umag_ref,'Umag'};
                udroop_y = {Q_ref};
                udroop   = build_voltage_droop(udroop_x,udroop_u,udroop_y,k_droop_u,tau_droop_u);

                ss_list{end+1} = udroop;

                % PQ control
                
                if T_VSC.Cac(vsc) % RLC filter

                    % P control
                    p_x={p_x};
                    p_u={P_ref,'ig_qc','ig_dc','u_qc','u_dc'};
                    p_y={is_qc_ref};
                    ss_p = build_active_power_control(p_x,p_u,p_y,kp_P,ki_P,ig_qc0,ig_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_p;
                    
                    % Q control
                    q_x={q_x};
                    q_u={Q_ref,'ig_qc','ig_dc','u_qc','u_dc'};
                    q_y={is_dc_ref};
                    ss_q = build_reactive_power_control(q_x,q_u,q_y,kp_Q,ki_Q,ig_qc0,ig_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_q;

                else % RL filter

                    % P control
                    p_x={p_x};
                    p_u={P_ref,'is_qc','is_dc','u_qc','u_dc'};
                    p_y={is_qc_ref};
                    ss_p = build_active_power_control(p_x,p_u,p_y,kp_P,ki_P,is_qc0,is_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_p;
                    
                    % Q control
                    q_x={q_x};
                    q_u={Q_ref,'is_qc','is_dc','u_qc','u_dc'};
                    q_y={is_dc_ref};
                    ss_q = build_reactive_power_control(q_x,q_u,q_y,kp_Q,ki_Q,is_qc0,is_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_q;

                end
                                
                % AC side current control
                is_x = {is_q_x1 is_q_x2};
                is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','u_qc','u_dc'};
                %is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','u_qc','u_dc','ig_qc','ig_dc'};
                is_y = {'vc_qc_pre_zoh' 'vc_dc_pre_zoh'};
                is   =  build_ac_current_loop(is_x,is_u,is_y,kp_s,ki_s,Lc,wb);
                %is   =  build_ac_current_loop_cigre(is_x,is_u,is_y,kp_s,ki_s,Lc,wb);

                ss_list{end+1} =  is;

                % ZOH vdiffq delay
                zoh_vdiffq_u = is_y{1};
                zoh_vdiffq_y = {'vc_q_pre_cmd'};
                zoh_vdiff_q = build_zoh2_2order(vdiffq_zoh_x,zoh_vdiffq_u,zoh_vdiffq_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_q;

                % ZOH vdiffd delay
                zoh_vdiffd_u = is_y{2};
                zoh_vdiffd_y = {'vc_d_pre_cmd'};
                zoh_vdiff_d = build_zoh2_2order(vdiffd_zoh_x,zoh_vdiffd_u,zoh_vdiffd_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_d;

                % Commutation delay q
                cmd_u = zoh_vdiffq_y;
                cmd_y = {'vc_qc'};
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_u = zoh_vdiffd_y;
                cmd_y = {'vc_dc'};
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_d;

                % RL/RLC filter and trafo
                if T_VSC.Cac(vsc) % RLC filter
                    % Transformer 
                    tr_x = {ig_q, ig_d};
                    tr_u = {'u_q','u_d','vg_q','vg_d'};
                    tr_y = {ig_q, ig_d};
                    tr_ss = build_transformer(tr_x,tr_u,tr_y,Rtr,Ltr,w0);
    
                    ss_list{end+1} = tr_ss;
    
                    % LC:
                    lc_x = {is_q is_d ucap_q ucap_d};
                    lc_u = {'vc_q','vc_d',ig_q,ig_d,[REF_w num2str(syncarea)]};
                    lc_y = {is_q is_d 'u_q' 'u_d'};
                    Lc_ss = build_lc_filter(lc_x,lc_u,lc_y,Rc,Rac,Lc,Cac,wb,is_q0,is_d0,ucap_q0,ucap_d0);
    
                    ss_list{end+1} = Lc_ss;                    

                else % RL filter

                    % plant: RL filter and trafo                
                    rl_x={is_q is_d};
                    rl_u={'vc_q','vc_d','vg_q','vg_d'};
                    rl_y={is_q is_d 'u_q' 'u_d'};
                    rl = build_rl_filter(rl_x,rl_u,rl_y,Rc,Lc,Rtr,Ltr,wb);
    
                    ss_list{end+1} = rl;

                end            

                % Build complete model
                input_vars = {'vg_sys_q','vg_sys_d',[REF_w num2str(syncarea)]}; 
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

                % Commutation delay
                cmd_qx1   = ['GFOR' num2str(num) '.cmdq1'];  
                cmd_qx2   = ['GFOR' num2str(num) '.cmdq2']; 
                cmd_dx1   = ['GFOR' num2str(num) '.cmdd1'];  
                cmd_dx2   = ['GFOR' num2str(num) '.cmdd2']; 

                % Measurement delay
                if T_VSC.tau_md(vsc)==0
                isq_md_x  =  [];
                uq_md_x   =  [];
                igq_md_x  =  [];
                isd_md_x  =  [];
                ud_md_x   =  [];
                igd_md_x  =  [];
                else
                isq_md_x  =  ['GFOR' num2str(num) '.isq_md'];
                uq_md_x   =  ['GFOR' num2str(num) '.uq_md'];
                igq_md_x  =  ['GFOR' num2str(num) '.igq_md'];
                isd_md_x  =  ['GFOR' num2str(num) '.isd_md'];
                ud_md_x   =  ['GFOR' num2str(num) '.ud_md'];
                igd_md_x  =  ['GFOR' num2str(num) '.igd_md'];
                end

                % Measurement ZOH
                if T_VSC.tau_zoh(vsc)==-1
                isq_zoh_x = [];
                uq_zoh_x = [];
                vdiffq_zoh_x = [];
                igq_zoh_x = [];
                isd_zoh_x = [];
                ud_zoh_x = [];
                igd_zoh_x = [];
                vdiffd_zoh_x = [];
                else
                isq_zoh_x1  =  ['GFOR' num2str(num) '.isq_zoh1'];
                isq_zoh_x2  =  ['GFOR' num2str(num) '.isq_zoh2'];
                isq_zoh_x = {isq_zoh_x1;isq_zoh_x2};
                uq_zoh_x1   =  ['GFOR' num2str(num) '.uq_zoh1'];
                uq_zoh_x2   =  ['GFOR' num2str(num) '.uq_zoh2'];
                uq_zoh_x = {uq_zoh_x1;uq_zoh_x2};
                vdiffq_zoh_x1   =  ['GFOR' num2str(num) '.vdiffq_zoh1'];
                vdiffq_zoh_x2   =  ['GFOR' num2str(num) '.vdiffq_zoh2'];
                vdiffq_zoh_x = {vdiffq_zoh_x1,vdiffq_zoh_x2};
                igq_zoh_x1  =  ['GFOR' num2str(num) '.igq_zoh1'];
                igq_zoh_x2  =  ['GFOR' num2str(num) '.igq_zoh2'];
                igq_zoh_x = {igq_zoh_x1;igq_zoh_x2};
                isd_zoh_x1  =  ['GFOR' num2str(num) '.isd_zoh1'];
                isd_zoh_x2  =  ['GFOR' num2str(num) '.isd_zoh2'];
                isd_zoh_x = {isd_zoh_x1;isd_zoh_x2};
                ud_zoh_x1   =  ['GFOR' num2str(num) '.ud_zoh1'];
                ud_zoh_x2   =  ['GFOR' num2str(num) '.ud_zoh2'];
                ud_zoh_x = {ud_zoh_x1;ud_zoh_x2};
                igd_zoh_x1  =  ['GFOR' num2str(num) '.igd_zoh1'];
                igd_zoh_x2  =  ['GFOR' num2str(num) '.igd_zoh2'];
                igd_zoh_x = {igd_zoh_x1;igd_zoh_x2};
                vdiffd_zoh_x1   =  ['GFOR' num2str(num) '.vdiffd_zoh1'];
                vdiffd_zoh_x2   =  ['GFOR' num2str(num) '.vdiffd_zoh2'];
                vdiffd_zoh_x = {vdiffd_zoh_x1;vdiffd_zoh_x2};
                end

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
                % Measurement delay
                tau_md = T_VSC.tau_md(vsc);
                % Commutation delay
                tau_cmd = T_VSC.tau_cmd(vsc);
                % ZOH delay
                tau_zoh = T_VSC.tau_zoh(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                ig_qc0   = lp_VSC{vsc}.ig_qc0; 
                ig_dc0   = lp_VSC{vsc}.ig_dc0;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                is_qc0   = lp_VSC{vsc}.is_qc0; 
                is_dc0   = lp_VSC{vsc}.is_dc0;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                u_qc0    = lp_VSC{vsc}.u_qc0;
                u_dc0    = lp_VSC{vsc}.u_dc0;
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
                
                % REF INVERSE transform: vc_c to vc (local -> global)
                vc_l2g_x = {''};
                vc_l2g_u = {'vc_qc','vc_dc','e_theta'};
                vc_l2g_y = {'vc_q','vc_d'};
                vc_l2g   = build_local2global(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0,vc_qc0,vc_dc0);

                ss_list{end+1} = vc_l2g ;

                % REF transform: ig to ig_c (global -> local)
                ig_g2l_x = {''};
                ig_g2l_u = {ig_q,ig_d,'e_theta'};
                ig_g2l_y = {'ig_qc_pre_md' 'ig_dc_pre_md'};
                ig_g2l   = build_global2local(ig_g2l_x,ig_g2l_u,ig_g2l_y,e_theta0,ig_q0,ig_d0);

                ss_list{end+1} = ig_g2l;       

                %igq measurement delay
                igq_md_u = ig_g2l_y{1};
                igq_md_y = {'ig_qc_pre_zoh'};
                igq_measurement_delay = build_measurement_delay(igq_md_x,igq_md_u,igq_md_y,tau_md);

                ss_list{end+1} = igq_measurement_delay;

                %igd measurement delay
                igd_md_u = ig_g2l_y{2};
                igd_md_y = {'ig_dc_pre_zoh'};
                igd_measurement_delay = build_measurement_delay(igd_md_x,igd_md_u,igd_md_y,tau_md);

                ss_list{end+1} = igd_measurement_delay;

                %igq ZOH delay
                igq_zoh_u = igq_md_y;
                igq_zoh_y = {'ig_qc'};
                igq_zoh_delay = build_zoh2_2order(igq_zoh_x,igq_zoh_u,igq_zoh_y,tau_zoh);

                ss_list{end+1} = igq_zoh_delay;

                %igd ZOH delay
                igd_zoh_u = igd_md_y;
                igd_zoh_y = {'ig_dc'};
                igd_zoh_delay = build_zoh2_2order(igd_zoh_x,igd_zoh_u,igd_zoh_y,tau_zoh);

                ss_list{end+1} = igd_zoh_delay;


                % REF transform: is to is_c (global -> local)
                is_g2l_x = {''};
                is_g2l_u = {is_q,is_d,'e_theta'};
                is_g2l_y = {'is_qc_pre_md' 'is_dc_pre_md'};
                is_g2l   = build_global2local(is_g2l_x,is_g2l_u,is_g2l_y,e_theta0,is_q0,is_d0);

                ss_list{end+1} = is_g2l;

                %isq measurement delay
                isq_md_u = is_g2l_y{1};
                isq_md_y = {'is_qc_pre_zoh'};
                isq_measurement_delay = build_measurement_delay(isq_md_x,isq_md_u,isq_md_y,tau_md);

                ss_list{end+1} = isq_measurement_delay;

                %isd measurement delay
                isd_md_u = is_g2l_y{2};
                isd_md_y = {'is_dc_pre_zoh'};
                isd_measurement_delay = build_measurement_delay(isd_md_x,isd_md_u,isd_md_y,tau_md);

                ss_list{end+1} = isd_measurement_delay;

                %isq ZOH delay
                isq_zoh_u = isq_md_y;
                isq_zoh_y = {'is_qc'};
                isq_zoh_delay = build_zoh2_2order(isq_zoh_x,isq_zoh_u,isq_zoh_y,tau_zoh);

                ss_list{end+1} = isq_zoh_delay;

                %isd ZOH delay
                isd_zoh_u = isd_md_y;
                isd_zoh_y = {'is_dc'};
                isd_zoh_delay = build_zoh2_2order(isd_zoh_x,isd_zoh_u,isd_zoh_y,tau_zoh);

                ss_list{end+1} = isd_zoh_delay;

                % REF transform: u to u_c (global -> local)
                u_g2l_x = {''};
                u_g2l_u = {'u_q','u_d','e_theta'};
                u_g2l_y = {'u_qc_pre_md','u_dc_pre_md'};
                u_g2l   = build_global2local(u_g2l_x,u_g2l_u,u_g2l_y,e_theta0,u_q0,u_d0);

                ss_list{end+1} = u_g2l;

                %uq measurement delay
                uq_md_u = u_g2l_y{1};
                uq_md_y = {'u_qc_pre_zoh'};
                uq_measurement_delay = build_measurement_delay(uq_md_x,uq_md_u,uq_md_y,tau_md);
                ss_list{end+1} = uq_measurement_delay;

                %ud measurement delay
                ud_md_u = u_g2l_y{2};
                ud_md_y = {'u_dc_pre_zoh'};
                ud_measurement_delay = build_measurement_delay(ud_md_x,ud_md_u,ud_md_y,tau_md);
                ss_list{end+1} = ud_measurement_delay;

                %uq ZOH delay
                uq_zoh_u = uq_md_y;
                uq_zoh_y = {'u_qc'};
                uq_zoh_delay = build_zoh2_2order(uq_zoh_x,uq_zoh_u,uq_zoh_y,tau_zoh);
                ss_list{end+1} = uq_zoh_delay;

                %ud ZOH delay
                ud_zoh_u = ud_md_y;
                ud_zoh_y = {'u_dc'};
                ud_zoh_delay = build_zoh2_2order(ud_zoh_x,ud_zoh_u,ud_zoh_y,tau_zoh);
                ss_list{end+1} = ud_zoh_delay;

                % Change base of voltage: system -> vsc
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};

                %vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,Vl2g);
                vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,1);
                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu -> System pu
                vsc_pu_x={''}; 
                vsc_pu_u={ig_q,ig_d};
                vsc_pu_y={iq, id};
                %vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Il2g);
                vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Sl2g);

                ss_list{end+1} = vsc_pu;

                % Angle deviation               
                dang_x={etheta_x};
                dang_u1={w_vsc,[REF_w num2str(syncarea)]};
                dang_u2={w_vsc};
                dang_y={'e_theta'};
                dang = build_angle_deviation(dang_x,dang_u1,dang_u2,dang_y,num,num_slk,element_slk,syncarea);
                
                ss_list{end+1} = dang;
                % Frequency droop with low-pass filter in Pac:
                fdroop_x={fdroop_x1};
                fdroop_u={P_ref,'u_qc','u_dc','ig_qc','ig_dc'};
                fdroop_y={w_vsc};
                fdroop = build_frequency_droop_withLPF(fdroop_x,fdroop_u,fdroop_y,k_droop_f,tau_droop_f,wb,ig_qc0,ig_dc0,u_qc0,u_dc0);
                ss_list{end+1} = fdroop;      

                % Voltage droop with low-pass filter in Qac:
                udroop_x={udroop_x1};
                udroop_u={Q_ref,'u_qc','u_dc','ig_qc','ig_dc'};
                udroop_y={u_qc_ref};
                udroop = build_voltage_droop_with_QLPF(udroop_x,udroop_u,udroop_y,k_droop_u,tau_droop_u,ig_dc0,ig_qc0,u_qc0,u_dc0);
                ss_list{end+1} = udroop;
                
                % AC side voltage control:
                u_x = {u_q_x1, u_d_x2};
                u_u = {u_qc_ref,u_dc_ref,'u_qc','u_dc','ig_qc_f','ig_dc_f'};
                u_y = {is_qc_ref ,is_dc_ref};
                ss_u   = build_ac_voltage_control(u_x,u_u,u_y,kp_vac,ki_vac,Cac,wb);
                ss_list{end+1} = ss_u;
                
                % AC side current control
                is_x = {is_q_x1 is_q_x2};
                is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','u_qc_f','u_dc_f'};
                is_y = {'vc_qc_pre_zoh' 'vc_dc_pre_zoh'};
                is   =  build_ac_current_loop(is_x,is_u,is_y,kp_s,ki_s,Lc,wb);
                ss_list{end+1} = is;

                % ZOH vdiffq delay
                zoh_vdiffq_u = is_y{1};
                zoh_vdiffq_y = {'vc_q_pre_cmd'};
                zoh_vdiff_q = build_zoh2_2order(vdiffq_zoh_x,zoh_vdiffq_u,zoh_vdiffq_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_q;

                % ZOH vdiffd delay
                zoh_vdiffd_u = is_y{2};
                zoh_vdiffd_y = {'vc_d_pre_cmd'};
                zoh_vdiff_d = build_zoh2_2order(vdiffd_zoh_x,zoh_vdiffd_u,zoh_vdiffd_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_d;

                % Commutation delay q
                cmd_u = zoh_vdiffq_y;
                cmd_y = {'vc_qc'};
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_u = zoh_vdiffd_y;
                cmd_y = {'vc_dc'};
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_d;
                
                % Grid current feedforward filter 
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
                
                % AC Voltage feedforward filter 
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
                tr_x = {ig_q, ig_d};
                tr_u = {'u_q','u_d','vg_q','vg_d'};
                tr_y = {ig_q, ig_d};
                tr_ss = build_transformer(tr_x,tr_u,tr_y,Rtr,Ltr,w0);
                ss_list{end+1} = tr_ss;

                % LC:
                lc_x    = {is_q is_d ucap_q ucap_d};
                if ~(num==num_slk(syncarea) && element_slk{syncarea} == "GFOR")
                    lc_u = {'vc_q','vc_d',ig_q,ig_d,[REF_w num2str(syncarea)]};
                else
                    lc_u = {'vc_q','vc_d',ig_q,ig_d,w_vsc};
                end
                lc_y = {is_q is_d 'u_q' 'u_d'};
                Lc_ss = build_lc_filter(lc_x,lc_u,lc_y,Rc,Rac,Lc,Cac,wb,is_q0,is_d0,ucap_q0,ucap_d0);
                ss_list{end+1} = Lc_ss;
                
                % Build complete model
                if num==num_slk(syncarea) && element_slk{syncarea} == "GFOR"
                    input_vars = {'vg_sys_q','vg_sys_d'};
                else
                    input_vars = {'vg_sys_q','vg_sys_d',[REF_w num2str(syncarea)]};
                end
                output_vars = {iq,id,w_vsc}; 

                SS_GFOR = connect(ss_list{:},input_vars,output_vars);  
                                
                %  adapt inputs/outputs
                SS_GFOR.InputName(1) = {vnXq};
                SS_GFOR.InputName(2) = {vnXd};
                if num==num_slk(syncarea) && element_slk{syncarea} == "GFOR"
                    SS_GFOR.OutputName(3) = {[REF_w num2str(syncarea)]};
                end

                % append ss to l_blocks
                l_blocks{end+1} = SS_GFOR; 


            case 'STATCOM'
            % -------------------------------------------------------------

                % ---------------------------------------------------------
                % Set names of state variables, inputs and outputs     
                % ---------------------------------------------------------

                num = T_VSC.number(vsc); 
                bus = T_VSC.bus(vsc);
                    
                % Frequency droop
                fdroop_x     = ['STATCOM' num2str(num) '.w_filt_x']; 
                P_ref         = ['STATCOM' num2str(num) '.P_ref']; 
                omega_ref     = ['STATCOM' num2str(num) '.omega_ref']; 
                
                % Voltage droop
                udroop_x   = ['STATCOM' num2str(num) '.q_filt_x']; 
                Q_ref      = ['STATCOM' num2str(num) '.Q_ref']; 
                Umag_ref   = ['STATCOM' num2str(num) '.Umag_ref']; 
                
                % LC:
                is_q   = ['STATCOM' num2str(num) '.is_q']; 
                is_d   = ['STATCOM' num2str(num) '.is_d']; 
                ucap_q = ['STATCOM' num2str(num) '.ucap_q']; 
                ucap_d = ['STATCOM' num2str(num) '.ucap_d'];                 

                % Trafo
                ig_q    = ['STATCOM' num2str(num) '.ig_q'];
                ig_d    = ['STATCOM' num2str(num) '.ig_d'];
                
                % Power control:
                p_x = ['STATCOM' num2str(num) '.Ke_P'];  
                q_x = ['STATCOM' num2str(num) '.Ke_Q']; 
                
                % AC side current control
                is_q_x1   = ['STATCOM' num2str(num) '.Ke_is_q'];  
                is_q_x2   = ['STATCOM' num2str(num) '.Ke_is_d']; 
                is_qc_ref = ['STATCOM' num2str(num) '.is_qc_ref'];
                is_dc_ref = ['STATCOM' num2str(num) '.is_dc_ref']; 

                % Commutation delay
                cmd_qx1   = ['STATCOM' num2str(num) '.cmdq1'];  
                cmd_qx2   = ['STATCOM' num2str(num) '.cmdq2']; 
                cmd_dx1   = ['STATCOM' num2str(num) '.cmdd1'];  
                cmd_dx2   = ['STATCOM' num2str(num) '.cmdd2']; 

                % Measurement delay
                if T_VSC.tau_md(vsc)==0
                isq_md_x  =  [];
                uq_md_x   =  [];
                igq_md_x  =  [];
                isd_md_x  =  [];
                ud_md_x   =  [];
                igd_md_x  =  [];
                else
                isq_md_x  =  ['STATCOM' num2str(num) '.isq_md'];
                uq_md_x   =  ['STATCOM' num2str(num) '.uq_md'];
                igq_md_x  =  ['STATCOM' num2str(num) '.igq_md'];
                isd_md_x  =  ['STATCOM' num2str(num) '.isd_md'];
                ud_md_x   =  ['STATCOM' num2str(num) '.ud_md'];
                igd_md_x  =  ['STATCOM' num2str(num) '.igd_md'];
                end

                % Measurement ZOH
                if T_VSC.tau_zoh(vsc)==-1
                isq_zoh_x = [];
                uq_zoh_x = [];
                vdiffq_zoh_x = [];
                igq_zoh_x = [];
                isd_zoh_x = [];
                ud_zoh_x = [];
                igd_zoh_x = [];
                vdiffd_zoh_x = [];
                else
                isq_zoh_x1  =  ['STATCOM' num2str(num) '.isq_zoh1'];
                isq_zoh_x2  =  ['STATCOM' num2str(num) '.isq_zoh2'];
                isq_zoh_x = {isq_zoh_x1;isq_zoh_x2};
                uq_zoh_x1   =  ['STATCOM' num2str(num) '.uq_zoh1'];
                uq_zoh_x2   =  ['STATCOM' num2str(num) '.uq_zoh2'];
                uq_zoh_x = {uq_zoh_x1;uq_zoh_x2};
                vdiffq_zoh_x1   =  ['STATCOM' num2str(num) '.vdiffq_zoh1'];
                vdiffq_zoh_x2   =  ['STATCOM' num2str(num) '.vdiffq_zoh2'];
                vdiffq_zoh_x = {vdiffq_zoh_x1,vdiffq_zoh_x2};
                igq_zoh_x1  =  ['STATCOM' num2str(num) '.igq_zoh1'];
                igq_zoh_x2  =  ['STATCOM' num2str(num) '.igq_zoh2'];
                igq_zoh_x = {igq_zoh_x1;igq_zoh_x2};
                isd_zoh_x1  =  ['STATCOM' num2str(num) '.isd_zoh1'];
                isd_zoh_x2  =  ['STATCOM' num2str(num) '.isd_zoh2'];
                isd_zoh_x = {isd_zoh_x1;isd_zoh_x2};
                ud_zoh_x1   =  ['STATCOM' num2str(num) '.ud_zoh1'];
                ud_zoh_x2   =  ['STATCOM' num2str(num) '.ud_zoh2'];
                ud_zoh_x = {ud_zoh_x1;ud_zoh_x2};
                igd_zoh_x1  =  ['STATCOM' num2str(num) '.igd_zoh1'];
                igd_zoh_x2  =  ['STATCOM' num2str(num) '.igd_zoh2'];
                igd_zoh_x = {igd_zoh_x1;igd_zoh_x2};
                vdiffd_zoh_x1   =  ['STATCOM' num2str(num) '.vdiffd_zoh1'];
                vdiffd_zoh_x2   =  ['STATCOM' num2str(num) '.vdiffd_zoh2'];
                vdiffd_zoh_x = {vdiffd_zoh_x1;vdiffd_zoh_x2};
                end
                
                % omega to angle VSC (1/s)
                angle_vsc_x = ['STATCOM' num2str(num) '.angle_vsc_x']; 
                w_vsc       = ['STATCOM' num2str(num) '.w']; 
                
                % PLL
                pll_x       = ['STATCOM' num2str(num) '.pll_x']; 
                
                % omega to angle grid (1/s)
                etheta_x = ['STATCOM' num2str(num) '.etheta_x']; 
                
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
                %DC voltage loop
                Ceq = T_VSC.Ceq(vsc);
                kpVdc = T_VSC.kpVdc(vsc);
                kiVdc = T_VSC.kiVdc(vsc);
                %POD:
                POD = T_VSC.POD(vsc);
                T = T_VSC.T(vsc);
                TLPF = T_VSC.TLPF(vsc);
                T1 = T_VSC.T1(vsc);
                T2 = T_VSC.T2(vsc);
                % Measurement delay
                tau_md = T_VSC.tau_md(vsc);
                % Commutation delay
                tau_cmd = T_VSC.tau_cmd(vsc);
                % ZOH delay
                tau_zoh = T_VSC.tau_zoh(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                ig_qc0   = lp_VSC{vsc}.ig_qc0; 
                ig_dc0   = lp_VSC{vsc}.ig_dc0;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                is_qc0   = lp_VSC{vsc}.is_qc0; 
                is_dc0   = lp_VSC{vsc}.is_dc0;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                u_qc0    = lp_VSC{vsc}.u_qc0;
                u_dc0    = lp_VSC{vsc}.u_dc0;
                ucap_q0    = lp_VSC{vsc}.ucap_q0;
                ucap_d0    = lp_VSC{vsc}.ucap_d0;     
                vc_qc0  = lp_VSC{vsc}.vc_qc0; 
                vc_dc0  = lp_VSC{vsc}.vc_dc0; 
                w0      = lp_VSC{vsc}.w0; 
                e_theta0 = lp_VSC{vsc}.etheta0; 


                % ---------------------------------------------------------
                % State-Space Model STATCOM
                % ---------------------------------------------------------

                % Transforms 
                
                % REF INVERSE transform: vc_c to vc (local -> global)
                vc_l2g_x = {''};
                vc_l2g_u = {'vc_qc','vc_dc','e_theta'};
                vc_l2g_y = {'vc_q','vc_d'};
                vc_l2g   = build_local2global(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0,vc_qc0,vc_dc0);

                ss_list{end+1} = vc_l2g ;
                
                % REF transform: is to is_c (global -> local)
                is_g2l_x = {''};
                is_g2l_u = {is_q, is_d, 'e_theta'};
                is_g2l_y = {'is_qc_pre_md' 'is_dc_pre_md'};
                is_g2l   = build_global2local(is_g2l_x,is_g2l_u,is_g2l_y,e_theta0,is_q0,is_d0);

                ss_list{end+1} = is_g2l;

                %isq measurement delay
                isq_md_u = is_g2l_y{1};
                isq_md_y = {'is_qc_pre_zoh'};
                isq_measurement_delay = build_measurement_delay(isq_md_x,isq_md_u,isq_md_y,tau_md);

                ss_list{end+1} = isq_measurement_delay;

                %isd measurement delay
                isd_md_u = is_g2l_y{2};
                isd_md_y = {'is_dc_pre_zoh'};
                isd_measurement_delay = build_measurement_delay(isd_md_x,isd_md_u,isd_md_y,tau_md);

                ss_list{end+1} = isd_measurement_delay;

                %isq ZOH delay
                isq_zoh_u = isq_md_y;
                isq_zoh_y = {'is_qc'};
                isq_zoh_delay = build_zoh2_2order(isq_zoh_x,isq_zoh_u,isq_zoh_y,tau_zoh);

                ss_list{end+1} = isq_zoh_delay;

                %isd ZOH delay
                isd_zoh_u = isd_md_y;
                isd_zoh_y = {'is_dc'};
                isd_zoh_delay = build_zoh2_2order(isd_zoh_x,isd_zoh_u,isd_zoh_y,tau_zoh);

                ss_list{end+1} = isd_zoh_delay;

                % REF transform: ig to ig_c (global -> local)
                ig_g2l_x = {''};
                ig_g2l_u = {ig_q, ig_d, 'e_theta'};
                ig_g2l_y = {'ig_qc_pre_md' 'ig_dc_pre_md'};
                ig_g2l   = build_global2local(ig_g2l_x,ig_g2l_u,ig_g2l_y,e_theta0,ig_q0,ig_d0);

                ss_list{end+1} = ig_g2l;

                %igq measurement delay
                igq_md_u = ig_g2l_y{1};
                igq_md_y = {'ig_qc_pre_zoh'};
                igq_measurement_delay = build_measurement_delay(igq_md_x,igq_md_u,igq_md_y,tau_md);

                ss_list{end+1} = igq_measurement_delay;

                %igd measurement delay
                igd_md_u = ig_g2l_y{2};
                igd_md_y = {'ig_dc_pre_zoh'};
                igd_measurement_delay = build_measurement_delay(igd_md_x,igd_md_u,igd_md_y,tau_md);

                ss_list{end+1} = igd_measurement_delay;

                %igq ZOH delay
                igq_zoh_u = igq_md_y;
                igq_zoh_y = {'ig_qc'};
                igq_zoh_delay = build_zoh2_2order(igq_zoh_x,igq_zoh_u,igq_zoh_y,tau_zoh);

                ss_list{end+1} = igq_zoh_delay;

                %igd ZOH delay
                igd_zoh_u = igd_md_y;
                igd_zoh_y = {'ig_dc'};
                igd_zoh_delay = build_zoh2_2order(igd_zoh_x,igd_zoh_u,igd_zoh_y,tau_zoh);

                ss_list{end+1} = igd_zoh_delay;
                              
                % REF transform: u to u_c (global -> local)
                u_g2l_x = {''};
                u_g2l_u = {'u_q','u_d','e_theta'};
                u_g2l_y = {'u_qc_pre_md','u_dc_pre_md'};
                u_g2l   = build_global2local(u_g2l_x,u_g2l_u,u_g2l_y,e_theta0,u_q0,u_d0);

                ss_list{end+1} = u_g2l;

                %uq measurement delay
                uq_md_u = u_g2l_y{1};
                uq_md_y = {'u_qc_pre_zoh'};
                uq_measurement_delay = build_measurement_delay(uq_md_x,uq_md_u,uq_md_y,tau_md);
                ss_list{end+1} = uq_measurement_delay;

                %ud measurement delay
                ud_md_u = u_g2l_y{2};
                ud_md_y = {'u_dc_pre_zoh'};
                ud_measurement_delay = build_measurement_delay(ud_md_x,ud_md_u,ud_md_y,tau_md);
                ss_list{end+1} = ud_measurement_delay;

                %uq ZOH delay
                uq_zoh_u = uq_md_y;
                uq_zoh_y = {'u_qc'};
                uq_zoh_delay = build_zoh2_2order(uq_zoh_x,uq_zoh_u,uq_zoh_y,tau_zoh);
                ss_list{end+1} = uq_zoh_delay;

                %ud ZOH delay
                ud_zoh_u = ud_md_y;
                ud_zoh_y = {'u_dc'};
                ud_zoh_delay = build_zoh2_2order(ud_zoh_x,ud_zoh_u,ud_zoh_y,tau_zoh);
                ss_list{end+1} = ud_zoh_delay;

                % Change base of voltage: system -> vsc              
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};
                %vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,Vl2g);
                vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,1);

                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu -> System pu

                if T_VSC.Cac(vsc) % RLC filter
                    vsc_pu_x={''}; 
                    vsc_pu_u={ig_q,ig_d};
                    vsc_pu_y={iq, id};
                else % RL filter
                    % Change base of current: VSC pu -> System pu
                    vsc_pu_x={''}; 
                    vsc_pu_u={is_q,is_d};
                    vsc_pu_y={iq, id};
                end

                %vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Il2g);
                vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Sl2g);
                ss_list{end+1} = vsc_pu;
                                
                % PLL:
                pll_x={pll_x};
                %pll_u={'u_dc_pre_zoh'};
                pll_u={'u_dc'};
                %pll_u={'vc_d'};
                pll_y={'w_vsc_pu'};
                pll = build_pll(pll_x,pll_u,pll_y,kp_pll,ki_pll);

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
                dang_x={etheta_x};
                dang_u1={w_vsc,[REF_w num2str(syncarea)]};
                dang_u2={w_vsc};
                dang_y={'e_theta'};
                dang = build_angle_deviation(dang_x,dang_u1,dang_u2,dang_y,num,num_slk,element_slk,syncarea);

                ss_list{end+1} = dang;

                % % Frequency droop with low-pass filter on omega:
                % fdroop_x={fdroop_x};
                % fdroop_u={omega_ref,w_vsc};
                % fdroop_y={P_ref};
                % fdroop = build_frequency_droop(fdroop_x,fdroop_u,fdroop_y,k_droop_f,tau_droop_f,wb);
                % 
                % ss_list{end+1} = fdroop;
                
                % voltage magnitude
                x = {''};
                u = {'u_qc' 'u_dc'};
                y = {'Umag'};
                ss_u = build_voltage_magnitude(x,u,y,u_qc0,u_dc0);

                ss_list{end+1} = ss_u;
                
                % % Voltage droop with low-pass filter in v:
                % udroop_x = {udroop_x};
                % udroop_u = {Umag_ref,'Umag'};
                % udroop_y = {Q_ref};
                % udroop   = build_voltage_droop(udroop_x,udroop_u,udroop_y,k_droop_u,tau_droop_u);
                % 
                % ss_list{end+1} = udroop;

                % Outer control
                
                if T_VSC.Cac(vsc) % RLC filter
                    %POD
                    ss_Power = STATCOM_SS_Power({'u_qc' ;'ig_qc'; 'u_dc' ; 'ig_dc'},'Power_POD',u_qc0,ig_qc0,u_dc0,ig_dc0);
                    ss_list{end+1} = ss_Power;

                    if POD == "Yes"
                        % Voltage droop
                        voltage_droop = build_voltage_droop(udroop_x,{Umag_ref,'Umag'},'idiffd_Vref',k_droop_u,tau_droop_u);
                        ss_list{end+1} = voltage_droop;

                        ss_POD = STATCOM_POD(T,TLPF,T1,T2,'Power_POD','idiffd_PODref',num);
                        ss_list{end+1} = ss_POD;

                        ss_addidiffd = STATCOM_SS_ADD('idiffd_PODref','idiffd_Vref',is_dc_ref);
                        ss_list{end+1} = ss_addidiffd;
                    else
                        % Voltage droop
                        voltage_droop = build_voltage_droop(udroop_x,{Umag_ref,'Umag'},is_dc_ref,k_droop_u,tau_droop_u);
                        ss_list{end+1} = voltage_droop;
                    end

                    %DC voltage control
                    ss_idc = STATCOM_SS_DCPower(1, 3/2*u_qc0*ig_qc0+3/2*u_dc0*ig_dc0, num);
                    ss_list{end+1} = ss_idc;

                    ss_DC_electric_circuit = build_STAT_DC_electric_circuit(Ceq,num);
                    ss_list{end+1} = ss_DC_electric_circuit;

                    ss_DC_control = STATCOM_SS_DC_CONTROL(kpVdc, kiVdc, num,is_qc_ref);
                    ss_list{end+1} = ss_DC_control;

                    % % P control
                    % p_x={p_x};
                    % p_u={P_ref,'ig_qc','ig_dc','u_qc','u_dc'};
                    % p_y={is_qc_ref};
                    % ss_p = build_active_power_control(p_x,p_u,p_y,kp_P,ki_P,ig_qc0,ig_dc0,u_qc0,u_dc0);
                    % 
                    % ss_list{end+1} = ss_p;
                    
                    % % Q control
                    % q_x={q_x};
                    % q_u={Q_ref,'ig_qc','ig_dc','u_qc','u_dc'};
                    % q_y={is_dc_ref};
                    % ss_q = build_reactive_power_control(q_x,q_u,q_y,kp_Q,ki_Q,ig_qc0,ig_dc0,u_qc0,u_dc0);
                    % 
                    % ss_list{end+1} = ss_q;

                else % RL filter

                    % P control
                    p_x={p_x};
                    p_u={P_ref,'is_qc','is_dc','u_qc','u_dc'};
                    p_y={is_qc_ref};
                    ss_p = build_active_power_control(p_x,p_u,p_y,kp_P,ki_P,is_qc0,is_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_p;
                    
                    % Q control
                    q_x={q_x};
                    q_u={Q_ref,'is_qc','is_dc','u_qc','u_dc'};
                    q_y={is_dc_ref};
                    ss_q = build_reactive_power_control(q_x,q_u,q_y,kp_Q,ki_Q,is_qc0,is_dc0,u_qc0,u_dc0);
    
                    ss_list{end+1} = ss_q;

                end
                                
                % AC side current control
                is_x = {is_q_x1 is_q_x2};
                is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','u_qc','u_dc'};
                is_y = {'vc_qc_pre_zoh' 'vc_dc_pre_zoh'};
                is   =  build_ac_current_loop(is_x,is_u,is_y,kp_s,ki_s,Lc,wb);

                ss_list{end+1} =  is;

                % ZOH vdiffq delay
                zoh_vdiffq_u = is_y{1};
                zoh_vdiffq_y = {'vc_q_pre_cmd'};
                zoh_vdiff_q = build_zoh2_2order(vdiffq_zoh_x,zoh_vdiffq_u,zoh_vdiffq_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_q;

                % ZOH vdiffd delay
                zoh_vdiffd_u = is_y{2};
                zoh_vdiffd_y = {'vc_d_pre_cmd'};
                zoh_vdiff_d = build_zoh2_2order(vdiffd_zoh_x,zoh_vdiffd_u,zoh_vdiffd_y,tau_zoh);

                ss_list{end+1} =  zoh_vdiff_d;

                % Commutation delay q
                cmd_u = zoh_vdiffq_y;
                cmd_y = {'vc_qc'};
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_u = zoh_vdiffd_y;
                cmd_y = {'vc_dc'};
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,tau_cmd);

                ss_list{end+1} =  cmd_d;

                % RL/RLC filter and trafo
                if T_VSC.Cac(vsc) % RLC filter
                    % Transformer 
                    tr_x = {ig_q, ig_d};
                    tr_u = {'u_q','u_d','vg_q','vg_d'};
                    tr_y = {ig_q, ig_d};
                    tr_ss = build_transformer(tr_x,tr_u,tr_y,Rtr,Ltr,w0);
    
                    ss_list{end+1} = tr_ss;
    
                    % LC:
                    lc_x = {is_q is_d ucap_q ucap_d};
                    lc_u = {'vc_q','vc_d',ig_q,ig_d,[REF_w num2str(syncarea)]};
                    lc_y = {is_q is_d 'u_q' 'u_d'};
                    Lc_ss = build_lc_filter(lc_x,lc_u,lc_y,Rc,Rac,Lc,Cac,wb,is_q0,is_d0,ucap_q0,ucap_d0);
    
                    ss_list{end+1} = Lc_ss;                    

                else % RL filter

                    % plant: RL filter and trafo                
                    rl_x={is_q is_d};
                    rl_u={'vc_q','vc_d','vg_q','vg_d'};
                    rl_y={is_q is_d 'u_q' 'u_d'};
                    rl = build_rl_filter(rl_x,rl_u,rl_y,Rc,Lc,Rtr,Ltr,wb);
    
                    ss_list{end+1} = rl;

                end            

                % Build complete model
                input_vars = {'vg_sys_q','vg_sys_d',[REF_w num2str(syncarea)]}; 
                output_vars = {iq,id,w_vsc};                  
                SS_STATCOM = connect(ss_list{:},input_vars,output_vars); 

                %  adapt inputs/outputs
                SS_STATCOM.InputName(1) = {vnXq};
                SS_STATCOM.InputName(2) = {vnXd};

                % append ss to l_blocks
                l_blocks{end+1} = SS_STATCOM; 

            % -------------------------------------------------------------

            case 'WT'
            % -------------------------------------------------------------

                % ---------------------------------------------------------
                % Set names of state variables, inputs and outputs     
                % ---------------------------------------------------------

                num = T_VSC.number(vsc); 
                bus = T_VSC.bus(vsc);
                    
                % Frequency droop
                fdroop_x     = ['WT' num2str(num) '.w_filt_x']; 
                P_ref         = ['WT' num2str(num) '.P_ref']; 
                omega_ref     = ['WT' num2str(num) '.omega_ref']; 
                
                % Voltage droop
                udroop_x   = ['WT' num2str(num) '.q_filt_x']; 
                Q_ref      = ['WT' num2str(num) '.Q_ref']; 
                Umag_ref   = ['WT' num2str(num) '.Umag_ref']; 
                
                % LC:
                is_q   = ['WT' num2str(num) '.is_q']; 
                is_d   = ['WT' num2str(num) '.is_d']; 
                ucap_q = ['WT' num2str(num) '.ucap_q']; 
                ucap_d = ['WT' num2str(num) '.ucap_d'];                 

                % Trafo
                ig_q    = ['WT' num2str(num) '.ig_q'];
                ig_d    = ['WT' num2str(num) '.ig_d'];
                
                % Power control:
                p_x = ['WT' num2str(num) '.Ke_P'];  
                q_x = ['WT' num2str(num) '.Ke_Q']; 
                
                % AC side current control
                is_q_x1   = ['WT' num2str(num) '.Ke_is_q'];  
                is_q_x2   = ['WT' num2str(num) '.Ke_is_d']; 
                is_qc_ref = ['WT' num2str(num) '.is_qc_ref'];
                is_dc_ref = ['WT' num2str(num) '.is_dc_ref']; 

                % Commutation delay
                cmd_qx1   = ['WT' num2str(num) '.cmdq1'];  
                cmd_qx2   = ['WT' num2str(num) '.cmdq2']; 
                cmd_qx3   = ['WT' num2str(num) '.cmdq3']; 
                cmd_dx1   = ['WT' num2str(num) '.cmdd1'];  
                cmd_dx2   = ['WT' num2str(num) '.cmdd2']; 
                cmd_dx3   = ['WT' num2str(num) '.cmdd3'];

                % % Measurement delay
                % if T_VSC.tau_md(vsc)==0
                % isq_md_x  =  [];
                % uq_md_x   =  [];
                % igq_md_x  =  [];
                % isd_md_x  =  [];
                % ud_md_x   =  [];
                % igd_md_x  =  [];
                % else
                % isq_md_x  =  ['WT' num2str(num) '.isq_md'];
                % uq_md_x   =  ['WT' num2str(num) '.uq_md'];
                % vgq_md_x   =  ['WT' num2str(num) '.unetq_md'];
                % igq_md_x  =  ['WT' num2str(num) '.igq_md'];
                % isd_md_x  =  ['WT' num2str(num) '.isd_md'];
                % ud_md_x   =  ['WT' num2str(num) '.ud_md'];
                % vgd_md_x   =  ['WT' num2str(num) '.unetd_md'];
                % igd_md_x  =  ['WT' num2str(num) '.igd_md'];
                % end

                % Measurement ZOH
                if T_VSC.tau_zoh(vsc)==-1
                isq_zoh_x = [];
                uq_zoh_x = [];
                vdiffq_zoh_x = [];
                igq_zoh_x = [];
                isd_zoh_x = [];
                ud_zoh_x = [];
                igd_zoh_x = [];
                vdiffd_zoh_x = [];
                vgq_zoh_x = [];
                vgd_zoh_x =  [];
                else
                vgq_zoh_x1   =  ['WT' num2str(num) '.unetq_zoh1'];
                vgq_zoh_x2   =  ['WT' num2str(num) '.unetq_zoh2'];
                vgq_zoh_x3   =  ['WT' num2str(num) '.unetq_zoh3'];
                vgq_zoh_x = {vgq_zoh_x1;vgq_zoh_x2;vgq_zoh_x3};
                isq_zoh_x1  =  ['WT' num2str(num) '.isq_zoh1'];
                isq_zoh_x2  =  ['WT' num2str(num) '.isq_zoh2'];
                isq_zoh_x3  =  ['WT' num2str(num) '.isq_zoh3'];
                isq_zoh_x = {isq_zoh_x1;isq_zoh_x2;isq_zoh_x3};
                uq_zoh_x1   =  ['WT' num2str(num) '.uq_zoh1'];
                uq_zoh_x2   =  ['WT' num2str(num) '.uq_zoh2'];
                uq_zoh_x3   =  ['WT' num2str(num) '.uq_zoh3'];
                uq_zoh_x = {uq_zoh_x1;uq_zoh_x2;uq_zoh_x3};
                vdiffq_zoh_x1   =  ['WT' num2str(num) '.vdiffq_zoh1'];
                vdiffq_zoh_x2   =  ['WT' num2str(num) '.vdiffq_zoh2'];
                vdiffq_zoh_x3   =  ['WT' num2str(num) '.vdiffq_zoh3'];
                vdiffq_zoh_x = {vdiffq_zoh_x1,vdiffq_zoh_x2,vdiffq_zoh_x3};
                igq_zoh_x1  =  ['WT' num2str(num) '.igq_zoh1'];
                igq_zoh_x2  =  ['WT' num2str(num) '.igq_zoh2'];
                igq_zoh_x3  =  ['WT' num2str(num) '.igq_zoh3'];
                igq_zoh_x = {igq_zoh_x1;igq_zoh_x2;igq_zoh_x3};
                vgd_zoh_x1   =  ['WT' num2str(num) '.unetd_zoh1'];
                vgd_zoh_x2   =  ['WT' num2str(num) '.unetd_zoh2'];
                vgd_zoh_x3   =  ['WT' num2str(num) '.unetd_zoh3'];
                vgd_zoh_x = {vgd_zoh_x1;vgd_zoh_x2;vgd_zoh_x3};
                isd_zoh_x1  =  ['WT' num2str(num) '.isd_zoh1'];
                isd_zoh_x2  =  ['WT' num2str(num) '.isd_zoh2'];
                isd_zoh_x3  =  ['WT' num2str(num) '.isd_zoh3'];
                isd_zoh_x = {isd_zoh_x1;isd_zoh_x2;isd_zoh_x3};
                ud_zoh_x1   =  ['WT' num2str(num) '.ud_zoh1'];
                ud_zoh_x2   =  ['WT' num2str(num) '.ud_zoh2'];
                ud_zoh_x3   =  ['WT' num2str(num) '.ud_zoh3'];
                ud_zoh_x = {ud_zoh_x1;ud_zoh_x2;ud_zoh_x3};
                igd_zoh_x1  =  ['WT' num2str(num) '.igd_zoh1'];
                igd_zoh_x2  =  ['WT' num2str(num) '.igd_zoh2'];
                igd_zoh_x3  =  ['WT' num2str(num) '.igd_zoh3'];
                igd_zoh_x = {igd_zoh_x1;igd_zoh_x2;igd_zoh_x3};
                vdiffd_zoh_x1   =  ['WT' num2str(num) '.vdiffd_zoh1'];
                vdiffd_zoh_x2   =  ['WT' num2str(num) '.vdiffd_zoh2'];
                vdiffd_zoh_x3   =  ['WT' num2str(num) '.vdiffd_zoh3'];
                vdiffd_zoh_x = {vdiffd_zoh_x1;vdiffd_zoh_x2;vdiffd_zoh_x3};
                end
                
                % omega to angle VSC (1/s)
                angle_vsc_x = ['WT' num2str(num) '.angle_vsc_x']; 
                w_vsc       = ['WT' num2str(num) '.w']; 
                
                % PLL
                pll_x       = ['WT' num2str(num) '.pll_x']; 
                
                % omega to angle grid (1/s)
                etheta_x = ['WT' num2str(num) '.etheta_x']; 
                
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
                cc_damp = T_VSC.cc_damp(vsc);
                % PLL
                kp_pll = T_VSC.kp_pll(vsc);
                ki_pll = T_VSC.ki_pll(vsc);
                tau_pll = T_VSC.tau_pll(vsc);
                % Power loops
                kp_Q  = T_VSC.kp_Q(vsc);
                ki_Q  = T_VSC.ki_Q(vsc);
                tau_droop_u = T_VSC.tau_droop_u(vsc);
                k_droop_u   = T_VSC.k_droop_u(vsc);
                %DC voltage loop
                Ceq = T_VSC.Ceq(vsc);
                kpVdc = T_VSC.kpVdc(vsc);
                kiVdc = T_VSC.kiVdc(vsc);
                % Measurement delay
                fc = T_VSC.fc(vsc);
                % Commutation delay
                tau_cmd = T_VSC.tau_cmd(vsc);
                % ZOH delay
                tau_zoh = T_VSC.tau_zoh(vsc);

                % ---------------------------------------------------------
                % Linearization point
                % ---------------------------------------------------------
 
                ig_q0   = lp_VSC{vsc}.ig_q0; 
                ig_d0   = lp_VSC{vsc}.ig_d0;
                ig_qc0   = lp_VSC{vsc}.ig_qc0; 
                ig_dc0   = lp_VSC{vsc}.ig_dc0;
                ig_qc0_p   = lp_VSC{vsc}.ig_qc0_p; 
                ig_dc0_p   = lp_VSC{vsc}.ig_dc0_p;
                is_q0   = lp_VSC{vsc}.is_q0; 
                is_d0   = lp_VSC{vsc}.is_d0;
                is_qc0   = lp_VSC{vsc}.is_qc0; 
                is_dc0   = lp_VSC{vsc}.is_dc0;
                is_qc0_p   = lp_VSC{vsc}.is_qc0_p; 
                is_dc0_p   = lp_VSC{vsc}.is_dc0_p;
                u_q0    = lp_VSC{vsc}.u_q0;
                u_d0    = lp_VSC{vsc}.u_d0;
                u_qc0    = lp_VSC{vsc}.u_qc0;
                u_dc0    = lp_VSC{vsc}.u_dc0;
                u_qc0_p    = lp_VSC{vsc}.u_qc0_p;
                u_dc0_p    = lp_VSC{vsc}.u_dc0_p;
                ucap_q0    = lp_VSC{vsc}.ucap_q0;
                ucap_d0    = lp_VSC{vsc}.ucap_d0;     
                vc_qc0  = lp_VSC{vsc}.vc_qc0; 
                vc_dc0  = lp_VSC{vsc}.vc_dc0; 
                vc_qc0_p  = lp_VSC{vsc}.vc_qc0_p; 
                vc_dc0_p  = lp_VSC{vsc}.vc_dc0_p; 
                vc_qc0_m  = lp_VSC{vsc}.vc_qc0_m; 
                vc_dc0_m  = lp_VSC{vsc}.vc_dc0_m; 
                vc_q0  = lp_VSC{vsc}.vc_q0; 
                vc_d0  = lp_VSC{vsc}.vc_d0; 
                vg_q0  = lp_VSC{vsc}.vg_q0; 
                vg_d0  = lp_VSC{vsc}.vg_d0;
                vg_qc0  = lp_VSC{vsc}.vg_qc0; 
                vg_dc0  = lp_VSC{vsc}.vg_dc0;
                vg_qc0_p  = lp_VSC{vsc}.vg_qc0_p; 
                vg_dc0_p  = lp_VSC{vsc}.vg_dc0_p;
                w0      = lp_VSC{vsc}.w0; 
                e_theta0 = lp_VSC{vsc}.etheta0; 
                e_theta0_cmd = lp_VSC{vsc}.e_theta0_cmd;
                e_theta0_cmd_neg = lp_VSC{vsc}.e_theta0_cmd_neg;
                e_theta0_filt = lp_VSC{vsc}.e_theta0_filt;
                e_theta0_delay = lp_VSC{vsc}.e_theta0_delay;
                e_theta0_delay2 = lp_VSC{vsc}.e_theta0_delay2;
                e_theta0_delay2_neg = lp_VSC{vsc}.e_theta0_delay2_neg;
                Pdc0  = lp_VSC{vsc}.Pdc0;
                idc0  = lp_VSC{vsc}.idc0;


                % ---------------------------------------------------------
                % State-Space Model WT
                % ---------------------------------------------------------

                % Transforms 
                
                % REF INVERSE transform: vg to vg_c (global -> local)
                vg_g2l_x = {''};
                vg_g2l_u = {'vg_q','vg_d','e_theta'};
                vg_g2l_y = {'vg_qc_pre_md','vg_dc_pre_md'};
                vg_g2l   = build_global2local_peak(vg_g2l_x,vg_g2l_u,vg_g2l_y,e_theta0_cmd,vg_q0,vg_d0);

                ss_list{end+1} = vg_g2l ;

                % vg BTWF abc:
                %OJO 50hz!!!!
                u = {vg_g2l_y{1};vg_g2l_y{2};'e_theta'};
                y_vg_btwf = {'vg_qc_pre_zoh';'vg_dc_pre_zoh'};
                x_q = {['WT' num2str(num) '.vgq_btw1'];['WT' num2str(num) '.vgq_btw2']};
                x_d = {['WT' num2str(num) '.vgd_btw1'];['WT' num2str(num) '.vgd_btw2']};
                btw_filter = build_btw_filter_abc(fc,x_q,x_d,u,y_vg_btwf,vg_qc0_p,vg_dc0_p);
                ss_list{end+1} = btw_filter;

                % vg ZOH abc:
                x_q = vgq_zoh_x;
                x_d = vgd_zoh_x;
                u = [y_vg_btwf;'e_theta'];
                y = {'vg_qc_rms';'vg_dc_rms'};
                zoh_delay = build_zoh_abc_3order(x_q,x_d,u,y,tau_zoh,vg_qc0_p,vg_dc0_p);

                ss_list{end+1} = zoh_delay;

                % change to peak value:
                x = {''};
                u = {'vg_qc_rms';'vg_dc_rms'};
                y = {'vg_qc';'vg_dc'};
                base_change = build_change_to_peak(x,u,y);

                ss_list{end+1} = base_change;

                % REF transform: is to is_c (global -> local)
                is_g2l_x = {''};
                is_g2l_u = {is_q, is_d, 'e_theta'};
                is_g2l_y = {'is_qc_pre_md' 'is_dc_pre_md'};
                is_g2l   = build_global2local_peak(is_g2l_x,is_g2l_u,is_g2l_y,e_theta0_cmd,is_q0,is_d0);

                ss_list{end+1} = is_g2l;

                % is BTWF abc:
                u = {is_g2l_y{1};is_g2l_y{2}; 'e_theta'};
                y_is_btwf = {'is_qc_pre_zoh';'is_dc_pre_zoh'};
                x_q = {['WT' num2str(num) '.isq_btw1'];['WT' num2str(num) '.isq_btw2']};
                x_d = {['WT' num2str(num) '.isd_btw1'];['WT' num2str(num) '.isd_btw2']};
                btw_filter = build_btw_filter_abc(fc,x_q,x_d,u,y_is_btwf,is_q0,is_d0);
                ss_list{end+1} = btw_filter;

                % is ZOH abc:
                x_q = isq_zoh_x;
                x_d = isd_zoh_x;
                u = [y_is_btwf;'e_theta'];
                y = {'is_qc_rms';'is_dc_rms'};
                zoh_delay = build_zoh_abc_3order(x_q,x_d,u,y,tau_zoh,is_qc0_p,is_dc0_p);

                ss_list{end+1} = zoh_delay;

                % change to peak value:
                x = {''};
                u = {'is_qc_rms';'is_dc_rms'};
                y = {'is_qc';'is_dc'};
                base_change = build_change_to_peak(x,u,y);

                ss_list{end+1} = base_change;

                % REF transform: ig to ig_c (global -> local)
                ig_g2l_x = {''};
                ig_g2l_u = {ig_q, ig_d, 'e_theta'};
                ig_g2l_y = {'ig_qc_pre_md' 'ig_dc_pre_md'};
                ig_g2l   = build_global2local_peak(ig_g2l_x,ig_g2l_u,ig_g2l_y,e_theta0_cmd,ig_q0,ig_d0);

                ss_list{end+1} = ig_g2l;

                % ig BTWF abc:
                u = {ig_g2l_y{1};ig_g2l_y{2};'e_theta'};
                y_ig_btwf = {'ig_qc_pre_zoh';'is_gc_pre_zoh'};
                x_q = {['WT' num2str(num) '.igq_btw1'];['WT' num2str(num) '.igq_btw2']};
                x_d = {['WT' num2str(num) '.igd_btw1'];['WT' num2str(num) '.igd_btw2']};
                btw_filter = build_btw_filter_abc(fc,x_q,x_d,u,y_ig_btwf,ig_qc0_p,ig_dc0_p);
                ss_list{end+1} = btw_filter;

                % ig ZOH abc:
                x_q = igq_zoh_x;
                x_d = igd_zoh_x;
                u = [y_ig_btwf;'e_theta'];
                y = {'ig_qc_rms';'ig_dc_rms'};
                zoh_delay = build_zoh_abc_3order(x_q,x_d,u,y,tau_zoh,ig_qc0_p,ig_dc0_p);

                ss_list{end+1} = zoh_delay;

                % change to peak value:
                x = {''};
                u = {'ig_qc_rms';'ig_dc_rms'};
                y = {'ig_qc';'ig_dc'};
                base_change = build_change_to_peak(x,u,y);

                ss_list{end+1} = base_change;
                              
                % REF transform: u to u_c (global -> local)
                u_g2l_x = {''};
                u_g2l_u = {'u_q','u_d','e_theta'};
                u_g2l_y = {'u_qc_pre_md','u_dc_pre_md'};
                u_g2l   = build_global2local_peak(u_g2l_x,u_g2l_u,u_g2l_y,e_theta0_cmd,u_q0,u_d0);

                ss_list{end+1} = u_g2l;

                % u BTWF abc:
                u = {u_g2l_y{1};u_g2l_y{2};'e_theta'};
                y_u_btwf = {'u_qc_pre_zoh';'u_dc_pre_zoh'};
                x_q = {['WT' num2str(num) '.uq_btw1'];['WT' num2str(num) '.uq_btw2']};
                x_d = {['WT' num2str(num) '.ud_btw1'];['WT' num2str(num) '.ud_btw2']};
                btw_filter = build_btw_filter_abc(fc,x_q,x_d,u,y_u_btwf,u_qc0_p,u_dc0_p);
                ss_list{end+1} = btw_filter;

                % u ZOH abc:
                x_q = uq_zoh_x;
                x_d = ud_zoh_x;
                u = [y_u_btwf;'e_theta'];
                y = {'u_qc_rms';'u_dc_rms'};
                zoh_delay = build_zoh_abc_3order(x_q,x_d,u,y,tau_zoh,u_qc0_p,u_dc0_p);

                ss_list{end+1} = zoh_delay;

                % change to peak value:
                x = {''};
                u = {'u_qc_rms';'u_dc_rms'};
                y = {'u_qc';'u_dc'};
                base_change = build_change_to_peak(x,u,y);

                ss_list{end+1} = base_change;

                % Change base of voltage: system -> vsc              
                vvsc_pu_x={''};
                vvsc_pu_u={'vg_sys_q','vg_sys_d'};
                vvsc_pu_y={'vg_q','vg_d'};
                %vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,Vl2g);
                vvsc_pu = build_base_change(vvsc_pu_x,vvsc_pu_u,vvsc_pu_y,1);

                ss_list{end+1} = vvsc_pu;

                % Change base of current: VSC pu--> System PU
                vsc_pu_x={''}; 
                vsc_pu_u={ig_q,ig_d};
                vsc_pu_y={iq, id};
                %vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Il2g);
                vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,(1/Sl2g));
                ss_list{end+1} = vsc_pu;
                      
                % Filtre PLL
                x = {['WT',num2str(num),'.pll_filter']};
                u = {'u_dc'};
                y = {'u_dc_pll_filt'};
                pll_mesurement_filter = build_measurement_delay(x,u,y,tau_pll);
                ss_list{end+1} = pll_mesurement_filter;
                
                % PLL:
                pll_x={pll_x};
                %pll_u={'u_dc_pre_zoh'};
                pll_u={'u_dc_pll_filt'};
                %pll_u={'vc_d'};
                pll_y={'w_vsc_pu'};
                pll = build_pll(pll_x,pll_u,pll_y,kp_pll,ki_pll);

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
                dang_x={etheta_x};
                dang_u1={w_vsc,[REF_w num2str(syncarea)]};
                dang_u2={w_vsc};
                dang_y={'e_theta'};
                dang = build_angle_deviation(dang_x,dang_u1,dang_u2,dang_y,num,num_slk,element_slk,syncarea);

                ss_list{end+1} = dang;
                
                % voltage magnitude
                x = {''};
                u = {'vg_qc' 'vg_dc'};
                y = {'Umag'};
                ss_u = build_voltage_magnitude(x,u,y,vg_qc0_p,vg_dc0_p);

                ss_list{end+1} = ss_u;
                
                % Outer control
                
                % Voltage droop
                y = {['WT',num2str(num),'.Aq']};
                voltage_droop = build_voltage_droop(udroop_x,{Umag_ref,'Umag'},y,k_droop_u,tau_droop_u);
                ss_list{end+1} = voltage_droop;

                %Q calculation
                q_x_calc={''};
                q_u={'ig_qc','ig_dc','vg_qc','vg_dc'};
                q_y={['WT',num2str(num),'.q']};
                ss_q = build_reactive_power_calculation_peak(q_x_calc,q_u,q_y,ig_qc0_p,ig_dc0_p,vg_qc0_p,vg_dc0_p);

                ss_list{end+1} = ss_q;

                % Q measurment delay
                x = {['WT',num2str(num),'.q_filter']};
                u = {['WT',num2str(num),'.q']};
                y = {['WT',num2str(num),'.q_filt']};
                q_mesurement_filter = build_measurement_delay(x,u,y,tau_droop_u);
                ss_list{end+1} = q_mesurement_filter;

                % Q control
                x=q_x;
                q_u={['WT',num2str(num),'.Aq'],['WT',num2str(num),'.q_filt']};
                q_y={is_dc_ref};
                ss_q = build_WT_reactive_power_control(x,q_u,q_y,kp_Q,ki_Q);
                ss_list{end+1} = ss_q;

                % DC voltage control
                % Change base of current: VSC pu--> System PU
                vsc_pu_x={''}; 
                vsc_pu_u={is_q,is_d};
                vsc_pu_y={'is_q_dc', 'is_d_dc'};
                %vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,1/Il2g);
                vsc_pu = build_base_change(vsc_pu_x,vsc_pu_u,vsc_pu_y,(1/Sl2g));
                ss_list{end+1} = vsc_pu;

                % Ptodc calculation
                p_x={''};
                p_u={'is_q_dc','is_d_dc','vc_q','vc_d'};
                p_y={['WT',num2str(num),'.p']};
                ss_p = build_active_power_todc_calculation(p_x,p_u,p_y,is_q0*Sl2g,is_d0*Sl2g,vc_q0,vc_d0);
                ss_list{end+1} = ss_p;

                % Pdctodc calculation
                % p_x={''};
                % p_u={['WT',num2str(num),'.vdc'],['WT',num2str(num),'.idc']};
                % p_y={['WT',num2str(num),'.pdc']};
                % ss_p = build_dc_power_todc_calculation(p_x,p_u,p_y,2,idc0*Sl2g);
                % ss_list{end+1} = ss_p;

                % idc calculation
                ss_idc = WT_SS_DCPower(2*sqrt(3/2), (3/2*vc_q0*is_q0+3/2*vc_d0*is_d0)*Sl2g,Pdc0*Sl2g, num);
                %ss_idc = WT_SS_DCPower(2, (3/2*vc_q0*is_q0+3/2*vc_d0*is_d0)*Sl2g,Pdc0*Sl2g, num);
                
                ss_list{end+1} = ss_idc;

                % DC capacitor
                ss_DC_electric_circuit = build_WT_DC_electric_circuit(Ceq,num);
                ss_list{end+1} = ss_DC_electric_circuit;

                % Filter vdc
                u = {join(['WT',num2str(num),'.vdc'])};
                y_vdc_btwf = {'vdc_pre_zoh'};
                x = {['WT' num2str(num) '.vdc_btw1'];['WT' num2str(num) '.vdc_btw2']};
                btw_filter = build_btw_filter_dc(fc,x,u,y_vdc_btwf);
                ss_list{end+1} = btw_filter;

                % zoh vdc       
                x = {['WT' num2str(num) '.vdc_zoh1'];['WT' num2str(num) '.vdc_zoh2']};
                u = y_vdc_btwf;
                y = {join(['WT',num2str(num),'.vdc_filt'])};
                zoh_delay = build_zoh_abc_2order_dc(x,u,y,tau_zoh);
                ss_list{end+1} = zoh_delay;

                ss_DC_control = WT_SS_DC_CONTROL(kpVdc, kiVdc, num,is_qc_ref);
                ss_list{end+1} = ss_DC_control;             
                                                                   
                % AC side current control
                is_x = {is_q_x1 is_q_x2};
                %is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','u_qc','u_dc'};
                is_u = {is_qc_ref,is_dc_ref,'is_qc','is_dc','vg_qc','vg_dc','ig_qc','ig_dc'};
                is_y = {'vc_qc_pre_zoh' 'vc_dc_pre_zoh'};
                %is   =  build_ac_current_loop(is_x,is_u,is_y,kp_s,ki_s,Lc,wb);
                is   =  build_ac_current_loop_cigre(is_x,is_u,is_y,kp_s,ki_s,cc_damp,Rc,Lc,wb);

                ss_list{end+1} =  is;
                
                % Modulation
                x = {''};
                u = {is_y{1};is_y{2};join(['WT',num2str(num),'.vdc_filt'])};
                y = {'vc_qc_m';'vc_dc_m'};
                modulation = build_modulation(x,u,y,2,vc_qc0_m,vc_dc0_m);

                ss_list{end+1} = modulation;  

                % REF INVERSE transform: vc_c to vc (local -> global)
                vc_l2g_x = {''};
                %vc_l2g_u = {'vc_qc','vc_dc','e_theta'};
                vc_l2g_u = {'vc_qc_m';'vc_dc_m';'e_theta'};
                %vc_l2g_y = {'vc_q','vc_d'};
                vc_l2g_y =  {'vc_qc','vc_dc'};
                %vc_l2g   =
                %build_local2global_peak(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0,vc_qc0,vc_dc0);
                %Aquesta anava bé (la de sobre)
                %vc_l2g   = build_local2global_peak(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0_delay2,vc_qc0_m*sqrt(2/3),vc_dc0_m*sqrt(2/3));
                %vc_l2g   = build_local2global_peak(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0_delay2,vc_qc0_m,vc_dc0_m);
                vc_l2g   = build_local2global_peak(vc_l2g_x,vc_l2g_u,vc_l2g_y,e_theta0_cmd,vc_qc0_m*sqrt(2/3),vc_dc0_m*sqrt(2/3));
                ss_list{end+1} = vc_l2g ;

                % Commutation delay abc
                x_q = {cmd_qx1;cmd_qx2;cmd_qx3};
                x_d = {cmd_dx1;cmd_dx2;cmd_dx3};
                %u = {'vc_qc_m';'vc_dc_m';'e_theta'};
                u = {'vc_qc','vc_dc','e_theta'};
                %y = {'vc_qc','vc_dc'};
                y = {'vc_q','vc_d'};
                com_delay = build_com_delay_3order_abc(x_q,x_d,u,y,tau_cmd,vc_qc0_m,vc_dc0_m);

                ss_list{end+1} = com_delay;

                % RL/RLC filter and trafo
                if T_VSC.Cac(vsc) % RLC filter
                    % Transformer 
                    tr_x = {ig_q, ig_d};
                    tr_u = {'u_q','u_d','vg_q','vg_d'};
                    tr_y = {ig_q, ig_d};
                    tr_ss = build_transformer(tr_x,tr_u,tr_y,Rtr,Ltr,w0);
    
                    ss_list{end+1} = tr_ss;
    
                    % LC:
                    lc_x = {is_q is_d ucap_q ucap_d};
                    lc_u = {'vc_q','vc_d',ig_q,ig_d,[REF_w num2str(syncarea)]};
                    lc_y = {is_q is_d 'u_q' 'u_d'};
                    Lc_ss = build_lc_filter(lc_x,lc_u,lc_y,Rc,Rac,Lc,Cac,wb,is_q0,is_d0,ucap_q0,ucap_d0);
    
                    ss_list{end+1} = Lc_ss;                    

                else % RL filter

                    % plant: RL filter and trafo                
                    rl_x={is_q is_d};
                    rl_u={'vc_q','vc_d','vg_q','vg_d'};
                    rl_y={is_q is_d 'u_q' 'u_d'};
                    rl = build_rl_filter(rl_x,rl_u,rl_y,Rc,Lc,Rtr,Ltr,wb);
    
                    ss_list{end+1} = rl;

                end            

                % Build complete model
                input_vars = {'vg_sys_q','vg_sys_d',[REF_w num2str(syncarea)]}; 

                %P calculation
                p_x_calc={''};
                p_u={iq,id,'vg_sys_q','vg_sys_d'};
                p_y={['WT',num2str(num),'.pout']};
                ss_p = build_active_power_calculation(p_x_calc,p_u,p_y,ig_q0,ig_d0,vg_q0,vg_d0);

                ss_list{end+1} = ss_p;

                %Q calculation
                p_x_calc={''};
                p_u={iq,id,'vg_sys_q','vg_sys_d'};
                p_y={['WT',num2str(num),'.qout']};
                ss_q = build_reactive_power_calculation(p_x_calc,p_u,p_y,ig_q0,ig_d0,vg_q0,vg_d0);

                ss_list{end+1} = ss_q;

                %output_vars = {iq,id,w_vsc};%,['WT',num2str(num),'.qout'],['WT',num2str(num),'.pout']};                  
                output_vars = {iq,id,w_vsc,['WT',num2str(num),'.qout'],['WT',num2str(num),'.pout']};                  

                SS_WT = connect(ss_list{:},input_vars,output_vars); 

                %  adapt inputs/outputs
                SS_WT.InputName(1) = {vnXq};
                SS_WT.InputName(2) = {vnXd};

                % append ss to l_blocks
                l_blocks{end+1} = SS_WT; 

            % -------------------------------------------------------------
        end



    end
end