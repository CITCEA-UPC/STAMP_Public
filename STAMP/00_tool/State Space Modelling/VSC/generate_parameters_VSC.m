function [T_VSC] =  generate_parameters_VSC(T_VSC,T_global,excel_data_vsc) 
    
     if isfile(['01_data\cases\' excel_data_vsc])
        
        for vsc = 1:1:height(T_VSC)
    
            num = T_VSC.number(vsc);
    
        % System pu base is RMS-LL
            Sb_sys = T_global.Sb(T_global.Area == T_VSC.Area(vsc)); %Sb system, in VA
            Vb_sys = T_global.Vb(T_global.Area == T_VSC.Area(vsc)); %Vb system, in V
            fb_sys = T_global.fb(T_global.Area == T_VSC.Area(vsc)); %fb, in Hz
            Ib_sys = Sb_sys/Vb_sys;
            Zb_sys = Vb_sys/Ib_sys;
    
        % Compute pu RMS-LL base values
            T_VSC.Sb(vsc)     = T_VSC.Sn(vsc)*1e6; %Sb machine, in VA
            T_VSC.Vn(vsc)     = T_VSC.Vn(vsc)*1e3; % rated RMS-LL, in V
            T_VSC.Vb(vsc)     = T_VSC.Vn(vsc); % voltage base (RMS, LL), in V
            T_VSC.Ib(vsc)     = T_VSC.Sb(vsc)/T_VSC.Vb(vsc); % current base (RMS, phase current), in A
            T_VSC.Zb(vsc)     = T_VSC.Vn(vsc).^2./T_VSC.Sb(vsc); % impedance base, in ohm
            T_VSC.wb(vsc)     = 2*pi*fb_sys;
            T_VSC.Lb(vsc)     = T_VSC.Zb(vsc)/T_VSC.wb(vsc); % impedance base, in ohm
            T_VSC.fb(vsc)     = fb_sys;
    
        % pu base conversions to system base
            % from local 2 global: SG --> system
            T_VSC.Sbpu_l2g(vsc) = T_VSC.Sb(vsc)/Sb_sys;
            T_VSC.Vbpu_l2g(vsc) = T_VSC.Vb(vsc)/Vb_sys;
            T_VSC.Ibpu_l2g(vsc) = T_VSC.Ib(vsc)/Ib_sys; 
            T_VSC.Zbpu_l2g(vsc) = T_VSC.Zb(vsc)/Zb_sys; 
                  
            % VSC parameters  
            mode = T_VSC.mode{vsc};
            T_data = readtable(excel_data_vsc,'Sheet',mode); % read table
            T_data = T_data(T_data.number == num,:); % select row
            T_data = removevars(T_data,{'number','bus'}); % get parameters columns
        
            switch mode
    
                case 'GFOL'
                % Transformer
                    T_VSC.Rtr(vsc) = T_data.Rtr;
                    T_VSC.Xtr(vsc) = T_data.Xtr;
                    T_VSC.Ltr(vsc) = T_VSC.Xtr(vsc)/T_VSC.wb(vsc);
                % RL filter
                    T_VSC.Rc(vsc) = T_data.Rc;
                    T_VSC.Xc(vsc) = T_data.Xc;
                    T_VSC.Lc(vsc) = T_VSC.Xc(vsc)/T_VSC.wb(vsc);
                    T_VSC.Cac(vsc) = T_data.Bac/T_VSC.wb(vsc); % Converter grid coupling filter capacitance
                    %T_VSC.wres(vsc) = sqrt( (T_VSC.Ltr(vsc) + T_VSC.Lc(vsc) ) / (T_VSC.Ltr(vsc)*T_VSC.Lc(vsc)*T_VSC.Cac(vsc) ) ); Passive filter resonance frequency
                    %T_VSC.Rac(vsc) = 1/(3*T_VSC.wres(vsc)*T_VSC.Cac(vsc)); % passive damping 
                    T_VSC.Rac(vsc) = T_data.Rac;
                % Currrent control
                    T_VSC.taus(vsc) = T_data.tau_s;
                    T_VSC.kp_s(vsc) = T_VSC.Lc(vsc)/T_VSC.taus(vsc);
                    T_VSC.ki_s(vsc) = T_VSC.Rc(vsc)/T_VSC.taus(vsc);
                % PLL
                    T_VSC.ts_pll(vsc) = T_data.ts_pll;
                    T_VSC.xi_pll(vsc) = T_data.xi_pll;
                    T_VSC.omega_pll(vsc) = 4/(T_VSC.ts_pll(vsc)*T_VSC.xi_pll(vsc));
                    T_VSC.tau_pll(vsc) = 2*T_VSC.xi_pll(vsc)/T_VSC.omega_pll(vsc);
                    T_VSC.kp_pll(vsc) = 2*T_VSC.omega_pll(vsc)*T_VSC.xi_pll(vsc);
                    T_VSC.ki_pll(vsc) = T_VSC.kp_pll(vsc)/T_VSC.tau_pll(vsc);
                % Power loops
                    T_VSC.tau_p(vsc) = T_data.tau_p;
                    T_VSC.kp_P(vsc)  = T_VSC.taus(vsc)/T_VSC.tau_p(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.ki_P(vsc)  = 1/T_VSC.tau_p(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.tau_q(vsc) = T_data.tau_q;
                    T_VSC.kp_Q(vsc)  = T_VSC.taus(vsc)/T_VSC.tau_q(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.ki_Q(vsc)  = 1/T_VSC.tau_q(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.tau_droop_f(vsc) = T_data.tau_droop_f;
                    T_VSC.k_droop_f(vsc)   = T_data.k_droop_f;
                    T_VSC.tau_droop_u(vsc) = T_data.tau_droop_u;
                    T_VSC.k_droop_u(vsc)   = T_data.k_droop_u;
                % POD
                    T_VSC.POD(vsc) = {'No'};
                % Measurement delay
                    T_VSC.tau_md(vsc)   = T_data.tau_md;
                % Commutation delay
                    T_VSC.tau_cmd(vsc)   = T_data.tau_cmd;
                % ZOH delay
                    T_VSC.tau_zoh(vsc)   = T_data.tau_zoh;
    
                case 'GFOR'
    
                % Transformer
                    T_VSC.Rtr(vsc) = T_data.Rtr;
                    T_VSC.Xtr(vsc) = T_data.Xtr;
                    T_VSC.Ltr(vsc) = T_VSC.Xtr(vsc)/T_VSC.wb(vsc);
                % RLC filter
                    T_VSC.Rc(vsc) = T_data.Rc;
                    T_VSC.Xc(vsc) = T_data.Xc;
                    T_VSC.Lc(vsc) = T_VSC.Xc(vsc)/T_VSC.wb(vsc);
                    T_VSC.Cac(vsc) = T_data.Bac/T_VSC.wb(vsc); % Converter grid coupling filter capacitance
                    %T_VSC.Rac(vsc) = 1/(3*10*T_VSC.wb(vsc)*T_VSC.Cac(vsc)); % passive damping
                    T_VSC.Rac(vsc) = T_data.Rac;
                % Currrent control
                    T_VSC.taus(vsc) = T_data.tau_s;
                    T_VSC.kp_s(vsc) = T_VSC.Lc(vsc)/T_VSC.taus(vsc);
                    T_VSC.ki_s(vsc) = T_VSC.Rc(vsc)/T_VSC.taus(vsc);
                % AC voltage control
                    T_VSC.set_time_v(vsc) = T_data.set_time_v; % in s
                    T_VSC.xi_v(vsc)   = T_data.xi_v;
                    T_VSC.wn_v(vsc)   = 4/(T_VSC.set_time_v(vsc)*T_VSC.xi_v(vsc));
                    T_VSC.kp_vac(vsc) = 2*T_VSC.xi_v(vsc)*T_VSC.wn_v(vsc)*T_VSC.Cac(vsc)*100;
                    T_VSC.ki_vac(vsc) = T_VSC.wn_v(vsc)^2*T_VSC.Cac(vsc);
                % Feedforward filters
                    T_VSC.tau_u(vsc) = T_data.tau_u; 
                    T_VSC.tau_ig(vsc) = T_data.tau_ig;
                % Droop parameters
                    T_VSC.tau_droop_f(vsc) = T_data.tau_droop_f;
                    T_VSC.k_droop_f(vsc)   = T_data.k_droop_f;
                    T_VSC.tau_droop_u(vsc) = T_data.tau_droop_u;
                    T_VSC.k_droop_u(vsc)   = T_data.k_droop_u;
                % POD
                    T_VSC.POD(vsc) = {'No'};
                % Measurement delay
                    T_VSC.tau_md(vsc)   = T_data.tau_md;
                % Commutation delay
                    T_VSC.tau_cmd(vsc)   = T_data.tau_cmd;
                % ZOH delay
                    T_VSC.tau_zoh(vsc)   = T_data.tau_zoh;
        
                case 'STATCOM'
                    % Transformer
                    T_VSC.Rtr(vsc) = T_data.Rtr;
                    T_VSC.Xtr(vsc) = T_data.Xtr;
                    T_VSC.Ltr(vsc) = T_VSC.Xtr(vsc)/T_VSC.wb(vsc);
                % RL filter
                    T_VSC.Rc(vsc) = T_data.Rc;
                    T_VSC.Xc(vsc) = T_data.Xc;
                    T_VSC.Lc(vsc) = T_VSC.Xc(vsc)/T_VSC.wb(vsc);
                    T_VSC.Cac(vsc) = T_data.Bac/T_VSC.wb(vsc); % Converter grid coupling filter capacitance
                    %T_VSC.Rac(vsc) = 1/(3*10*T_VSC.wb(vsc)*T_VSC.Cac(vsc)); % passive damping 
                    T_VSC.Rac(vsc) = T_data.Rac;
                % Currrent control
                    T_VSC.taus(vsc) = T_data.tau_s;
                    T_VSC.kp_s(vsc) = T_VSC.Lc(vsc)/T_VSC.taus(vsc);
                    T_VSC.ki_s(vsc) = T_VSC.Rc(vsc)/T_VSC.taus(vsc);
                % PLL
                    T_VSC.ts_pll(vsc) = T_data.ts_pll;
                    T_VSC.xi_pll(vsc) = T_data.xi_pll;
                    T_VSC.omega_pll(vsc) = 4/(T_VSC.ts_pll(vsc)*T_VSC.xi_pll(vsc));
                    T_VSC.tau_pll(vsc) = 2*T_VSC.xi_pll(vsc)/T_VSC.omega_pll(vsc);
                    T_VSC.kp_pll(vsc) = 2*T_VSC.omega_pll(vsc)*T_VSC.xi_pll(vsc);
                    T_VSC.ki_pll(vsc) = T_VSC.kp_pll(vsc)/T_VSC.tau_pll(vsc);
                % Power loops
                    T_VSC.tau_p(vsc) = T_data.tau_p;
                    T_VSC.kp_P(vsc)  = T_VSC.taus(vsc)/T_VSC.tau_p(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.ki_P(vsc)  = 1/T_VSC.tau_p(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.tau_q(vsc) = T_data.tau_q;
                    T_VSC.kp_Q(vsc)  = T_VSC.taus(vsc)/T_VSC.tau_q(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.ki_Q(vsc)  = 1/T_VSC.tau_q(vsc)*(T_VSC.Sb(vsc)/T_VSC.Ib(vsc)/1000);
                    T_VSC.tau_droop_f(vsc) = T_data.tau_droop_f;
                    T_VSC.k_droop_f(vsc)   = T_data.k_droop_f;
                    T_VSC.tau_droop_u(vsc) = T_data.tau_droop_u;
                    T_VSC.k_droop_u(vsc)   = T_data.k_droop_u;
                % Vdc control
                    T_VSC.Ceq(vsc) = T_data.Ceq;
                    T_VSC.kpVdc(vsc) = T_data.kpVdc;
                    T_VSC.kiVdc(vsc) = T_data.kiVdc;
                % POD
                    T_VSC.POD(vsc) = T_data.POD;
                    T_VSC.T(vsc) = T_data.T;
                    T_VSC.TLPF(vsc) = T_data.TLPF;
                    T_VSC.T1(vsc) = T_data.T1;
                    T_VSC.T2(vsc) = T_data.T2;
                % Measurement delay
                    T_VSC.tau_md(vsc)   = T_data.tau_md;
                % Commutation delay
                    T_VSC.tau_cmd(vsc)   = T_data.tau_cmd;
                % ZOH delay
                    T_VSC.tau_zoh(vsc)   = T_data.tau_zoh;
                    
                case 'WT'
                    % Transformer
                    T_VSC.Rtr(vsc) = T_data.Rtr;
                    T_VSC.Xtr(vsc) = T_data.Xtr;
                    T_VSC.Ltr(vsc) = T_VSC.Xtr(vsc)/T_VSC.wb(vsc);
                % RL filter
                    T_VSC.Rc(vsc) = T_data.Rc;
                    T_VSC.Xc(vsc) = T_data.Xc;
                    T_VSC.Lc(vsc) = T_VSC.Xc(vsc)/T_VSC.wb(vsc);
                    T_VSC.Cac(vsc) = T_data.Bac/T_VSC.wb(vsc); % Converter grid coupling filter capacitance
                    T_VSC.Rac(vsc) = T_data.Rac;
                % Currrent control
                    T_VSC.kp_s(vsc) = T_data.kp_s;
                    T_VSC.ki_s(vsc) = T_data.ki_s;
                    T_VSC.cc_damp(vsc) = T_data.cc_damp;
                % PLL
                    T_VSC.tau_pll(vsc) = T_data.tau_pll;
                    T_VSC.kp_pll(vsc) = T_data.kp_pll;
                    T_VSC.ki_pll(vsc) = T_data.ki_pll;
                % Power loops
                    T_VSC.kp_Q(vsc)  = T_data.kp_Q;
                    T_VSC.ki_Q(vsc)  =  T_data.ki_Q;
                    T_VSC.tau_droop_u(vsc) = T_data.tau_droop_u;
                    T_VSC.k_droop_u(vsc)   = T_data.k_droop_u;
                % Vdc control
                    T_VSC.Ceq(vsc) = T_data.Ceq;
                    T_VSC.kpVdc(vsc) = T_data.kpVdc;
                    T_VSC.kiVdc(vsc) = T_data.kiVdc;
                  % Measurement delay
                    T_VSC.fc(vsc)   = T_data.fc;
                % Commutation delay
                    T_VSC.tau_cmd(vsc)   = T_data.tau_cmd;
                % ZOH delay
                    T_VSC.tau_zoh(vsc)   = T_data.tau_zoh;
                    
            end
        
        end
     end
end
