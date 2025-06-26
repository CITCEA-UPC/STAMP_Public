function init_VSC = generate_initialization_VSC(T_VSC,T_global)
    
    init_VSC = cell(1,height(T_VSC));

    for vsc = 1:1:height(T_VSC)

        % Base powers
        Svsc = T_VSC.Sb(vsc);       % SG rated power, SG power base  
        Sb  = T_global.Sb(T_global.Area == T_VSC.Area(vsc)); % System power base

        % Rl filter and trafo
        Rtr = T_VSC.Rtr(vsc);
        Xtr = T_VSC.Xtr(vsc);
        Rc  = T_VSC.Rc(vsc);
        Xc  = T_VSC.Xc(vsc);

        %Data from the power-flow
        delta0   = T_VSC.theta(vsc)*pi/180;
        %Vg       = (T_VSC.V(vsc)/sqrt(3))/T_VSC.Vbpu_l2g(vsc); % PCC line-neutral voltage RMS 
        Vg       = (T_VSC.V(vsc)/sqrt(3))/1; % PCC line-neutral voltage RMS 
        Pvsc0    = T_VSC.P(vsc)*(Sb/Svsc);
        Qvsc0    = T_VSC.Q(vsc)*(Sb/Svsc);

        mode = T_VSC.mode{vsc};

        switch mode

            case 'GFOL'   

                Rac = T_VSC.Rac(vsc);
                Cac = T_VSC.Cac(vsc);
                wb = T_VSC.wb(vsc);

                % Calculation of voltages and currents (REF: NET-POC)
                Ig       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi      = atan2(imag(Ig),real(Ig));        % angle of transformer current
                U        = Vg + Ig*(Rtr+1i*Xtr);            % Voltage at capacitor bus
                theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
                Icap     = U/(Rac-1i/(wb*Cac));             % current through capacitor
                Ucap     = U - Rac*Icap;
                theta_ucap = atan2(imag(Ucap),real(Ucap));
                Is       = Ig + Icap;                       % converter filter current
                phi_is   = atan2(imag(Is),real(Is));
                Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
                theta_vc = atan2(imag(Vc),real(Vc));  

%                 % Calculation of voltages and currents (REF: NET-POC)
%                 Is       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % converter filter current 
%                 phi_is   = atan2(imag(Is),real(Is));
%                 U        = Vg + Is*(Rtr+1i*Xtr);            % Voltage at capacitor bus    
%                 theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
%                 Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
%                 theta_vc = atan2(imag(Vc),real(Vc)); 


                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(U).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(U).*sin(delta_bus + theta_in)*sqrt(2);      

                % qd TRAFO current (REF:GLOBAL)
                ig_q0 = abs(Ig).*cos(delta_bus  + phi)*sqrt(2);
                ig_d0 = -abs(Ig).*sin(delta_bus + phi)*sqrt(2);
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vc_q0 = abs(Vc).*cos(delta_bus  + theta_vc)*sqrt(2); 
                vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc)*sqrt(2); 

                % Capacitor voltage (REF:GLOBAL)
                ucap_q0 = abs(Ucap).*cos(delta_bus + theta_ucap)*sqrt(2);
                ucap_d0 = -abs(Ucap).*sin(delta_bus + theta_ucap)*sqrt(2);
                        
        
                % Initial values in qd referenced to VSC REF 
                % qd converter voltage (REF:LOCAL)
                [vg_qc0,vg_dc0] = rotation_vect(real(Vg)*sqrt(2), -imag(Vg)*sqrt(2), theta_in); 
                % qd converter voltage (REF:LOCAL)
                [vc_qc0,vc_dc0] = rotation_vect(real(Vc)*sqrt(2), -imag(Vc)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(U)*sqrt(2),  -imag(U)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
                % qd NET-POC current (REF:LOCAL)
                [ig_qc0,ig_dc0] = rotation_vect(real(Ig)*sqrt(2),-imag(Ig)*sqrt(2), theta_in);
      
                % PLL 
                initVSC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vc_q0^2+vc_d0^2);
                %initVSC.Udiff_mag   = Udiff_mag*T_VSC.Vbpu_l2g(vsc);
                initVSC.Udiff_mag   = Udiff_mag*1;
                initVSC.angle_vdiff = delta_bus  + theta_vc;

                initVSC.vdiffd = vc_dc0;
                initVSC.vdiffq = vc_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                %Is_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Ibpu_l2g(vsc);
                Is_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Sbpu_l2g(vsc);

                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initVSC.Isa = Isa_VSC;
                initVSC.Isb = Isb_VSC;
                initVSC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initVSC.idiffd = is_dc0;
                initVSC.idiffq = is_qc0;     
        
                % Ig transformer current in abc, REF:GLOBAL
        
%               Ig_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Ibpu_l2g(vsc);
%         
%               Iga = Ig_mag*sin(delta_bus + phi_is);
%               Igb = Ig_mag*sin(delta_bus + phi_is -2*pi/3);
%               Igc = Ig_mag*sin(delta_bus + phi_is +2*pi/3);
%         
%               initVSC.Iga = Iga;
%               initVSC.Igb = Igb;
%               initVSC.Igc = Igc;  
        
                %Ig_mag = sqrt(ig_q0^2+ig_d0^2)*T_VSC.Ibpu_l2g(vsc);
                Ig_mag = sqrt(ig_q0^2+ig_d0^2)*T_VSC.Sbpu_l2g(vsc);

                Iga = Ig_mag*sin(delta_bus + phi);
                Igb = Ig_mag*sin(delta_bus + phi -2*pi/3);
                Igc = Ig_mag*sin(delta_bus + phi +2*pi/3);
        
                initVSC.Iga = Iga;
                initVSC.Igb = Igb;
                initVSC.Igc = Igc;  

                % U converter-POC voltage in abc, REF:LOCAL
        
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;

                % Ig NET-POC current, REF:LOCAL        
                initVSC.igd = ig_dc0;
                initVSC.igq = ig_qc0;
                
                % Differential current loops 
                Udiff_q = vc_qc0;
                Udiff_d = vc_dc0;
        
                initVSC.PI_idiffq =  Udiff_q - initVSC.uq - Xc*initVSC.idiffd;
                initVSC.PI_idiffd =  Udiff_d - initVSC.ud + Xc*initVSC.idiffq;
                initVSC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initVSC.PI_V = initVSC.idiffd;
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;       
        
                % RL filter
                % initVSC.Rtr = T_VSC.Rtr(vsc)*T_VSC.Zbpu_l2g(vsc);
                % initVSC.Ltr = T_VSC.Ltr(vsc)*T_VSC.Zbpu_l2g(vsc);
                % initVSC.Rc = T_VSC.Rc(vsc)*T_VSC.Zbpu_l2g(vsc);
                % initVSC.Lc = T_VSC.Lc(vsc)*T_VSC.Zbpu_l2g(vsc);
                % initVSC.Rac = T_VSC.Rac(vsc)*T_VSC.Zbpu_l2g(vsc);
                % initVSC.Cac = T_VSC.Cac(vsc)/T_VSC.Zbpu_l2g(vsc); 

                initVSC.Rtr = T_VSC.Rtr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Ltr = T_VSC.Ltr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rc = T_VSC.Rc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Lc = T_VSC.Lc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rac = T_VSC.Rac(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Cac = T_VSC.Cac(vsc)*T_VSC.Sbpu_l2g(vsc); 

                % Capacitor initial voltages, REF:GLOBAL
                %Ucap_mag = sqrt(ucap_q0^2+ucap_d0^2)*T_VSC.Vbpu_l2g(vsc);
                Ucap_mag = sqrt(ucap_q0^2+ucap_d0^2)*1;

                initVSC.Ucap_a = Ucap_mag*sin(delta_bus + theta_ucap);
                initVSC.Ucap_b = Ucap_mag*sin(delta_bus + theta_ucap -2*pi/3);
                initVSC.Ucap_c = Ucap_mag*sin(delta_bus + theta_ucap +2*pi/3);

                % PQ references
                %Scap = 3*U*conj(Is); %no capacitor
                Scap = 3*U*conj(Ig);
                initVSC.Pref = real(Scap);
                initVSC.Qref = imag(Scap); 
                

            case 'GFOR'

                Rac = T_VSC.Rac(vsc);
                Cac = T_VSC.Cac(vsc);
                wb = T_VSC.wb(vsc);

                % Calculation of voltages and currents (REF: NET-POC)
                Ig       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi      = atan2(imag(Ig),real(Ig));        % angle of transformer current
                U        = Vg + Ig*(Rtr+1i*Xtr);            % Voltage at capacitor bus
                theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
                Icap     = U/(Rac-1i/(wb*Cac));             % current through capacitor
                Ucap     = U - Rac*Icap;
                theta_ucap = atan2(imag(Ucap),real(Ucap));
                Is       = Ig + Icap;                       % converter filter current
                phi_is   = atan2(imag(Is),real(Is));
                Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
                theta_vc = atan2(imag(Vc),real(Vc));        
        
                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(U).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(U).*sin(delta_bus + theta_in)*sqrt(2);
                
                % qd TRAFO current (REF:GLOBAL)
                ig_q0 = abs(Ig).*cos(delta_bus  + phi)*sqrt(2);
                ig_d0 = -abs(Ig).*sin(delta_bus + phi)*sqrt(2);
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vc_q0 = abs(Vc).*cos(delta_bus  + theta_vc)*sqrt(2); 
                vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc)*sqrt(2); 
                
                % Capacitor voltage (REF:GLOBAL)
                ucap_q0 = abs(Ucap).*cos(delta_bus + theta_ucap)*sqrt(2);
                ucap_d0 = -abs(Ucap).*sin(delta_bus + theta_ucap)*sqrt(2);
        
        
                % Initial values in qd referenced to VSC REF 
        
                % qd transformer NET-POC voltage (REF:LOCAL)
                [vg_qc0,vg_dc0] = rotation_vect(real(Vg)*sqrt(2), -imag(Vg)*sqrt(2), theta_in);   
                % qd converter voltage (REF:LOCAL)
                [vc_qc0,vc_dc0] = rotation_vect(real(Vc)*sqrt(2), -imag(Vc)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(U)*sqrt(2),  -imag(U)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
                % qd NET-POC current (REF:LOCAL)
                [ig_qc0,ig_dc0] = rotation_vect(real(Ig)*sqrt(2),-imag(Ig)*sqrt(2), theta_in);
        
                % PLL 
                initVSC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vc_q0^2+vc_d0^2);
                initVSC.Udiff_mag   = Udiff_mag*1;
                initVSC.angle_vdiff = delta_bus  + theta_vc;
                
                initVSC.vdiffd = vc_dc0;
                initVSC.vdiffq = vc_qc0;
                
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Sbpu_l2g(vsc);
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initVSC.Isa = Isa_VSC;
                initVSC.Isb = Isb_VSC;
                initVSC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initVSC.idiffd = is_dc0;
                initVSC.idiffq = is_qc0;     
        
                % Ig transformer current in abc, REF:GLOBAL
        
                Ig_mag = sqrt(ig_q0^2+ig_d0^2)*T_VSC.Sbpu_l2g(vsc);
        
                Iga = Ig_mag*sin(delta_bus + phi);
                Igb = Ig_mag*sin(delta_bus + phi -2*pi/3);
                Igc = Ig_mag*sin(delta_bus + phi +2*pi/3);
        
                initVSC.Iga = Iga;
                initVSC.Igb = Igb;
                initVSC.Igc = Igc;  
        
                % U converter-POC voltage in abc, REF:LOCAL
        
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;
        
                % Ig NET-POC current, REF:LOCAL
        
                initVSC.igd = ig_dc0;
                initVSC.igq = ig_qc0;
        
                % Differential current loops 
                Udiff_q = vc_qc0;
                Udiff_d = vc_dc0;
        
                initVSC.PI_idiffq =  Udiff_q - initVSC.uq - Xc*initVSC.idiffd;
                initVSC.PI_idiffd =  Udiff_d - initVSC.ud + Xc*initVSC.idiffq;
                initVSC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initVSC.PI_V = initVSC.idiffd;
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;
        
                % Grid-Forming Loops: 
                initVSC.PI_vacq =  initVSC.idiffq - wb*Cac*initVSC.ud - initVSC.igq;
                initVSC.PI_vacd =  initVSC.idiffd + wb*Cac*initVSC.uq - initVSC.igd;
        
                % RL filter
                initVSC.Rtr = T_VSC.Rtr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Ltr = T_VSC.Ltr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rc = T_VSC.Rc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Lc = T_VSC.Lc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rac = T_VSC.Rac(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Cac = T_VSC.Cac(vsc)*T_VSC.Sbpu_l2g(vsc); 
        
                % Capacitor initial voltages, REF:GLOBAL
                Ucap_mag = sqrt(ucap_q0^2+ucap_d0^2)*1;
        
                initVSC.Ucap_a = Ucap_mag*sin(delta_bus + theta_ucap);
                initVSC.Ucap_b = Ucap_mag*sin(delta_bus + theta_ucap -2*pi/3);
                initVSC.Ucap_c = Ucap_mag*sin(delta_bus + theta_ucap +2*pi/3);
        
                % PQ references
                Scap = 3*U*conj(Ig);
                initVSC.Pref = real(Scap);
                initVSC.Qref = imag(Scap); 

            case 'STATCOM'
                Rac = T_VSC.Rac(vsc);
                Cac = T_VSC.Cac(vsc);
                wb = T_VSC.wb(vsc);

                % Calculation of voltages and currents (REF: NET-POC)
                Ig       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi      = atan2(imag(Ig),real(Ig));        % angle of transformer current
                U        = Vg + Ig*(Rtr+1i*Xtr);            % Voltage at capacitor bus
                theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
                Icap     = U/(Rac-1i/(wb*Cac));             % current through capacitor
                Ucap     = U - Rac*Icap;
                theta_ucap = atan2(imag(Ucap),real(Ucap));
                Is       = Ig + Icap;                       % converter filter current
                phi_is   = atan2(imag(Is),real(Is));
                Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
                theta_vc = atan2(imag(Vc),real(Vc));  

%                 % Calculation of voltages and currents (REF: NET-POC)
%                 Is       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % converter filter current 
%                 phi_is   = atan2(imag(Is),real(Is));
%                 U        = Vg + Is*(Rtr+1i*Xtr);            % Voltage at capacitor bus    
%                 theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
%                 Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
%                 theta_vc = atan2(imag(Vc),real(Vc)); 


                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(U).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(U).*sin(delta_bus + theta_in)*sqrt(2);      

                % qd TRAFO current (REF:GLOBAL)
                ig_q0 = abs(Ig).*cos(delta_bus  + phi)*sqrt(2);
                ig_d0 = -abs(Ig).*sin(delta_bus + phi)*sqrt(2);
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vc_q0 = abs(Vc).*cos(delta_bus  + theta_vc)*sqrt(2); 
                vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc)*sqrt(2); 

                % Capacitor voltage (REF:GLOBAL)
                ucap_q0 = abs(Ucap).*cos(delta_bus + theta_ucap)*sqrt(2);
                ucap_d0 = -abs(Ucap).*sin(delta_bus + theta_ucap)*sqrt(2);
                        
        
                % Initial values in qd referenced to VSC REF 
        
                % qd converter voltage (REF:LOCAL)
                [vc_qc0,vc_dc0] = rotation_vect(real(Vc)*sqrt(2), -imag(Vc)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(U)*sqrt(2),  -imag(U)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
                % qd NET-POC current (REF:LOCAL)
                [ig_qc0,ig_dc0] = rotation_vect(real(Ig)*sqrt(2),-imag(Ig)*sqrt(2), theta_in);
      
                % PLL 
                initVSC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
        
                % Udiff converter voltage in abc, REF:GLOBAL
        
                Udiff_mag = sqrt(vc_q0^2+vc_d0^2);
                initVSC.Udiff_mag   = Udiff_mag*1;
                initVSC.angle_vdiff = delta_bus  + theta_vc;

                initVSC.vdiffd = vc_dc0;
                initVSC.vdiffq = vc_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Sbpu_l2g(vsc);
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initVSC.Isa = Isa_VSC;
                initVSC.Isb = Isb_VSC;
                initVSC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initVSC.idiffd = is_dc0;
                initVSC.idiffq = is_qc0;     
        
                % Ig transformer current in abc, REF:GLOBAL
        
%               Ig_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Ibpu_l2g(vsc);
%         
%               Iga = Ig_mag*sin(delta_bus + phi_is);
%               Igb = Ig_mag*sin(delta_bus + phi_is -2*pi/3);
%               Igc = Ig_mag*sin(delta_bus + phi_is +2*pi/3);
%         
%               initVSC.Iga = Iga;
%               initVSC.Igb = Igb;
%               initVSC.Igc = Igc;  
        
                Ig_mag = sqrt(ig_q0^2+ig_d0^2)*T_VSC.Sbpu_l2g(vsc);
        
                Iga = Ig_mag*sin(delta_bus + phi);
                Igb = Ig_mag*sin(delta_bus + phi -2*pi/3);
                Igc = Ig_mag*sin(delta_bus + phi +2*pi/3);
        
                initVSC.Iga = Iga;
                initVSC.Igb = Igb;
                initVSC.Igc = Igc;  

                % U converter-POC voltage in abc, REF:LOCAL
        
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;

                % Ig NET-POC current, REF:LOCAL        
                initVSC.igd = ig_dc0;
                initVSC.igq = ig_qc0;
                
                % Differential current loops 
                Udiff_q = vc_qc0;
                Udiff_d = vc_dc0;
        
                initVSC.PI_idiffq =  Udiff_q - initVSC.uq - Xc*initVSC.idiffd;
                initVSC.PI_idiffd =  Udiff_d - initVSC.ud + Xc*initVSC.idiffq;
                initVSC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initVSC.PI_V = initVSC.idiffd;
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;       
        
                % RL filter
                initVSC.Rtr = T_VSC.Rtr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Ltr = T_VSC.Ltr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rc = T_VSC.Rc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Lc = T_VSC.Lc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rac = T_VSC.Rac(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Cac = T_VSC.Cac(vsc)*T_VSC.Sbpu_l2g(vsc); 

                % Capacitor initial voltages, REF:GLOBAL
                Ucap_mag = sqrt(ucap_q0^2+ucap_d0^2)*1;
        
                initVSC.Ucap_a = Ucap_mag*sin(delta_bus + theta_ucap);
                initVSC.Ucap_b = Ucap_mag*sin(delta_bus + theta_ucap -2*pi/3);
                initVSC.Ucap_c = Ucap_mag*sin(delta_bus + theta_ucap +2*pi/3);

                % PQ references
                %Scap = 3*U*conj(Is); %no capacitor
                Scap = 3*U*conj(Ig);
                initVSC.Pref = real(Scap);
                initVSC.Qref = imag(Scap); 

          case 'WT'
                Rac = T_VSC.Rac(vsc);
                Cac = T_VSC.Cac(vsc);
                wb = T_VSC.wb(vsc);
                cc_damp = T_VSC.cc_damp(vsc);

                 %LOCAL per unit BASE:
                 % RLC filter
                 % angle between POC and capacitor bus

                 % Need to include the filters deviation!
                    % Butterworth filter:
                    if T_VSC.fc(vsc) == -1
                        phase_btwf = 0;
                    else
                        [Ass,Bss,Css,Dss] = butter(2,T_VSC.fc(vsc)*2*pi,'low','s');
                        x = {'x1';'x2'};
                        u = {'u'};
                        y = {'y'};
                        btw_filter = ss(Ass,Bss,Css,Dss,'statename',x,'inputname',u,'outputname',y);
                        [mag,phase,wout] = bode(btw_filter,2*pi*50);
                        phase_btwf = phase*pi/180;
                        %phase_btwf_pre2 = -2*atan(50/T_VSC.fc(vsc))
                        %phase_btwf = -atan((2*1/sqrt(2)*50/T_VSC.fc(vsc))/1-(50/T_VSC.fc(vsc))^2);
                    end

                    % Zero-order-hold:
                    if T_VSC.tau_zoh(vsc) == -1
                        phase_zoh = 0;
                    else
                        a = [20*T_VSC.tau_zoh(vsc)^2 -60*T_VSC.tau_zoh(vsc) +840];
                        b = [60*T_VSC.tau_zoh(vsc)^2 +360*T_VSC.tau_zoh(vsc) +840];
                        [Ass,Bss,Css,Dss] = tf2ss(a,b);
                        x = {'x1';'x2'};
                        u = {'u'};
                        y = {'y'};
                        zoh = ss(Ass,Bss,Css,Dss,'statename',x,'inputname',u,'outputname',y);
                        [mag,phase,wout] = bode(zoh,2*pi*50);
                        phase_zoh = phase*pi/180;

                        %phase_zoh = -atan((1-cos(2*pi*50*T_VSC.tau_zoh(vsc)))/sin(2*pi*50*T_VSC.tau_zoh(vsc)));

                        %phase_zoh = -2*pi*50*T_VSC.tau_zoh(vsc)/2;
                    end
                    %delay
                    if T_VSC.tau_cmd(vsc) == -1
                        phase_delay = 0;
                    else
                        a = [12*T_VSC.tau_cmd(vsc)^2 -60*T_VSC.tau_cmd(vsc) 120];
                        b = [12*T_VSC.tau_cmd(vsc)^2 60*T_VSC.tau_cmd(vsc) 120];

                        [Ass,Bss,Css,Dss] = tf2ss(a,b);
                        x = {'x1';'x2'};
                        u = {'u'};
                        y = {'y'};
                        delay = ss(Ass,Bss,Css,Dss,'statename',x,'inputname',u,'outputname',y);
                        [mag,phase,wout] = bode(delay,2*pi*50);
                        phase_delay = phase*pi/180;

                        phase_delay = -2*pi*50*1*T_VSC.tau_cmd(vsc);
                    end

                 

                % Calculation of voltages and currents (REF: NET-POC)
                Ig       = conj((Pvsc0+1i*Qvsc0)./(3*Vg));  % Transformer current 
                phi      = atan2(imag(Ig),real(Ig));        % angle of transformer current
                U        = Vg + Ig*(Rtr+1i*Xtr);            % Voltage at capacitor bus
                theta_in = atan2(imag(U),real(U));          % angle between POC and capacitor bus
                theta_in_filt = theta_in + phase_btwf+phase_zoh+phase_delay; % angle including filters
                %theta_in_filt = theta_in + phase_delay;
                theta_md = theta_in - phase_delay;
                Icap     = U/(Rac-1i/(wb*Cac));             % current through capacitor
                Ucap     = U - Rac*Icap;
                theta_ucap = atan2(imag(Ucap),real(Ucap));
                Is       = Ig + Icap;                       % converter filter current
                phi_is   = atan2(imag(Is),real(Is));
                Vc       = U + Is*(Rc+1i*Xc);               % voltage applied by the converter
                theta_vc = atan2(imag(Vc),real(Vc));  

                % In peak values:
                Vg_peak = Vg*sqrt(2);
                Ig_peak = 2/3*conj((Pvsc0+1i*Qvsc0)./(Vg_peak));
                phi_peak= atan2(imag(Ig),real(Ig));        % angle of transformer current
                U_peak  = Vg_peak + Ig_peak*(Rtr+1i*Xtr);            % Voltage at capacitor bus
                theta_in_peak = atan2(imag(U_peak),real(U_peak)); 

                % Initial values in qd referenced to GLOBAL REF
        
                delta_bus = delta0; % NET-POC
        
                % qd GRID voltage (REF:GLOBAL)
                vg_q0 = abs(Vg).*cos(delta_bus)*sqrt(2);
                vg_d0 = -abs(Vg).*sin(delta_bus)*sqrt(2);
                
                % qd VSC-PCC voltage (REF:GLOBAL)
                u_q0 = abs(U).*cos(delta_bus  + theta_in)*sqrt(2);
                u_d0 = -abs(U).*sin(delta_bus + theta_in)*sqrt(2);   

                initVSC.U_mag = abs(U)*sqrt(2);
                initVSC.angle_umag = delta_bus+theta_in;

                % qd TRAFO current (REF:GLOBAL)
                ig_q0 = abs(Ig).*cos(delta_bus  + phi)*sqrt(2);
                ig_d0 = -abs(Ig).*sin(delta_bus + phi)*sqrt(2);
                
                % VSC current (REF:GLOBAL)
                is_q0 = abs(Is).*cos(delta_bus  + phi_is)*sqrt(2);
                is_d0 = -abs(Is).*sin(delta_bus + phi_is)*sqrt(2);
                
                % qd converter voltage (REF:GLOBAL)
                vc_q0 = abs(Vc).*cos(delta_bus  + theta_vc)*sqrt(2); 
                vc_d0 = -abs(Vc).*sin(delta_bus + theta_vc)*sqrt(2); 

                % Capacitor voltage (REF:GLOBAL)
                ucap_q0 = abs(Ucap).*cos(delta_bus + theta_ucap)*sqrt(2);
                ucap_d0 = -abs(Ucap).*sin(delta_bus + theta_ucap)*sqrt(2);
                        
        
                % Initial values in qd referenced to VSC REF 
                % qd converter voltage (REF:LOCAL)
                [vg_qc0,vg_dc0] = rotation_vect(real(Vg)*sqrt(2), -imag(Vg)*sqrt(2), theta_in); 
                % qd converter voltage (REF:LOCAL)
                [vc_qc0,vc_dc0] = rotation_vect(real(Vc)*sqrt(2), -imag(Vc)*sqrt(2), theta_in);                
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0,u_dc0]   = rotation_vect(real(U)*sqrt(2),  -imag(U)*sqrt(2), theta_in);                
                % qd VSC-POC current (REF:LOCAL)
                [is_qc0,is_dc0] = rotation_vect(real(Is)*sqrt(2),-imag(Is)*sqrt(2), theta_in);
                % qd NET-POC current (REF:LOCAL)
                [ig_qc0,ig_dc0] = rotation_vect(real(Ig)*sqrt(2),-imag(Ig)*sqrt(2), theta_in);
      
                % PEAK base - Initial values in qd referenced to VSC REF 
                % qd converter voltage (REF:LOCAL)
                [vg_qc0_p,vg_dc0_p] = rotation_vect(real(Vg)*sqrt(3), -imag(Vg)*sqrt(3), theta_in);
                [vg_qc0_m,vg_dc0_m] = rotation_vect(real(Vg)*sqrt(3), -imag(Vg)*sqrt(3), theta_in_filt);
                initVSC.vg_qc0_m = vg_qc0_m;
                initVSC.vg_dc0_m = vg_dc0_m;
                % qd converter voltage (REF:LOCAL)
                [vc_qc0_p,vc_dc0_p] = rotation_vect(real(Vc)*sqrt(3), -imag(Vc)*sqrt(3), theta_in);   
                [vc_qc0_m,vc_dc0_m] = rotation_vect(real(Vc)*sqrt(3), -imag(Vc)*sqrt(3), theta_in_filt);           
                initVSC.vc_qc0_m = vc_qc0_m;
                initVSC.vc_dc0_m = vc_dc0_m;
                % qd VSC-POC voltage (REF:LOCAL)
                [u_qc0_p,u_dc0_p] = rotation_vect(real(U)*sqrt(3), -imag(U)*sqrt(3), theta_in);     
                [u_qc0_m,u_dc0_m] = rotation_vect(real(U)*sqrt(3), -imag(U)*sqrt(3), theta_in_filt); 
                initVSC.u_qc0_m = u_qc0_m;
                initVSC.u_dc0_m = u_dc0_m;
                % qd VSC current (REF:LOCAL)
                [is_qc0_p,is_dc0_p] = rotation_vect(real(Is)*sqrt(3), -imag(Is)*sqrt(3), theta_in);
                [is_qc0_m,is_dc0_m] = rotation_vect(real(Is)*sqrt(3), -imag(Is)*sqrt(3), theta_in_filt);
                initVSC.is_qc0_m = is_qc0_m;
                initVSC.is_dc0_m = is_dc0_m;
                % qd VSC-POC grid current (REF:LOCAL)
                [ig_qc0_p,ig_dc0_p] = rotation_vect(real(Ig)*sqrt(3), -imag(Ig)*sqrt(3), theta_in);
                [ig_qc0_m,ig_dc0_m] = rotation_vect(real(Ig)*sqrt(3), -imag(Ig)*sqrt(3), theta_in_filt);
                initVSC.ig_qc0_m = ig_qc0_m;
                initVSC.ig_dc0_m = ig_dc0_m;
        
                % PLL 
                initVSC.thetaPLL_init = delta0 + theta_in -pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!
                phase_solver = -2*pi*50*1e-5/2;
                initVSC.thetaPLL_init_filts = delta0 + theta_in + phase_btwf+phase_zoh -pi/2;
                % Udiff converter voltage in abc, REF:GLOBAL
        
                initVSC.Vg_mag = abs(Vg)*sqrt(2);
                initVSC.angle_vg = delta0;
                initVSC.Vga = initVSC.Vg_mag*sin(delta0);
                initVSC.Vgb = initVSC.Vg_mag*sin(delta0 -2/pi*3);
                initVSC.Vgc = initVSC.Vg_mag*sin(delta0 +2/pi*3);

                Udiff_mag = sqrt(vc_q0^2+vc_d0^2);
                initVSC.Udiff_mag   = Udiff_mag*1;
                initVSC.angle_vdiff = (delta_bus  + theta_vc);

                initVSC.Udiff_a = Udiff_mag*sin(delta_bus + theta_vc);
                initVSC.Udiff_b = Udiff_mag*sin(delta_bus + theta_vc -2*pi/3);
                initVSC.Udiff_c = Udiff_mag*sin(delta_bus + theta_vc +2*pi/3);

                initVSC.Udiff_a_delay = Udiff_mag*sin(delta_bus + theta_vc);
                initVSC.Udiff_b_delay = Udiff_mag*sin(delta_bus + theta_vc -2*pi/3);
                initVSC.Udiff_c_delay = Udiff_mag*sin(delta_bus + theta_vc +2*pi/3);


                initVSC.Ua = initVSC.U_mag*sin(initVSC.angle_umag);
                initVSC.Ub = initVSC.U_mag*sin(initVSC.angle_umag -2*pi/3);
                initVSC.Uc = initVSC.U_mag*sin(initVSC.angle_umag +2*pi/3);

                initVSC.vc_q0 = vc_d0;
                initVSC.vc_d0 = vc_q0;

                initVSC.vg_qc0 = vg_qc0;
                initVSC.vg_dc0 = vg_dc0;

                initVSC.vg_qc0_p = vg_qc0_p;
                initVSC.vg_dc0_p = vg_dc0_p;

                initVSC.vdiffd = vc_dc0;
                initVSC.vdiffq = vc_qc0;
        
                % Is (=Idiff) converter current in abc, REF:GLOBAL
        
                Is_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Sbpu_l2g(vsc);

                initVSC.Is_mag = Is_mag;
                initVSC.angle_is = delta_bus+phi_is;
        
                Isa_VSC = Is_mag*sin(delta_bus + phi_is);
                Isb_VSC = Is_mag*sin(delta_bus + phi_is -2*pi/3);
                Isc_VSC = Is_mag*sin(delta_bus + phi_is +2*pi/3);
        
                initVSC.Isa = Isa_VSC;
                initVSC.Isb = Isb_VSC;
                initVSC.Isc = Isc_VSC;  
        
                % Is (=Idiff) converter current in qd, REF: LOCAL
        
                initVSC.idiffd = is_dc0;
                initVSC.idiffq = is_qc0;     
                initVSC.idiffdc_p = is_dc0_p;
                initVSC.idiffqc_p = is_qc0_p;   
        
                % Ig transformer current in abc, REF:GLOBAL
        
%               Ig_mag = sqrt(is_q0^2+is_d0^2)*T_VSC.Ibpu_l2g(vsc);
%         
%               Iga = Ig_mag*sin(delta_bus + phi_is);
%               Igb = Ig_mag*sin(delta_bus + phi_is -2*pi/3);
%               Igc = Ig_mag*sin(delta_bus + phi_is +2*pi/3);
%         
%               initVSC.Iga = Iga;
%               initVSC.Igb = Igb;
%               initVSC.Igc = Igc;  
        
                Ig_mag = sqrt(ig_q0^2+ig_d0^2)*T_VSC.Sbpu_l2g(vsc);

                initVSC.Ig_mag = Ig_mag;
                initVSC.angle_ig = delta_bus+phi;
        
                Iga = Ig_mag*sin(delta_bus + phi);
                Igb = Ig_mag*sin(delta_bus + phi -2*pi/3);
                Igc = Ig_mag*sin(delta_bus + phi +2*pi/3);
        
                initVSC.Iga = Iga;
                initVSC.Igb = Igb;
                initVSC.Igc = Igc;  

                % U converter-POC voltage in abc, REF:LOCAL
        
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;

                initVSC.udc_p = u_dc0_p;
                initVSC.uqc_p = u_qc0_p;

                % Ig NET-POC current, REF:LOCAL        
                initVSC.igd = ig_dc0;
                initVSC.igq = ig_qc0;

                initVSC.igdc_p = ig_dc0_p;
                initVSC.igqc_p = ig_qc0_p;
                
                % Differential current loops 
                Udiff_q = vc_qc0;
                Udiff_d = vc_dc0;

                initVSC.udiffqc_p = vc_qc0_p;
                initVSC.udiffdc_p = vc_dc0_p;

                initVSC.PI_idiffq =  vc_qc0_m - initVSC.vg_qc0_p - Xc*is_dc0_p -Rc*Xc*is_qc0_p - (ig_qc0_p-is_qc0_p)*cc_damp;
                initVSC.PI_idiffd =  vc_dc0_m - initVSC.vg_dc0_p  + Xc*is_qc0_p -Rc*Xc*is_dc0_p - (ig_dc0_p-is_dc0_p)*cc_damp;
                initVSC.PI_idiff0 = 0;
        
                %Voltage controller, REF:LOCAL
                initVSC.PI_V = initVSC.is_dc0_m;
                initVSC.ud = u_dc0;
                initVSC.uq = u_qc0;       

                initVSC.Pdc = (3/2*vc_q0*is_q0 + 3/2*vc_d0*is_d0)*T_VSC.Sbpu_l2g(vsc);
                initVSC.idc = initVSC.Pdc/2;
        
                % RL filter
                initVSC.Rtr = T_VSC.Rtr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Ltr = T_VSC.Ltr(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rc = T_VSC.Rc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Lc = T_VSC.Lc(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Rac = T_VSC.Rac(vsc)/T_VSC.Sbpu_l2g(vsc);
                initVSC.Cac = T_VSC.Cac(vsc)*T_VSC.Sbpu_l2g(vsc); 

                % Capacitor initial voltages, REF:GLOBAL
                Ucap_mag = sqrt(ucap_q0^2+ucap_d0^2)*1;
        
                initVSC.Ucap_mag = Ucap_mag;
                initVSC.angle_ucap = delta_bus+theta_ucap;

                initVSC.Ucap_a = Ucap_mag*sin(delta_bus + theta_ucap);
                initVSC.Ucap_b = Ucap_mag*sin(delta_bus + theta_ucap -2*pi/3);
                initVSC.Ucap_c = Ucap_mag*sin(delta_bus + theta_ucap +2*pi/3);

                % PQ references
                %Scap = 3*U*conj(Is); %no capacitor
                Scap = 3*U*conj(Ig);
                initVSC.Pref = real(Scap);
                initVSC.Qref = imag(Scap);             
               
        end     


        init_VSC{vsc} = initVSC;
        
    end
end
