function l_blocks = generate_SS_MMC_Pac(T_MMC_Pac,lp_mmc,Connectivity_Matrix)

    for mmc = 1:1:height(T_MMC_Pac)
        lp = lp_mmc{mmc};
        T_MMC = T_MMC_Pac(mmc,:);
        %% Outer Loops:
        Pac_control = build_Pac_control(T_MMC.kpPac, T_MMC.kiPac, lp.idiffq0_c,lp.idiffd0_c,lp.vnq0_c,lp.vnd0_c,T_MMC.number,T_MMC.bus);
        Q_control = build_Q_control(T_MMC.kpQ, T_MMC.kiQ, lp.idiffq0_c,lp.idiffd0_c,lp.vnq0_c,lp.vnd0_c,T_MMC.number,T_MMC.bus);
        
        %% Energy Loop:
        energy_control = build_energy_control(T_MMC.kpEt, T_MMC.kiEt, T_MMC.number);
    
        %% Inner Loops
        is_current_control = build_is_current_control( T_MMC.kpIs, T_MMC.kiIs, T_MMC.Lc,T_MMC.La ,T_MMC.f, T_MMC.number,T_MMC.bus);
        isum_current_control = build_isum_current_control(T_MMC.kpIsum, T_MMC.kiIsum, T_MMC.number);
        
        %% PLL:
        PLL = build_PLL(T_MMC.kpPLL, T_MMC.kiPLL, T_MMC.number, T_MMC.bus);   
    
        %% MMC electric system:
        MMC_electric_circuit = build_MMC_electric_circuit(T_MMC.number,T_MMC.bus,T_MMC.busdc,T_MMC.Rc,T_MMC.Ra,T_MMC.Lc,T_MMC.La,T_MMC.f);
        %Total Energy:
        total_energy = build_total_energy(lp.idiffq0,lp.idiffd0,lp.vdiffq0,lp.vdiffd0,lp.isum0,lp.vsum0, T_MMC.number);
    
        %% Transformer
        if isequal(T_MMC.trafo{:},'Yes')
            if isequal(T_MMC.join_trafo{:},'Yes')
                [MMC_trafo,input_currents] = build_MMC_trafo(T_MMC.bus,T_MMC.number,Connectivity_Matrix,T_MMC.f,T_MMC.Rtrafo,T_MMC.Ltrafo); 
            elseif isequal(T_MMC.join_trafo{:},'No')
                SS_nus = build_sum_currents_v2(T_MMC.bus,Connectivity_Matrix);
                [MMC_trafo,input_currents] = build_MMC_trafo_v2(T_MMC.bus, T_MMC.number,T_MMC.f, T_MMC.Rtrafo, T_MMC.Ltrafo); 
            end
        end
        %% Rotation matrix for all the input/output signals:
        %From global to local:
        %idiff:
        u = {  join(['IPC',num2str(T_MMC.number),'.idiffq']) ;... 
               join(['IPC',num2str(T_MMC.number),'.idiffd']) ;... 
               join(['IPC',num2str(T_MMC.number),'.angle']) };
        y = {  join(['IPC',num2str(T_MMC.number),'.idiffq_predelay']) ;... 
               join(['IPC',num2str(T_MMC.number),'.idiffd_predelay'])};
        global_to_local_idiff = build_global_to_local(lp.etheta0, lp.idiffq0, lp.idiffd0 , u , y);
       
        %vn:
        u = { join(['NET','.vn',num2str(T_MMC.bus),'q']) ;... 
              join(['NET','.vn',num2str(T_MMC.bus),'d']) ;...
              join(['IPC',num2str(T_MMC.number),'.angle'] )};
        y = { join(['IPC',num2str(T_MMC.number),'.vq_predelay']) ;... 
              join(['IPC',num2str(T_MMC.number),'.vd_predelay']) };
        global_to_local_vn = build_global_to_local(lp.etheta0, lp.vnq0, lp.vnd0 , u , y);
        
        %From local to global:
        %vdiff
        u = { join( ['IPC',num2str(T_MMC.number),'.vdiff_q_c',num2str(T_MMC.number)] ); ...
              join( ['IPC',num2str(T_MMC.number),'.vdiff_d_c',num2str(T_MMC.number)] ); ...
              join(['IPC',num2str(T_MMC.number),'.angle'])                           };
        y = { join( ['IPC',num2str(T_MMC.number),'.vdiff_q'] ) ;...
              join( ['IPC',num2str(T_MMC.number),'.vdiff_d'] )};...
        local_to_global_vdiff = build_local_to_global(lp.etheta0, lp.vdiffq0_c, lp.vdiffd0_c, u , y);
    
        %% All signal delays:
        %Uq
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_vq']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.vq_predelay']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.vn',num2str(T_MMC.bus),'q_c',num2str(T_MMC.number)]);
        uq_delay = build_delay(T_MMC.delay,delay_x,delay_u,delay_y);
        
        %Ud
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_vd']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.vd_predelay']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.vn',num2str(T_MMC.bus),'d_c',num2str(T_MMC.number)]);
        ud_delay = build_delay(T_MMC.delay,delay_x,delay_u,delay_y);
        
        %idiffq
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_idiffq']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.idiffq_predelay']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.idiffq_c',num2str(T_MMC.number)]);
        idiffq_delay = build_delay(T_MMC.delay, delay_x, delay_u, delay_y);
        
        %idiffd
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_idiffd']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.idiffd_predelay']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.idiffd_c',num2str(T_MMC.number)]);
        idiffd_delay = build_delay(T_MMC.delay, delay_x, delay_u, delay_y);
        
        %Et
        delay_x = join(['IPC',num2str(T_MMC.number),'delay_Et']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.Et_predelay']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.Et']);
        Et_delay = build_delay(T_MMC.delay, delay_x, delay_u, delay_y);
    
        %vDC
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_vDC']);
        delay_u = join(['DC_NET.v',num2str(T_MMC.busdc),'DC']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.vDC_delay']);
        vdc_delay = build_delay(T_MMC.delay, delay_x, delay_u, delay_y);
    
        %isum0
        delay_x = join(['IPC',num2str(T_MMC.number),'.delay_isum0']);
        delay_u = join(['IPC',num2str(T_MMC.number),'.isum0']);
        delay_y = join(['IPC',num2str(T_MMC.number),'.isum0_delay']);
        isum0_delay = build_delay(T_MMC.delay, delay_x, delay_u, delay_y);
    
        %% Connect
        if isequal(T_MMC.trafo{:},'Yes')
            if isequal(T_MMC.join_trafo{:},'Yes')
                y = {join(['NET','.vn',num2str(T_MMC.bus),'q']);... 
                     join(['NET','.vn',num2str(T_MMC.bus),'d']);...  
                     join(['IPC',num2str(T_MMC.number),'.iDC'])   ;...
                     join(['IPC',num2str(T_MMC.number),'.Et'])    };
        
                u = {join(['IPC',num2str(T_MMC.number),'.Pac_ref'])                        ;...
                     join(['IPC',num2str(T_MMC.number),'.Q_ref'])                          ;...
                     join(['IPC',num2str(T_MMC.number),'.Et_ref'])                         ;...
                     join(['IPC',num2str(T_MMC.number),'.angle_ref'] )                     ;...       
                     join(['DC_NET.v',num2str(T_MMC.busdc),'DC']);                        };
                % Add currents to the inputs:
                u = [u;input_currents];
                T_MMC_Pac.ss{mmc} = connect(Pac_control,Q_control,energy_control,...
                                   is_current_control,isum_current_control,PLL,MMC_electric_circuit,total_energy,...
                                   MMC_trafo,global_to_local_idiff,global_to_local_vn,local_to_global_vdiff,...
                                   uq_delay,ud_delay,idiffq_delay,idiffd_delay,Et_delay,...
                                   vdc_delay,isum0_delay,u,y);
            elseif isequal(T_MMC.join_trafo{:},'No')
            y = {join(['IPC',num2str(T_MMC.number),'.idiffq']);... 
                 join(['IPC',num2str(T_MMC.number),'.idiffd']);...  
                 join(['IPC',num2str(T_MMC.number),'.iDC'])   ;...
                 join(['IPC',num2str(T_MMC.number),'.Et'])    };
    
            u = {join(['NET','.vn',num2str(T_MMC.bus),'q'])                         ;... 
                 join(['NET','.vn',num2str(T_MMC.bus),'d'])                         ;...
                 join(['IPC',num2str(T_MMC.number),'.Pac_ref'])                        ;...
                 join(['IPC',num2str(T_MMC.number),'.Q_ref'])                          ;...
                 join(['IPC',num2str(T_MMC.number),'.Et_ref'])                         ;...
                 join(['IPC',num2str(T_MMC.number),'.angle_ref'] )                     ;...       
                 join(['DC_NET.v',num2str(T_MMC.busdc),'DC']);                        };
    
            T_MMC_Pac.ss{mmc} = connect(Pac_control,Q_control,energy_control,...
                               is_current_control,isum_current_control,PLL,MMC_electric_circuit,total_energy,...
                               global_to_local_idiff,global_to_local_vn,local_to_global_vdiff,...
                               uq_delay,ud_delay,idiffq_delay,idiffd_delay,Et_delay,...
                               vdc_delay,isum0_delay,u,y);    
            T_MMC_Pac.ss_trafo{mmc} = {SS_nus MMC_trafo};
            end
        else
            y = {join(['IPC',num2str(T_MMC.number),'.idiffq']);... 
                 join(['IPC',num2str(T_MMC.number),'.idiffd']);...  
                 join(['IPC',num2str(T_MMC.number),'.iDC'])   ;...
                 join(['IPC',num2str(T_MMC.number),'.Et'])    };
    
            u = {join(['NET','.vn',num2str(T_MMC.bus),'q'])                         ;... 
                 join(['NET','.vn',num2str(T_MMC.bus),'d'])                         ;...
                 join(['IPC',num2str(T_MMC.number),'.Pac_ref'])                        ;...
                 join(['IPC',num2str(T_MMC.number),'.Q_ref'])                          ;...
                 join(['IPC',num2str(T_MMC.number),'.Et_ref'])                         ;...
                 join(['IPC',num2str(T_MMC.number),'.angle_ref'] )                     ;...       
                 join(['DC_NET.v',num2str(T_MMC.busdc),'DC']);                        };
    
            T_MMC_Pac.ss{mmc} = connect(Pac_control,Q_control,energy_control,...
                               is_current_control,isum_current_control,PLL,MMC_electric_circuit,total_energy,...
                               global_to_local_idiff,global_to_local_vn,local_to_global_vdiff,...
                               uq_delay,ud_delay,idiffq_delay,idiffd_delay,Et_delay,...
                               vdc_delay,isum0_delay,u,y);
        end    
    end
end