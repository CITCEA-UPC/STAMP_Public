%% Calculates the linearization point per each MMC
function lp_sg = generate_linearization_point_SG_user(T_SG,results)

lp_sg = cell(1,height(T_SG));

    for sg = 1:1:height(T_SG)  
        %% Data from the power-flow ---------------------------------------
        bus = T_SG.bus(sg);       
        num      = T_SG.number(sg);
        theta0   = results.global.theta(bus)*pi/180;
        V        = results.global.Vm(bus)/sqrt(3)*sqrt(2);   % PCC line voltage RMS
        Psg0     = results.user.P(num)*T_SG.Sb(sg)/T_SG.Sn(sg);
        Qsg0     = results.user.Q(num)*T_SG.Sb(sg)/T_SG.Sn(sg);
        
        %SG current
        I = abs(conj((Psg0+1i*Qsg0)/V));
        phi = -acos(Psg0./(sqrt(Psg0.^2+Qsg0.^2))).*sign(Qsg0./Psg0) + theta0;
        
        % Internal voltage
        E = (V*cos(theta0)+1i*V*sin(theta0))+(T_SG.Rs_pu(sg)+1i*T_SG.Xq(sg))*(I*cos(phi)+1i*I*sin(phi));
        Eq = real(E);
        Ed = imag(E);
        
        Emag = abs(E);
        delta = abs(atan(Ed/Eq)); %rotor angle
        
        % qd currents
        Iq = I*cos(-delta+phi);
        Id = -I*sin(-delta+phi);
        
        % qd terminal voltage
        Vq = V.*cos(theta0-delta);
        Vd = -V.*sin(theta0-delta);
        
        % qd terminal voltage (REF: NET)
        Vq_NET = V.*cos(theta0)*T_SG.Vbpubase(sg); %OJU AQUI ELS RMS (?)
        Vd_NET = -V.*sin(theta0)*T_SG.Vbpubase(sg);

        Iq_NET = I*cos(phi)*T_SG.Ibpubase(sg);
        Id_NET = -I*sin(phi)*T_SG.Ibpubase(sg);
        
        % Field voltage
        Eq_tr = Emag-Id*(T_SG.Xq(sg)-T_SG.Xd_tr(sg));
        Efd = Eq_tr + (T_SG.Xd(sg)-T_SG.Xd_tr(sg))*Id;
        Ifd = Efd/T_SG.Lmd_pu(sg);
       
        %% calculate linear model linearization point ---------------------      
        lp.isq0 = Iq;  % pu
        lp.isd0 = Id;  % pu
        lp.ifd0 = Ifd; % pu
        lp.ikd0 = 0;
        lp.ikq10 = 0;
        lp.ikq20 = 0;
        lp.vsgq_pu0 = Vq; % V
        lp.vsgd_pu0 = Vd; % V
        lp.w0_pu = 1; %results.f/fref; % pu
        lp.w0 = T_SG.wn(sg); %results.f*2*pi; % rad/s
        lp.etheta0 = delta; 

        lp.vq0 = Vq_NET;
        lp.vd0 = Vd_NET;
        lp.iq0 = Iq_NET;
        lp.id0 = Id_NET;

        lp_sg{sg} = lp;
    end
end
