function init_IPC = generate_initialization_IPC(T_IPC,T_global)
    
    init_IPC = cell(1,height(T_IPC));

    for ipc = 1:1:height(T_IPC)

        % Base powers
        Svsc = T_IPC.Sb(ipc);       % SG rated power, SG power base  
        Sb   = T_global.Sb(T_global.Area == T_IPC.Area(ipc)); % System power base
        wb   = 2*pi*T_global.fb(T_global.Area == T_IPC.Area(ipc)); % System power base

        % Rl filter and trafo
        Ra = T_IPC.Ra(ipc);
        Xa = T_IPC.Xa(ipc);
        Rc  = T_IPC.Rc(ipc);
        Xc  = T_IPC.Xc(ipc);
        
        Xeq = Xc + Xa/2;
        Req = Rc + Ra/2;

        %Data from the power-flow
        delta0   = T_IPC.theta(ipc)*pi/180;
        Vg       = (T_IPC.V(ipc)/sqrt(3))/1; % PCC line-neutral voltage RMS 
        Pvsc0    = T_IPC.P(ipc)*(Sb/Svsc);
        Qvsc0    = T_IPC.Q(ipc)*(Sb/Svsc);

        mode = T_IPC.mode{ipc};

        switch mode

            case 'AC-GFOL_DC-GFOL'

                % Calculation of voltages and currents (REF: NET-POC)
                Is       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi_is   = atan2(imag(Is),real(Is));
                Vdiff       = Vg + Is*(Req+1i*Xeq);               % voltage applied by the converter
                theta_vdiff = atan2(imag(Vdiff),real(Vdiff));  
                theta_in = 0; %No filter implemented

                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(Vg).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(Vg).*sin(delta_bus + theta_in)*sqrt(2);      
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vdiff_q0 = abs(Vdiff).*cos(delta_bus  + theta_vdiff)*sqrt(2); 
                vdiff_d0 = -abs(Vdiff).*sin(delta_bus + theta_vdiff)*sqrt(2); 
                 
       
                % Initial values in qd referenced to VSC REF 
        
                % qd converter voltage (REF:LOCAL)
                [vdiff_qc0,vdiff_dc0] = rotation_vect(real(Vdiff)*sqrt(2), -imag(Vdiff)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(Vg)*sqrt(2),  -imag(Vg)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
      
                % PLL 
                initIPC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vdiff_q0^2+vdiff_d0^2);
                initIPC.Udiff_mag   = Udiff_mag*1;
                initIPC.angle_vdiff = delta_bus  + theta_vdiff;

                initIPC.vdiffd = vdiff_dc0;
                initIPC.vdiffq = vdiff_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*1;
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initIPC.Isa = Isa_VSC;
                initIPC.Isb = Isb_VSC;
                initIPC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initIPC.idiffd = is_dc0;
                initIPC.idiffq = is_qc0;     
                             
                % U converter-POC voltage in abc, REF:LOCAL
        
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;
              
                % Differential current loops 
                Udiff_q = vdiff_qc0;
                Udiff_d = vdiff_dc0;
        
                initIPC.PI_idiffq =  Udiff_q - initIPC.uq - Xeq*initIPC.idiffd;
                initIPC.PI_idiffd =  Udiff_d - initIPC.ud + Xeq*initIPC.idiffq;
                initIPC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initIPC.PI_V = initIPC.idiffd;
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;  
                initIPC.Vref = u_qc0;
        
                % RL filter
                initIPC.Rc = T_IPC.Rc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Lc = T_IPC.Lc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Ra = T_IPC.Ra(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.La = T_IPC.La(ipc)/T_IPC.Sbpu_l2g(ipc); 

                % PQ references
                Scap = 3*Vg*conj(Is);
                initIPC.Pref = real(Scap);
                initIPC.Qref = imag(Scap); 

                initIPC.isum0_DC = (T_IPC.Pdc(ipc)/(3*T_IPC.Vdc(ipc)))*1;

                Vsum0_DC = (-2*initIPC.Ra*initIPC.isum0_DC+T_IPC.Vdc(ipc));
                initIPC.PI_isum0_DC = -(-T_IPC.Vdc(ipc)+Vsum0_DC);
                initIPC.vsum0 = Vsum0_DC;

                initIPC.Usuma = Vsum0_DC;
                initIPC.Usumb = Vsum0_DC;
                initIPC.Usumc = Vsum0_DC;
                
                initIPC.Vdc = T_IPC.Vdc(ipc);
                initIPC.Vdcref = T_IPC.Vdc(ipc);

                initIPC.PI_Wt = initIPC.isum0_DC-T_IPC.P(ipc)/(3*T_IPC.Vdc(ipc));

            case 'AC-GFOL_DC-GFOR'

                 % Calculation of voltages and currents (REF: NET-POC)
                Is       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi_is   = atan2(imag(Is),real(Is));
                Vdiff       = Vg + Is*(Req+1i*Xeq);               % voltage applied by the converter
                theta_vdiff = atan2(imag(Vdiff),real(Vdiff));  
                theta_in = 0; %No filter implemented

                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(Vg).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(Vg).*sin(delta_bus + theta_in)*sqrt(2);      
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vdiff_q0 = abs(Vdiff).*cos(delta_bus  + theta_vdiff)*sqrt(2); 
                vdiff_d0 = -abs(Vdiff).*sin(delta_bus + theta_vdiff)*sqrt(2); 
                 
       
                % Initial values in qd referenced to VSC REF 
        
                % qd converter voltage (REF:LOCAL)
                [vdiff_qc0,vdiff_dc0] = rotation_vect(real(Vdiff)*sqrt(2), -imag(Vdiff)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(Vg)*sqrt(2),  -imag(Vg)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
      
                % PLL 
                initIPC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vdiff_q0^2+vdiff_d0^2);
                initIPC.Udiff_mag   = Udiff_mag*1;
                initIPC.angle_vdiff = delta_bus  + theta_vdiff;

                initIPC.vdiffd = vdiff_dc0;
                initIPC.vdiffq = vdiff_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*1;
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initIPC.Isa = Isa_VSC;
                initIPC.Isb = Isb_VSC;
                initIPC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initIPC.idiffd = is_dc0;
                initIPC.idiffq = is_qc0;     
                             
                % U converter-POC voltage in abc, REF:LOCAL
        
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;
                
              
                % Differential current loops 
                Udiff_q = vdiff_qc0;
                Udiff_d = vdiff_dc0;
        
                initIPC.PI_idiffq =  Udiff_q - initIPC.uq - Xeq*initIPC.idiffd;
                initIPC.PI_idiffd =  Udiff_d - initIPC.ud + Xeq*initIPC.idiffq;
                initIPC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initIPC.PI_V = initIPC.idiffd;
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;    
                initIPC.Vref = u_qc0;
        
                % RL filter
                initIPC.Rc = T_IPC.Rc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Lc = T_IPC.Lc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Ra = T_IPC.Ra(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.La = T_IPC.La(ipc)/T_IPC.Sbpu_l2g(ipc); 

                % PQ references
                Scap = 3*Vg*conj(Is);
                initIPC.Pref = real(Scap);
                initIPC.Qref = imag(Scap);

                initIPC.isum0_DC = (T_IPC.Pdc(ipc)/(3*T_IPC.Vdc(ipc)))*1;
    
                Vsum0_DC = (-2*initIPC.Ra*initIPC.isum0_DC+T_IPC.Vdc(ipc));
                initIPC.PI_isum0_DC = -(-T_IPC.Vdc(ipc)+Vsum0_DC);
                initIPC.vsum0 = Vsum0_DC;

                initIPC.Usuma = Vsum0_DC;
                initIPC.Usumb = Vsum0_DC;
                initIPC.Usumc = Vsum0_DC;

                initIPC.Vdc = T_IPC.Vdc(ipc);
                initIPC.Vdcref = T_IPC.Vdc(ipc);

                initIPC.PI_Wt = initIPC.isum0_DC-T_IPC.P(ipc)/(3*T_IPC.Vdc(ipc));

            case 'AC-GFOR_DC-GFOL'

                % Calculation of voltages and currents (REF: NET-POC)
                Is       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi_is   = atan2(imag(Is),real(Is));
                Vdiff       = Vg + Is*(Req+1i*Xeq);               % voltage applied by the converter
                theta_vdiff = atan2(imag(Vdiff),real(Vdiff));  
                theta_in = 0; %No filter implemented

                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(Vg).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(Vg).*sin(delta_bus + theta_in)*sqrt(2);      
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vdiff_q0 = abs(Vdiff).*cos(delta_bus  + theta_vdiff)*sqrt(2); 
                vdiff_d0 = -abs(Vdiff).*sin(delta_bus + theta_vdiff)*sqrt(2); 
                 
       
                % Initial values in qd referenced to VSC REF 
        
                % qd converter voltage (REF:LOCAL)
                [vdiff_qc0,vdiff_dc0] = rotation_vect(real(Vdiff)*sqrt(2), -imag(Vdiff)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(Vg)*sqrt(2),  -imag(Vg)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
      
                % PLL 
                initIPC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vdiff_q0^2+vdiff_d0^2);
                initIPC.Udiff_mag   = Udiff_mag*1;
                initIPC.angle_vdiff = delta_bus  + theta_vdiff;

                initIPC.vdiffd = vdiff_dc0;
                initIPC.vdiffq = vdiff_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*1;
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initIPC.Isa = Isa_VSC;
                initIPC.Isb = Isb_VSC;
                initIPC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initIPC.idiffd = is_dc0;
                initIPC.idiffq = is_qc0;     
                             
                % U converter-POC voltage in abc, REF:LOCAL
        
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;
              
                % Differential current loops 
                Udiff_q = vdiff_qc0;
                Udiff_d = vdiff_dc0;
        
                initIPC.PI_idiffq =  Udiff_q - initIPC.uq - Xeq*initIPC.idiffd;
                initIPC.PI_idiffd =  Udiff_d - initIPC.ud + Xeq*initIPC.idiffq;
                initIPC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initIPC.PI_V = initIPC.idiffd;
                initIPC.ud = u_dc0;
                initIPC.uq = u_qc0;  
                initIPC.Vref = u_qc0;
        
                % RL filter
                initIPC.Rc = T_IPC.Rc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Lc = T_IPC.Lc(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.Ra = T_IPC.Ra(ipc)/T_IPC.Sbpu_l2g(ipc);
                initIPC.La = T_IPC.La(ipc)/T_IPC.Sbpu_l2g(ipc); 

                % PQ references
                Scap = 3*Vg*conj(Is);
                initIPC.Pref = real(Scap);
                initIPC.Qref = imag(Scap); 

                initIPC.isum0_DC = (T_IPC.Pdc(ipc)/(3*T_IPC.Vdc(ipc)))*1;
                
                Vsum0_DC = (-2*initIPC.Ra*initIPC.isum0_DC+T_IPC.Vdc(ipc));
                initIPC.PI_isum0_DC = -(-T_IPC.Vdc(ipc)+Vsum0_DC);
                initIPC.vsum0 = Vsum0_DC;

                initIPC.Usuma = Vsum0_DC;
                initIPC.Usumb = Vsum0_DC;
                initIPC.Usumc = Vsum0_DC;
                
                initIPC.Vdc = T_IPC.Vdc(ipc);
                initIPC.Vdcref = T_IPC.Vdc(ipc);

                initIPC.PI_Wt = initIPC.isum0_DC-T_IPC.P(ipc)/(3*T_IPC.Vdc(ipc));

                % Grid-Forming Loops: 
                initIPC.PI_vacq =  is_qc0-T_IPC.Cac(ipc)*T_IPC.fb(ipc)*2*pi*u_dc0;
                initIPC.PI_vacd =  is_dc0+T_IPC.Cac(ipc)*T_IPC.fb(ipc)*2*pi*u_qc0;

        end     

        init_IPC{ipc} = initIPC;
        
    end
end
