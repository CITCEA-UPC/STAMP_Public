function l_blocks = generate_IPC_pu_with_functions(l_blocks,T_IPC_complete, lp_IPC, T_global, num_slk, element_slk, REF_w)
    for ipc = 1:1:size(T_IPC_complete.bus,1)
        ss_list = {};  
        mode = T_IPC_complete.mode{ipc};

        lp = lp_IPC{ipc};
        T_IPC = T_IPC_complete(ipc,:);
        switch mode
            case 'AC-GFOL_DC-GFOL'
                % Case AC GFOL DC GFOL
                %% Outer Loops:
                Pac_control = build_Pac_control(T_IPC.kpPac, T_IPC.kiPac, lp.idiffq0_c,lp.idiffd0_c,lp.vnq0_c,lp.vnd0_c,T_IPC.number,T_IPC.bus);
                ss_list{end+1} = Pac_control;
                Q_control = build_Q_control(T_IPC.kpQ, T_IPC.kiQ, lp.idiffq0_c,lp.idiffd0_c,lp.vnq0_c,lp.vnd0_c,T_IPC.number,T_IPC.bus);
                ss_list{end+1} = Q_control;
                %% Energy Loop:
                energy_control = build_energy_control_FF(T_IPC.kpEt, T_IPC.kiEt, lp.idiffq0_c, lp.vnq0_c, lp.idiffd0_c, lp.vnd0_c, T_IPC.number,T_IPC.bus, T_IPC.Vdc);
                ss_list{end+1} = energy_control;
                %% Inner Loops
                is_current_control = build_is_current_control( T_IPC.kpIs, T_IPC.kiIs, T_IPC.Lc,T_IPC.La ,T_IPC.fb, T_IPC.number,T_IPC.bus);
                ss_list{end+1} = is_current_control;
                isum_current_control = build_isum_current_control(T_IPC.kpIsum, T_IPC.kiIsum, T_IPC.number);
                ss_list{end+1} = isum_current_control;
                %% PLL:
                PLL = build_PLL(T_IPC.kpPLL, T_IPC.kiPLL, T_IPC.number, T_IPC.bus,[REF_w num2str(T_IPC.SyncArea)]);   
                ss_list{end+1} = PLL;
                %% MMC electric system:
                MMC_electric_circuit = build_MMC_electric_circuit(T_IPC.number,T_IPC.bus,T_IPC.busdc,T_IPC.Rc,T_IPC.Ra,T_IPC.Lc,T_IPC.La,T_IPC.fb);
                ss_list{end+1} = MMC_electric_circuit;
                %Total Energy:
                total_energy = build_total_energy(lp.idiffq0,lp.idiffd0,lp.vdiffq0,lp.vdiffd0,lp.isum0,lp.vsum0, T_IPC.number);
                ss_list{end+1} = total_energy;

                %% Change pu base from local to system:
                change_pu = build_change_pu(T_IPC.Sbpu_l2g,T_IPC.number);
                ss_list{end+1} = change_pu;
                %% Rotation matrix for all the input/output signals:
                %From global to local:
                %idiff:
                u = {  join(['IPC',num2str(T_IPC.number),'.idiffq']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.angle']) };
                y = {  join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd_predelay'])};
                global_to_local_idiff = build_global_to_local(lp.etheta0, lp.idiffq0, lp.idiffd0 , u , y);
                ss_list{end+1} = global_to_local_idiff;
                %vn:
                u = { join(['NET','.vn',num2str(T_IPC.bus),'q']) ;... 
                      join(['NET','.vn',num2str(T_IPC.bus),'d']) ;...
                      join(['IPC',num2str(T_IPC.number),'.angle'] )};
                y = { join(['IPC',num2str(T_IPC.number),'.vq_predelay']) ;... 
                      join(['IPC',num2str(T_IPC.number),'.vd_predelay']) };
                global_to_local_vn = build_global_to_local(lp.etheta0, lp.vnq0, lp.vnd0 , u , y);
                ss_list{end+1} = global_to_local_vn;
                %From local to global:
                %vdiff
                u = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_c',num2str(T_IPC.number)] ); ...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_c',num2str(T_IPC.number)] ); ...
                      join(['IPC',num2str(T_IPC.number),'.angle'])                           };
                y = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] ) ;...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] )};...
                local_to_global_vdiff = build_local_to_global(lp.etheta0, lp.vdiffq0_c, lp.vdiffd0_c, u , y);
                ss_list{end+1} = local_to_global_vdiff;

                %% Commutation delays
                % Commutation delay q
                cmd_qx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_q1'] ); 
                cmd_qx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_q2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_q'] );
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_dx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_d1'] ); 
                cmd_dx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_d2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_d'] );
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_d;

                % Commutation delay vsum0
                cmd_x1 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum1'] ); 
                cmd_x2 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vsum0_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vsum0'] );
                cmd_vsum = build_com_delay_2order({cmd_x1;cmd_x2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_vsum;
                
                %% All signal delays:
                %Uq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vq_zoh2'])};
                uq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = uq_zoh_delay;
                %Uq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'q_c',num2str(T_IPC.number)]);
                uq_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = uq_delay;
                
                %Ud ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vd_zoh2'])};
                ud_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = ud_zoh_delay;
                %Ud
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'d_c',num2str(T_IPC.number)]);
                ud_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = ud_delay;

                %idiffq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffq_zoh2'])};
                idiffq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffq_zoh_delay;
                %idiffq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffq_c',num2str(T_IPC.number)]);
                idiffq_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffq_delay;

                %idiffd ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffd_zoh2'])};
                idiffd_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffd_zoh_delay;
                %idiffd
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffd_c',num2str(T_IPC.number)]);
                idiffd_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffd_delay;

                %Et ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.Et_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.Et_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.Et_zoh2'])};
                Et_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = Et_zoh_delay;
                %Et
                delay_x = join(['IPC',num2str(T_IPC.number),'delay_Et']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.Et']);
                Et_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = Et_delay;

                %vDC ZOH delay
                u_zoh = join(['DC_NET.v',num2str(T_IPC.busdc),'DC']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vDC_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vDC_zoh2'])};
                vDC_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = vDC_zoh_delay;
                %vDC
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vDC']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vDC_delay']);
                vdc_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = vdc_delay;

                %isum0 ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.isum0']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.isum0_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.isum0_zoh2'])};
                isum_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = isum_zoh_delay;
                %isum0
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_isum0']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.isum0_delay']);
                isum0_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = isum0_delay;
                %%
                % Build complete model
                input_vars = {join(['NET','.vn',num2str(T_IPC.bus),'q']),...                         
                              join(['NET','.vn',num2str(T_IPC.bus),'d']),...
                              [REF_w num2str(T_IPC.SyncArea)],...
                              join(['DC_NET.v',num2str(T_IPC.busdc),'DC'])};
                output_vars = {join(['IPC',num2str(T_IPC.number),'.idiffq']);... 
                               join(['IPC',num2str(T_IPC.number),'.idiffd']);... 
                               join(['IPC',num2str(T_IPC.number),'.w']);...
                               join(['IPC',num2str(T_IPC.number),'.iDC'])  };                  
                SS_IPC = connect(ss_list{:},input_vars,output_vars); 

                % append ss to l_blocks
                l_blocks{end+1} = SS_IPC;

            case 'AC-GFOL_DC-GFOR'
                % Case AC GFOL DC GFOR
                %% Outer Loops:
                vdc_control = build_vdc_control2(T_IPC.kpVdc,T_IPC.kpPac, T_IPC.kiPac, lp.vnq0_c,lp.idiffq0_c,lp.vnd0_c,lp.idiffd0_c,T_IPC.number,T_IPC.bus);
                %vdc_control = build_vdc_control3(T_IPC.kpVdc, T_IPC.kiVdc, T_IPC.number);
                ss_list{end+1} = vdc_control;
                Q_control = build_Q_control(T_IPC.kpQ, T_IPC.kiQ, lp.idiffq0_c,lp.idiffd0_c,lp.vnq0_c,lp.vnd0_c,T_IPC.number,T_IPC.bus);
                ss_list{end+1} = Q_control;
                %% Energy Loop:
                energy_control = build_energy_control_FF(T_IPC.kpEt, T_IPC.kiEt, lp.idiffq0_c, lp.vnq0_c, lp.idiffd0_c, lp.vnd0_c, T_IPC.number,T_IPC.bus, T_IPC.Vdc);
                ss_list{end+1} = energy_control;
                %% Inner Loops
                is_current_control = build_is_current_control( T_IPC.kpIs, T_IPC.kiIs, T_IPC.Lc,T_IPC.La ,T_IPC.fb, T_IPC.number,T_IPC.bus);
                ss_list{end+1} = is_current_control;
                isum_current_control = build_isum_current_control(T_IPC.kpIsum, T_IPC.kiIsum, T_IPC.number);
                ss_list{end+1} = isum_current_control;
                %% PLL:                
                PLL = build_PLL(T_IPC.kpPLL, T_IPC.kiPLL, T_IPC.number, T_IPC.bus,[REF_w num2str(T_IPC.SyncArea)]);   
                ss_list{end+1} = PLL;
                %% MMC electric system:
                MMC_electric_circuit = build_MMC_electric_circuit(T_IPC.number,T_IPC.bus,T_IPC.busdc,T_IPC.Rc,T_IPC.Ra,T_IPC.Lc,T_IPC.La,T_IPC.fb);
                ss_list{end+1} = MMC_electric_circuit;
                %Total Energy:
                total_energy = build_total_energy(lp.idiffq0,lp.idiffd0,lp.vdiffq0,lp.vdiffd0,lp.isum0,lp.vsum0, T_IPC.number);
                ss_list{end+1} = total_energy;

                %% Change pu base from local to system:
                change_pu = build_change_pu(T_IPC.Sbpu_l2g,T_IPC.number);
                ss_list{end+1} = change_pu;

                %% Rotation matrix for all the input/output signals:
                %From global to local:
                %idiff:
                u = {  join(['IPC',num2str(T_IPC.number),'.idiffq']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.angle']) };
                y = {  join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd_predelay'])};
                global_to_local_idiff = build_global_to_local(lp.etheta0, lp.idiffq0, lp.idiffd0 , u , y);
                ss_list{end+1} = global_to_local_idiff;
                %vn:
                u = { join(['NET','.vn',num2str(T_IPC.bus),'q']) ;... 
                      join(['NET','.vn',num2str(T_IPC.bus),'d']) ;...
                      join(['IPC',num2str(T_IPC.number),'.angle'] )};
                y = { join(['IPC',num2str(T_IPC.number),'.vq_predelay']) ;... 
                      join(['IPC',num2str(T_IPC.number),'.vd_predelay']) };
                global_to_local_vn = build_global_to_local(lp.etheta0, lp.vnq0, lp.vnd0 , u , y);
                ss_list{end+1} = global_to_local_vn;
                %From local to global:
                %vdiff
                u = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_c',num2str(T_IPC.number)] ); ...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_c',num2str(T_IPC.number)] ); ...
                      join(['IPC',num2str(T_IPC.number),'.angle'])                           };
                y = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] ) ;...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] )};...
                local_to_global_vdiff = build_local_to_global(lp.etheta0, lp.vdiffq0_c, lp.vdiffd0_c, u , y);
                ss_list{end+1} = local_to_global_vdiff;

                %% Commutation delays
                % Commutation delay q
                cmd_qx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_q1'] ); 
                cmd_qx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_q2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_q'] );
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_dx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_d1'] ); 
                cmd_dx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_d2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_d'] );
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_d;

                % Commutation delay vsum0
                cmd_x1 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum1'] ); 
                cmd_x2 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vsum0_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vsum0'] );
                cmd_vsum = build_com_delay_2order({cmd_x1;cmd_x2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_vsum;
                %% All signal delays:
                %Uq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vq_zoh2'])};
                uq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = uq_zoh_delay;
                %Uq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'q_c',num2str(T_IPC.number)]);
                uq_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = uq_delay;
                
                %Ud ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vd_zoh2'])};
                ud_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = ud_zoh_delay;
                %Ud
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'d_c',num2str(T_IPC.number)]);
                ud_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = ud_delay;

                %idiffq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffq_zoh2'])};
                idiffq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffq_zoh_delay;
                %idiffq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffq_c',num2str(T_IPC.number)]);
                idiffq_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffq_delay;

                %idiffd ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffd_zoh2'])};
                idiffd_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffd_zoh_delay;
                %idiffd
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffd_c',num2str(T_IPC.number)]);
                idiffd_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffd_delay;

                %Et ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.Et_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.Et_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.Et_zoh2'])};
                Et_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = Et_zoh_delay;
                %Et
                delay_x = join(['IPC',num2str(T_IPC.number),'delay_Et']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.Et']);
                Et_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = Et_delay;

                %vDC ZOH delay
                u_zoh = join(['DC_NET.v',num2str(T_IPC.busdc),'DC']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vDC_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vDC_zoh2'])};
                vDC_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = vDC_zoh_delay;
                %vDC
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vDC']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vDC_delay']);
                vdc_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = vdc_delay;

                %isum0 ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.isum0']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.isum0_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.isum0_zoh2'])};
                isum_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = isum_zoh_delay;
                %isum0
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_isum0']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.isum0_delay']);
                isum0_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = isum0_delay;

                % Build complete model
                input_vars = {join(['NET','.vn',num2str(T_IPC.bus),'q']),...                         
                              join(['NET','.vn',num2str(T_IPC.bus),'d']),...
                              [REF_w num2str(T_IPC.SyncArea)],...
                              join(['DC_NET.v',num2str(T_IPC.busdc),'DC'])}; 
                output_vars = {join(['IPC',num2str(T_IPC.number),'.idiffq']);... 
                               join(['IPC',num2str(T_IPC.number),'.idiffd']);... 
                               join(['IPC',num2str(T_IPC.number),'.w']);... 
                               join(['IPC',num2str(T_IPC.number),'.iDC'])  };                  
                SS_IPC = connect(ss_list{:},input_vars,output_vars); 

                % append ss to l_blocks
                l_blocks{end+1} = SS_IPC;

            case 'AC-GFOR_DC-GFOL'
                % Case AC GFOL DC GFOL
                %% Outer Loops:
                AC_voltage_control = build_AC_voltage_control( T_IPC.kpVac, T_IPC.kiVac , T_IPC.fb , T_IPC.Cac , T_IPC.bus ,T_IPC.number);
                ss_list{end+1} = AC_voltage_control;
                %% Energy Loop:
                energy_control = build_energy_control_FF(T_IPC.kpEt, T_IPC.kiEt, lp.idiffq0_c, lp.vnq0_c, lp.idiffd0_c, lp.vnd0_c, T_IPC.number,T_IPC.bus, T_IPC.Vdc);
                ss_list{end+1} = energy_control;
                %% Inner Loops
                is_current_control = build_is_current_control( T_IPC.kpIs, T_IPC.kiIs, T_IPC.Lc,T_IPC.La ,T_IPC.fb, T_IPC.number,T_IPC.bus);
                ss_list{end+1} = is_current_control;
                isum_current_control = build_isum_current_control(T_IPC.kpIsum, T_IPC.kiIsum, T_IPC.number);
                ss_list{end+1} = isum_current_control;
                %% Syncrhonization loop:
                f_droop = build_GF_f_droop(T_IPC.kf, T_IPC.number,[REF_w num2str(T_IPC.SyncArea)]);
                ss_list{end+1} = f_droop;
                Pac_low_pass_filter = build_Pac_low_pass_filter(T_IPC.tPac, lp.vnq0_c, lp.vnd0_c,lp.idiffq0_c,lp.idiffd0_c,T_IPC.number,T_IPC.bus);
                ss_list{end+1} = Pac_low_pass_filter;
                %% MMC electric system:
                MMC_electric_circuit = build_MMC_electric_circuit(T_IPC.number,T_IPC.bus,T_IPC.busdc,T_IPC.Rc,T_IPC.Ra,T_IPC.Lc,T_IPC.La,T_IPC.fb);
                ss_list{end+1} = MMC_electric_circuit;
                %Total Energy:
                total_energy = build_total_energy(lp.idiffq0,lp.idiffd0,lp.vdiffq0,lp.vdiffd0,lp.isum0,lp.vsum0, T_IPC.number);
                ss_list{end+1} = total_energy;

                %% Change pu base from local to system:
                change_pu = build_change_pu(T_IPC.Sbpu_l2g,T_IPC.number);
                ss_list{end+1} = change_pu;
                
                %% Rotation matrix for all the input/output signals:
                %From global to local:
                %idiff:
                u = {  join(['IPC',num2str(T_IPC.number),'.idiffq']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.angle']) };
                y = {  join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']) ;... 
                       join(['IPC',num2str(T_IPC.number),'.idiffd_predelay'])};
                global_to_local_idiff = build_global_to_local(lp.etheta0, lp.idiffq0, lp.idiffd0 , u , y);
                ss_list{end+1} = global_to_local_idiff;
                %vn:
                u = { join(['NET','.vn',num2str(T_IPC.bus),'q']) ;... 
                      join(['NET','.vn',num2str(T_IPC.bus),'d']) ;...
                      join(['IPC',num2str(T_IPC.number),'.angle'] )};
                y = { join(['IPC',num2str(T_IPC.number),'.vq_predelay']) ;... 
                      join(['IPC',num2str(T_IPC.number),'.vd_predelay']) };
                global_to_local_vn = build_global_to_local(lp.etheta0, lp.vnq0, lp.vnd0 , u , y);
                ss_list{end+1} = global_to_local_vn;
                %From local to global:
                %vdiff
                u = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_c',num2str(T_IPC.number)] ); ...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_c',num2str(T_IPC.number)] ); ...
                      join(['IPC',num2str(T_IPC.number),'.angle'])                           };
                y = { join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] ) ;...
                      join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] )};...
                local_to_global_vdiff = build_local_to_global(lp.etheta0, lp.vdiffq0_c, lp.vdiffd0_c, u , y);
                ss_list{end+1} = local_to_global_vdiff;

                %% Commutation delays
                % Commutation delay q
                cmd_qx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_q1'] ); 
                cmd_qx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_q2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_q_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_q'] );
                cmd_q = build_com_delay_2order({cmd_qx1;cmd_qx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_q;

                % Commutation delay d
                cmd_dx1 = join( ['IPC',num2str(T_IPC.number),'.cmd_d1'] ); 
                cmd_dx2 = join( ['IPC',num2str(T_IPC.number),'.cmd_d2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vdiff_d_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vdiff_d'] );
                cmd_d = build_com_delay_2order({cmd_dx1;cmd_dx2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_d;

                % Commutation delay vsum0
                cmd_x1 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum1'] ); 
                cmd_x2 = join( ['IPC',num2str(T_IPC.number),'.cmd_vsum2'] );
                cmd_u = join( ['IPC',num2str(T_IPC.number),'.vsum0_precmd'] );
                cmd_y = join( ['IPC',num2str(T_IPC.number),'.vsum0'] );
                cmd_vsum = build_com_delay_2order({cmd_x1;cmd_x2},cmd_u,cmd_y,T_IPC.tau_cmd);

                ss_list{end+1} =  cmd_vsum;
                %% All signal delays:
                 %% All signal delays:
                %Uq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vq_zoh2'])};
                uq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = uq_zoh_delay;
                %Uq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'q_c',num2str(T_IPC.number)]);
                uq_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = uq_delay;
                
                %Ud ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.vd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vd_zoh2'])};
                ud_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = ud_zoh_delay;
                %Ud
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vn',num2str(T_IPC.bus),'d_c',num2str(T_IPC.number)]);
                ud_delay = build_delay(T_IPC.delay,delay_x,delay_u,delay_y);
                ss_list{end+1} = ud_delay;

                %idiffq ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffq_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffq_zoh2'])};
                idiffq_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffq_zoh_delay;
                %idiffq
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffq']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffq_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffq_c',num2str(T_IPC.number)]);
                idiffq_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffq_delay;

                %idiffd ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.idiffd_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.idiffd_zoh2'])};
                idiffd_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = idiffd_zoh_delay;
                %idiffd
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_idiffd']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.idiffd_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.idiffd_c',num2str(T_IPC.number)]);
                idiffd_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = idiffd_delay;

                %Et ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.Et_predelay']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.Et_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.Et_zoh2'])};
                Et_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = Et_zoh_delay;
                %Et
                delay_x = join(['IPC',num2str(T_IPC.number),'delay_Et']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.Et_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.Et']);
                Et_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = Et_delay;

                %vDC ZOH delay
                u_zoh = join(['DC_NET.v',num2str(T_IPC.busdc),'DC']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.vDC_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.vDC_zoh2'])};
                vDC_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = vDC_zoh_delay;
                %vDC
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_vDC']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.vDC_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.vDC_delay']);
                vdc_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = vdc_delay;

                %isum0 ZOH delay
                u_zoh = join(['IPC',num2str(T_IPC.number),'.isum0']);
                y_zoh = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                x_zoh = {join(['IPC',num2str(T_IPC.number),'.isum0_zoh1']);...
                         join(['IPC',num2str(T_IPC.number),'.isum0_zoh2'])};
                isum_zoh_delay = build_zoh2_2order(x_zoh,u_zoh,y_zoh,T_IPC.tau_cmd);
                ss_list{end+1} = isum_zoh_delay;
                %isum0
                delay_x = join(['IPC',num2str(T_IPC.number),'.delay_isum0']);
                delay_u = join(['IPC',num2str(T_IPC.number),'.isum0_zoh']);
                delay_y = join(['IPC',num2str(T_IPC.number),'.isum0_delay']);
                isum0_delay = build_delay(T_IPC.delay, delay_x, delay_u, delay_y);
                ss_list{end+1} = isum0_delay;

                % Build complete model
                input_vars = {join(['NET','.vn',num2str(T_IPC.bus),'q']),...                         
                              join(['NET','.vn',num2str(T_IPC.bus),'d']),...
                              [REF_w num2str(T_IPC.SyncArea)],...
                              join(['DC_NET.v',num2str(T_IPC.busdc),'DC'])};
                output_vars = {join(['IPC',num2str(T_IPC.number),'.idiffq']);... 
                               join(['IPC',num2str(T_IPC.number),'.idiffd']);... 
                               join(['IPC',num2str(T_IPC.number),'.w']);...
                               join(['IPC',num2str(T_IPC.number),'.iDC'])  };                  
                SS_IPC = connect(ss_list{:},input_vars,output_vars); 

                % append ss to l_blocks
                l_blocks{end+1} = SS_IPC;
        end
    end
end