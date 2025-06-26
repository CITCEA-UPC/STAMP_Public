function [T_SG] =  generate_parameters_SG(T_SG,T_global,excel_data_sg) 

    if isfile(['01_data\cases\' excel_data_sg])

        types = sheetnames(excel_data_sg);
     
        for sg = 1:1:height(T_SG)
    
            num = T_SG.number(sg);
    
        % System pu base is RMS-LL
            Sb_sys = T_global.Sb(T_global.Area == T_SG.Area(sg)); %Sb system, in VA
            Vb_sys = T_global.Vb(T_global.Area == T_SG.Area(sg)); %Vb system, in V
            fb_sys = T_global.fb(T_global.Area == T_SG.Area(sg)); %fb, in Hz
            Ib_sys = Sb_sys/Vb_sys;
            Zb_sys = Vb_sys/Ib_sys;
    
        % Compute pu peak-FN base values
            T_SG.Sb(sg)     = T_SG.Sn(sg)*1e6; %Sb machine, in VA
            T_SG.Vn(sg)     = T_SG.Vn(sg)*1e3; % rated RMS-LL, in V
            T_SG.Vb(sg)     = T_SG.Vn(sg)*sqrt(2/3); % voltage base (peak, FN), in V
            T_SG.Ib(sg)     = (2/3)*T_SG.Sb(sg)/T_SG.Vb(sg); % current base (peak, phase current), in A
            T_SG.Zb(sg)     = T_SG.Vn(sg).^2./T_SG.Sb(sg); % impedance base, in ohm
            T_SG.wb(sg)     = 2*pi*fb_sys;
            T_SG.Lb(sg)     = T_SG.Zb(sg)/T_SG.wb(sg); % impedance base, in ohm
            T_SG.fb(sg)     = fb_sys;
            T_SG.Lb(sg)     = T_SG.Zb(sg)/T_SG.wb(sg);
    
        % pu base conversions to system base
            % from local 2 global: SG --> system
            T_SG.Sbpu_l2g(sg) = T_SG.Sb(sg)/Sb_sys;
            T_SG.Vbpu_l2g(sg) = T_SG.Vb(sg)/Vb_sys;
            T_SG.Ibpu_l2g(sg) = T_SG.Ib(sg)/Ib_sys; %T_SG.Sb(sg)/Sb_sys*sqrt(2/3); 
            T_SG.Zbpu_l2g(sg) = T_SG.Zb(sg)/Zb_sys; %Sb_sys/T_SG.Sb(sg);
              
        % SG electrical parameters      
            Xl          = T_SG.Xl(sg);
            Xd          = T_SG.Xd(sg);
            Xd_tr       = T_SG.Xd_tr(sg);
            Xd_subtr    = T_SG.Xd_subtr(sg);
            Xq          = T_SG.Xq(sg);
            Xq_tr       = T_SG.Xq_tr(sg);
            Xq_subtr    = T_SG.Xq_subtr(sg);
            Tdo_tr      = T_SG.Tdo_tr(sg);
            Tdo_subtr   = T_SG.Tdo_subtr(sg);
            Tqo_tr      = T_SG.Tqo_tr(sg);
            Tqo_subtr   = T_SG.Tqo_subtr(sg);
           
    %         Lfd_pu = (Lmd_pu*(Xd_tr-Xl))/(Lmd_pu-Xd_tr+Xl);
    %         L1q_pu = (Lmq_pu*(Xq_tr-Xl))/(Lmq_pu-Xq_tr+Xl);
    % 
    %         L1d_pu = (Xd_subtr-Xl)*(Lmd_pu*Lfd_pu)/(Lmd_pu*Lfd_pu-(Lfd_pu+Lmd_pu)*(Xd_subtr-Xl));
    %         L2q_pu = (Xq_subtr-Xl)*(Lmq_pu*L1q_pu)/(Lmq_pu*L1q_pu-(L1q_pu+Lmq_pu)*(Xq_subtr-Xl));
    % 
    %         Rf_pu = (Lmd_pu+Lfd_pu)/(Tdo_tr*wb);
    %         R1d_pu = 1/(Tdo_subtr*wb)*(L1d_pu+Lmd_pu*Lfd_pu/(Lmd_pu+Lfd_pu));
    % 
    %         R1q_pu = (Lmq_pu+L1q_pu)/(Tqo_tr*wb);
    %         R2q_pu = 1/(Tqo_subtr*wb)*(L2q_pu+Lmq_pu*L1q_pu/(Lmq_pu+L1q_pu));
    
        Xmd = Xd - Xl; 
        Xmq = Xq - Xl; 
    
        %d axis
        Td_tr = Tdo_tr*Xd_tr/Xd;
        Td_subtr = Tdo_subtr*Xd_subtr/Xd_tr;
        
        Ld = Xd*T_SG.Lb(sg);
        Lmd = Xmd*T_SG.Lb(sg);
        Ll = Xl*T_SG.Lb(sg);
        
        A = Lmd^2/(Ld*(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr));
        a = (Ld*(Td_tr+Td_subtr)-Ll*(Tdo_tr+Tdo_subtr))/Lmd;
        b = (Ld*Td_tr*Td_subtr-Ll*Tdo_tr*Tdo_subtr)/Lmd;
        c = (Tdo_tr*Tdo_subtr-Td_tr*Td_subtr)/(Tdo_tr+Tdo_subtr-Td_tr-Td_subtr);
        
        ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
        La = ra*(a+sqrt(a^2-4*b))/2;
        rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
        Lb = rb*(a-sqrt(a^2-4*b))/2;
        
        Rf_pu = ra/T_SG.Zb(sg);
        Lfd_pu = La/T_SG.Lb(sg);
        R1d_pu = rb/T_SG.Zb(sg);
        L1d_pu = Lb/T_SG.Lb(sg);
        
        
        % q axis
        Tq_tr = Tqo_tr*Xq_tr/Xq;
        Tq_subtr = Tqo_subtr*Xq_subtr/Xq_tr;
        
        Lq = Xq*T_SG.Lb(sg);
        Lmq = Xmq*T_SG.Lb(sg);
        
        A = Lmq^2/(Lq*(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr));
        a = (Lq*(Tq_tr+Tq_subtr)-Ll*(Tqo_tr+Tqo_subtr))/Lmq;
        b = (Lq*Tq_tr*Tq_subtr-Ll*Tqo_tr*Tqo_subtr)/Lmq;
        c = (Tqo_tr*Tqo_subtr-Tq_tr*Tq_subtr)/(Tqo_tr+Tqo_subtr-Tq_tr-Tq_subtr);
        
        ra = (2*A*sqrt(a^2-4*b))/(a-2*c+sqrt(a^2-4*b));
        La = ra*(a+sqrt(a^2-4*b))/2;
        rb = (2*A*sqrt(a^2-4*b))/(2*c-a+sqrt(a^2-4*b));
        Lb = rb*(a-sqrt(a^2-4*b))/2;
        
        R1q_pu = ra/T_SG.Zb(sg);
        L1q_pu = La/T_SG.Lb(sg);
        R2q_pu = rb/T_SG.Zb(sg);
        L2q_pu = Lb/T_SG.Lb(sg);
    
        % Conversion from standard to equivalent circuit parameters
        Ll_pu = Xl; 
        Lmd_pu = Xd - Xl; 
        Lmq_pu = Xq - Xl; 
            
            % save to T_SG
            T_SG.Ll_pu(sg)  = Ll_pu; 
            T_SG.Lmd_pu(sg) = Lmd_pu; 
            T_SG.Lmq_pu(sg) = Lmq_pu; 
            T_SG.Lfd_pu(sg) = Lfd_pu;
            T_SG.L1q_pu(sg) = L1q_pu;
            T_SG.L1d_pu(sg) = L1d_pu;
            T_SG.L2q_pu(sg) = L2q_pu;
            T_SG.Rf_pu(sg)  = Rf_pu;
            T_SG.R1d_pu(sg) = R1d_pu;
            T_SG.R1q_pu(sg) = R1q_pu;
            T_SG.R2q_pu(sg) = R2q_pu;
    
            T_SG.Ltr(sg)    = T_SG.Xtr(sg)/(2*pi*T_SG.fb(sg));
                    
        % Exciter
            if any(contains(types,['EXCITER-' T_SG.exciter{sg}]))
                T_exciter = readtable(excel_data_sg,'Sheet',['EXCITER-' T_SG.exciter{sg}]);
                T_exciter = T_exciter(T_exciter.number == num,:);
                T_exciter = removevars(T_exciter,{'number','bus'});
                clear exc
                exc = table2struct(T_exciter);         
            else
                clear exc
                exc.TR = 0; % no exciter
            end
            T_SG.exc(sg) = {exc};
        
        % PSS
            if any(contains(types,['PSS-' T_SG.pss{sg}]))
                T_pss = readtable(excel_data_sg,'Sheet',['PSS-' T_SG.pss{sg}]);
                T_pss = T_pss(T_pss.number == num,:);
                T_pss = removevars(T_pss,{'number','bus'});
                clear pss
                pss = table2struct(T_pss); 
                pss.hasPSS = 1;
            else
                clear pss
                pss.hasPSS = 0;
            end    
            T_SG.PSS(sg) = {pss};
    
        % Governor and turbine
            if any(contains(types,['GOVTURB-' T_SG.govturb{sg}]))
                T_govturb = readtable(excel_data_sg,'Sheet',['GOVTURB-' T_SG.govturb{sg}]);
                T_govturb = T_govturb(T_govturb.number == num,:);
                T_govturb = removevars(T_govturb,{'number','bus'});
                clear mech
                mech = table2struct(T_govturb);
            else
                clear mech
                mech.R = 0; % no governor-turbine
            end 
            T_SG.mech(sg) = {mech}; 
        end
    end
end
