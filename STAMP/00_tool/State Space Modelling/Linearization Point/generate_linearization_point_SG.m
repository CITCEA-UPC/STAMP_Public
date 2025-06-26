%% Calculates the linearization point per each MMC
function lp_sg = generate_linearization_point_SG(T_SG, T_global, delta_slk_ll)

lp_sg = cell(1,height(T_SG));

    for sg = 1:1:height(T_SG)  

        Ssg = T_SG.Sb(sg);       % SG rated power, SG power base  
        Vsg = T_SG.Vb(sg);
        Sb  = T_global.Sb(T_global.Area == T_SG.Area(sg)); % System power base
        Vb  = T_global.Vb(T_global.Area == T_SG.Area(sg));
        delta_slk = delta_slk_ll(T_SG.Area(sg));
                   
        % SG parameters
        Rs_pu  = T_SG.Rs(sg);
        Rtr    = T_SG.Rtr(sg);
        Xtr    = T_SG.Xtr(sg);
        Rsnb   = T_SG.Rsnb(sg);
        Xq     = T_SG.Xq(sg);
        Xd     = T_SG.Xd(sg);
        Xd_tr  = T_SG.Xd_tr(sg);
        Lmd_pu = T_SG.Lmd_pu(sg);

        % Data from the power-flow 
        delta0   = T_SG.theta(sg)*pi/180;
        V        = T_SG.V(sg)*(Vb/(Vsg*sqrt(3)/sqrt(2)));          % PCC line-line voltage RMS
        Psg0     = T_SG.P(sg)*(Sb/Ssg);
        Qsg0     = T_SG.Q(sg)*(Sb/Ssg);
                           
        % SG terminals voltage
        Itr = conj((Psg0+1i*Qsg0)./V);
        Vin = V + Itr*(Rtr+1i*Xtr);
        theta_in = atan(imag(Vin)/real(Vin));
       
        % Snubber current
        Isnb = Vin/(Rsnb);
        
        %SG current
        Isg = Isnb+Itr;
        I = abs(Isg);
        
        % Aparent power (inside the transformer)
        Sin = Vin*conj(Isg);
        Pin = real(Sin);
        Qin = imag(Sin);
        phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin); %acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin);
        
        % Internal voltage
        E = abs(Vin)+(Rs_pu+1i*Xq)*(I.*cos(phi)+1i*I.*sin(phi));
        Eq = real(E);
        Ed = imag(E);
        
        Emag = abs(E);
        delta = atan(Ed./Eq); %rotor angle %atan((Xq*I*cos(phi)-Rs_pu*I*sin(phi)/(abs(Vin)+Rs_pu*I*cos(phi)+Xq*I*sin(phi)))); 
        
        % qd currents
        Iq = I.*cos(-delta+phi); %local
        Id = -I.*sin(-delta+phi); %local
                
        % qd terminal voltage
        vsgq_g0 = abs(Vin).*cos(-delta); %local
        vsgd_g0 = -abs(Vin).*sin(-delta); %local
        
        delta_bus = delta0 + theta_in - delta_slk;
        
        % qd terminal voltage (REF: NET)
        
        Vq = abs(Vin).*cos(delta_bus)*Vsg/Vb; % global
        Vd = -abs(Vin).*sin(delta_bus)*Vsg/Vb;% global

        % qd terminal voltage outside bus (REF: NET, rms l-l)
        Vq_bus = abs(V)*cos(delta0-delta_slk)*Vsg/Vb;
        Vd_bus = -abs(V)*sin(delta0-delta_slk)*Vsg/Vb;
        
        % % qd terminal voltage (REF: NET)
        % Vq = abs(Vin).*cos(delta_bus)*sqrt(2/3); % global
        % Vd = -abs(Vin).*sin(delta_bus)*sqrt(2/3);% global
        % 
        % % qd terminal voltage outside bus (REF: NET, rms l-l)
        % Vq_bus = abs(V)*cos(delta0-delta_slk)*sqrt(2/3);
        % Vd_bus = -abs(V)*sin(delta0-delta_slk)*sqrt(2/3);
        

        % Field voltage
        Eq_tr = Emag-Id*(Xq-Xd_tr);
        Efd = Eq_tr + (Xd-Xd_tr)*Id;
        Ifd = Efd/Lmd_pu;

        Pm0 = Pin+(Iq.^2+Id.^2)*Rs_pu;  

        e_theta0 = delta0 + delta + theta_in - delta_slk;  
       
        %% Store linearization point

        lp.isq0 = Iq;  % pu
        lp.isd0 = Id;  % pu
        lp.ifd0 = Ifd; % pu
        lp.ikd0 = 0;
        lp.ikq10 = 0;
        lp.ikq20 = 0;
        lp.vq0 = Vq; % V
        lp.vd0 = Vd; % V
        lp.w0_pu = 1; %results.f/fref; % pu
        lp.w0 = T_SG.wb(sg); %results.f*2*pi; % rad/s
        lp.etheta0 = e_theta0; 
        lp.Pm0 = Pm0;
        lp.vq_bus0 = Vq_bus;
        lp.vd_bus0 = Vd_bus;

        lp.Efd0 = Efd;

        lp.vsg_q0 = vsgq_g0;
        lp.vsg_d0 = vsgd_g0;

        lp_sg{sg} = lp;
    end
end
