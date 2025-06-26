function [T_IPC] =  generate_parameters_IPC(T_IPC,T_global,excel_data_ipc) 
    
     if isfile(['01_data\cases\' excel_data_ipc])
        
        for vsc = 1:1:height(T_IPC)
    
            num = T_IPC.number(vsc);
    
        % System pu base is RMS-LL
            Sb_sys = T_global.Sb(T_global.Area == T_IPC.Area(vsc)); %Sb system, in VA
            Vb_sys = T_global.Vb(T_global.Area == T_IPC.Area(vsc)); %Vb system, in V
            fb_sys = T_global.fb(T_global.Area == T_IPC.Area(vsc)); %fb, in Hz
            Ib_sys = Sb_sys/Vb_sys;
            Zb_sys = Vb_sys/Ib_sys;
    
        % Compute pu RMS-LL base values
            T_IPC.Sb(vsc)     = T_IPC.Sn(vsc)*1e6; %Sb machine, in VA
            T_IPC.Vn(vsc)     = T_IPC.Vn(vsc)*1e3; % rated RMS-LL, in V
            T_IPC.Vb(vsc)     = T_IPC.Vn(vsc); % voltage base (RMS, LL), in V
            T_IPC.Vdcb(vsc)   = T_IPC.Vdcn(vsc); % voltage base (RMS, LL), in V
            T_IPC.Ib(vsc)     = T_IPC.Sb(vsc)/T_IPC.Vb(vsc); % current base (RMS, phase current), in A
            T_IPC.Zb(vsc)     = T_IPC.Vn(vsc).^2./T_IPC.Sb(vsc); % impedance base, in ohm
            T_IPC.wb(vsc)     = 2*pi*fb_sys;
            T_IPC.Lb(vsc)     = T_IPC.Zb(vsc)/T_IPC.wb(vsc); % impedance base, in ohm
            T_IPC.fb(vsc)     = fb_sys;
    
        % pu base conversions to system base
            % from local 2 global: SG --> system
            T_IPC.Sbpu_l2g(vsc) = T_IPC.Sb(vsc)/Sb_sys;
            T_IPC.Vbpu_l2g(vsc) = T_IPC.Vb(vsc)/Vb_sys;
            T_IPC.Ibpu_l2g(vsc) = T_IPC.Ib(vsc)/Ib_sys; 
            T_IPC.Zbpu_l2g(vsc) = T_IPC.Zb(vsc)/Zb_sys; 
                  
            % VSC parameters  
            mode = T_IPC.mode{vsc};
            T_data = readtable(excel_data_ipc,'Sheet',mode); % read table
            T_data = T_data(T_data.number == num,:); % select row
            T_data = removevars(T_data,{'number','bus'}); % get parameters columns
        
            switch mode
    
                case 'AC-GFOL_DC-GFOL'
                % Transformer
                    T_IPC.Rc(vsc) = T_data.Rc;
                    T_IPC.Xc(vsc) = T_data.Xc;
                    T_IPC.Lc(vsc) = T_IPC.Xc(vsc)/T_IPC.wb(vsc);
                % RL inside IPC
                    T_IPC.Ra(vsc) = T_data.Ra;
                    T_IPC.Xa(vsc) = T_data.Xa;
                    T_IPC.La(vsc) = T_IPC.Xa(vsc)/T_IPC.wb(vsc);
                % Carm inside IPC
                    T_IPC.Carm(vsc) = T_data.Carm;
                % Grid Currrent control
                    T_IPC.kpIs(vsc) = T_data.kpIs;
                    T_IPC.kiIs(vsc) = T_data.kiIs;
                % Inner Currrent control
                    T_IPC.kpIsum(vsc) = T_data.kpIsum;
                    T_IPC.kiIsum(vsc) = T_data.kiIsum;
                % PLL                     
                    T_IPC.kpPLL(vsc) = T_data.kpPLL;
                    T_IPC.kiPLL(vsc) = T_data.kiPLL;
                    T_IPC.kpw(vsc) = T_data.kpw;
                    T_IPC.tw(vsc) = T_data.tw;
                % Energy control
                    T_IPC.kpEt(vsc) = T_data.kpEt;
                    T_IPC.kiEt(vsc) = T_data.kiEt;
                % Power loops
                    T_IPC.kpPac(vsc) = T_data.kpPac;
                    T_IPC.kiPac(vsc) = T_data.kiPac;
                    T_IPC.tPac(vsc) = T_data.tPac;
                    T_IPC.kpQ(vsc) = T_data.kpQ;
                    T_IPC.kiQ(vsc) = T_data.kiQ;
                    T_IPC.tQ(vsc) = T_data.tQ;
                    T_IPC.kpVac(vsc) = T_data.kpVac;
                    T_IPC.tVac(vsc) = T_data.tVac;
                % Measurement delay
                    T_IPC.delay(vsc) = T_data.delay;
                % Control delay
                    T_IPC.tau_cmd(vsc) = T_data.tau_cmd;
                % ZOH delay
                    T_IPC.tau_zoh(vsc) = T_data.tau_zoh;
   
                case 'AC-GFOL_DC-GFOR'
    
                % Transformer
                    T_IPC.Rc(vsc) = T_data.Rc;
                    T_IPC.Xc(vsc) = T_data.Xc;
                    T_IPC.Lc(vsc) = T_IPC.Xc(vsc)/T_IPC.wb(vsc);
                % RL inside IPC
                    T_IPC.Ra(vsc) = T_data.Ra;
                    T_IPC.Xa(vsc) = T_data.Xa;
                    T_IPC.La(vsc) = T_IPC.Xa(vsc)/T_IPC.wb(vsc);
                % Carm inside IPC
                    T_IPC.Carm(vsc) = T_data.Carm;
                % Grid Currrent control
                    T_IPC.kpIs(vsc) = T_data.kpIs;
                    T_IPC.kiIs(vsc) = T_data.kiIs;
                % Inner Currrent control
                    T_IPC.kpIsum(vsc) = T_data.kpIsum;
                    T_IPC.kiIsum(vsc) = T_data.kiIsum;
                % PLL                     
                    T_IPC.kpPLL(vsc) = T_data.kpPLL;
                    T_IPC.kiPLL(vsc) = T_data.kiPLL;
                    T_IPC.kpw(vsc) = T_data.kpw;
                    T_IPC.tw(vsc) = T_data.tw;
                % Energy control
                    T_IPC.kpEt(vsc) = T_data.kpEt;
                    T_IPC.kiEt(vsc) = T_data.kiEt;
                % DC voltage loops
                    T_IPC.kpPac(vsc) = T_data.kpPac;
                    T_IPC.kiPac(vsc) = T_data.kiPac;
                    T_IPC.kpVdc(vsc) = T_data.kpVdc;
                    T_IPC.kiVdc(vsc) = T_data.kiVdc;
                % Reactive Power loops
                    T_IPC.kpQ(vsc) = T_data.kpQ;
                    T_IPC.kiQ(vsc) = T_data.kiQ;
                    T_IPC.tQ(vsc) = T_data.tQ;
                    T_IPC.kpVac(vsc) = T_data.kpVac;
                    T_IPC.tVac(vsc) = T_data.tVac;
                % Measurement delay
                    T_IPC.delay(vsc) = T_data.delay;
                % Control delay
                    T_IPC.tau_cmd(vsc) = T_data.tau_cmd;
                % ZOH delay
                    T_IPC.tau_zoh(vsc) = T_data.tau_zoh;
                    
                case 'AC-GFOR_DC-GFOL'
                % Transformer
                    T_IPC.Rc(vsc) = T_data.Rc;
                    T_IPC.Xc(vsc) = T_data.Xc;
                    T_IPC.Lc(vsc) = T_IPC.Xc(vsc)/T_IPC.wb(vsc);
                % RL inside IPC
                    T_IPC.Ra(vsc) = T_data.Ra;
                    T_IPC.Xa(vsc) = T_data.Xa;
                    T_IPC.La(vsc) = T_IPC.Xa(vsc)/T_IPC.wb(vsc);
                % Carm inside IPC
                    T_IPC.Carm(vsc) = T_data.Carm;
                % Grid Currrent control
                    T_IPC.kpIs(vsc) = T_data.kpIs;
                    T_IPC.kiIs(vsc) = T_data.kiIs;
                % Inner Currrent control
                    T_IPC.kpIsum(vsc) = T_data.kpIsum;
                    T_IPC.kiIsum(vsc) = T_data.kiIsum;
                % Energy control
                    T_IPC.kpEt(vsc) = T_data.kpEt;
                    T_IPC.kiEt(vsc) = T_data.kiEt;
                % Outer loops
                    T_IPC.kpVac(vsc) = T_data.kpVac;
                    T_IPC.kiVac(vsc) = T_data.kiVac;
                    T_IPC.Cac(vsc)   = T_data.Cac;
                    T_IPC.kpQ(vsc) = T_data.kpQ;
                    T_IPC.kiQ(vsc) = T_data.kiQ;
                    T_IPC.tQ(vsc) = T_data.tQ;
                    T_IPC.tVac(vsc) = T_data.tVac;
                    T_IPC.kf(vsc)  = T_data.kf;
                    T_IPC.tPac(vsc) = T_data.tPac;
                % Measurement delay
                    T_IPC.delay(vsc) = T_data.delay;
                % Control delay
                    T_IPC.tau_cmd(vsc) = T_data.tau_cmd;
                % ZOH delay
                    T_IPC.tau_zoh(vsc) = T_data.tau_zoh;
            end
        
        end
     end
end
