function [T_shunt] =  generate_parameters_SHUNT(T_shunt,T_global,excel_data_shunt) 
    
     if isfile(['01_data\cases\' excel_data_shunt])
        
        for shunt_element = 1:1:height(T_shunt)
    
            num = T_shunt.number(shunt_element);
    
        % System pu base is RMS-LL
            Sb_sys = T_global.Sb(T_global.Area == T_shunt.Area(shunt_element)); %Sb system, in VA
            Vb_sys = T_global.Vb(T_global.Area == T_shunt.Area(shunt_element)); %Vb system, in V
            fb_sys = T_global.fb(T_global.Area == T_shunt.Area(shunt_element)); %fb, in Hz
            Ib_sys = Sb_sys/Vb_sys;
            Zb_sys = Vb_sys/Ib_sys;
    
        % Compute pu RMS-LL base values
            T_shunt.Sb(shunt_element)     = T_shunt.Sn(shunt_element)*1e6; %Sb machine, in VA
            T_shunt.Vn(shunt_element)     = T_shunt.Vn(shunt_element)*1e3; % rated RMS-LL, in V
            T_shunt.Vb(shunt_element)     = T_shunt.Vn(shunt_element); % voltage base (RMS, LL), in V
            T_shunt.Ib(shunt_element)     = T_shunt.Sb(shunt_element)/T_shunt.Vb(shunt_element); % current base (RMS, phase current), in A
            T_shunt.Zb(shunt_element)     = T_shunt.Vn(shunt_element).^2./T_shunt.Sb(shunt_element); % impedance base, in ohm
            T_shunt.wb(shunt_element)     = 2*pi*fb_sys;
            T_shunt.Lb(shunt_element)     = T_shunt.Zb(shunt_element)/T_shunt.wb(shunt_element); % impedance base, in ohm
            T_shunt.fb(shunt_element)     = fb_sys;
    
        % pu base conversions to system base
            % from local 2 global: device --> system
            T_shunt.Sbpu_l2g(shunt_element) = T_shunt.Sb(shunt_element)/Sb_sys;
            T_shunt.Vbpu_l2g(shunt_element) = T_shunt.Vb(shunt_element)/Vb_sys;
            T_shunt.Ibpu_l2g(shunt_element) = T_shunt.Ib(shunt_element)/Ib_sys; 
            T_shunt.Zbpu_l2g(shunt_element) = T_shunt.Zb(shunt_element)/Zb_sys; 
                  
            % Shunt parameters  
            type = T_shunt.type{shunt_element};
            T_data = readtable(excel_data_shunt,'Sheet',type); % read table
            T_data = T_data(T_data.number == num,:); % select row
            T_data = removevars(T_data,{'number','bus'}); % get parameters columns
        
            switch type
    
                case 'RLC'
                  T_shunt.R(shunt_element) = T_data.R;
                  T_shunt.L(shunt_element) = T_data.L;
                  T_shunt.C(shunt_element) = T_data.C;

                case 'C-type'
                  T_shunt.C1(shunt_element) = T_data.C1;
                  T_shunt.L(shunt_element) = T_data.L;
                  T_shunt.C2(shunt_element) = T_data.C2;
                  T_shunt.R(shunt_element) = T_data.R;

                %case 'C'

                    
            end
        
        end
     end
end
