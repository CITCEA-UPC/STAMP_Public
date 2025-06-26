function init_user = generate_initialization_user(T_user,delta_slk)
    
    init_user = cell(1,height(T_user));

    for user = 1:1:height(T_user)
        %% For Linear
        delta_slk_local = delta_slk(T_user.SyncArea(user));

        %Data from the power-flow
        delta0   = T_user.theta(user)*pi/180;
        Vg       = (T_user.V(user)/sqrt(3)); % PCC line-neutral voltage RMS 
        Puser0    = T_user.P(user);
        Quser0    = T_user.Q(user);

        vg_q0 = abs(Vg).*cos(delta0-delta_slk_local)*sqrt(2);
        vg_d0 = -abs(Vg).*sin(delta0-delta_slk_local)*sqrt(2);

        Ig       = conj((Puser0+1i*Quser0)./(3*Vg)); %Injected current
        phi_ig   = atan2(imag(Ig),real(Ig));
        ig_q0 = abs(Ig).*cos(delta0+phi_ig-delta_slk_local)*sqrt(2);
        ig_d0 = -abs(Ig).*sin(delta0+phi_ig-delta_slk_local)*sqrt(2);

        inituser.vg_q0 = vg_q0;
        inituser.vg_d0 = vg_d0;
        inituser.ig_q0 = ig_q0;
        inituser.ig_d0 = ig_d0;

        Iga = abs(Ig)*sin(delta0 + phi_ig - delta_slk_local);
        Igb = abs(Ig)*sin(delta0 + phi_ig - delta_slk_local- 2*pi/3);
        Igc = abs(Ig)*sin(delta0 + phi_ig - delta_slk_local + 2*pi/3);

        inituser.Iga = Iga;
        inituser.Igb = Igb;
        inituser.Igc = Igc;
        
        inituser.Igabc = Ig;

        %% For NON-Linear
        %Data from the power-flow
        delta0   = T_user.theta(user)*pi/180;
        Vg       = (T_user.V(user)/sqrt(3)); % PCC line-neutral voltage RMS 
        Puser0    = T_user.P(user);
        Quser0    = T_user.Q(user);

        vg_q0 = abs(Vg).*cos(delta0)*sqrt(2);
        vg_d0 = -abs(Vg).*sin(delta0)*sqrt(2);

        Ig       = conj((Puser0+1i*Quser0)./(3*Vg)); %Injected current
        phi_ig   = atan2(imag(Ig),real(Ig));
        ig_q0 = abs(Ig).*cos(delta0+phi_ig)*sqrt(2);
        ig_d0 = -abs(Ig).*sin(delta0+phi_ig)*sqrt(2);

        ig_qc0  = 2*Puser0/(3*abs(Vg)*sqrt(2));
        ig_dc0  = 2*Quser0/(3*abs(Vg)*sqrt(2));

        inituser.vg_q0_nl = vg_q0;
        inituser.vg_d0_nl = vg_d0;
        inituser.ig_q0_nl = ig_q0;
        inituser.ig_d0_nl = ig_d0;
        inituser.ig_qc0_nl = ig_qc0;
        inituser.ig_dc0_nl = ig_dc0;

        inituser.angles_nl = delta0 -pi/2; % For a PLL for example...

        Iga = abs(Ig)*sin(delta0)*sqrt(2);
        Igb = abs(Ig)*sin(delta0 - 2*pi/3)*sqrt(2);
        Igc = abs(Ig)*sin(delta0 + 2*pi/3)*sqrt(2);

        inituser.Iga_nl = Iga;
        inituser.Igb_nl = Igb;
        inituser.Igc_nl = Igc;
        
        inituser.Igabc_nl = Ig;

        Ig_nou       = conj((Puser0+1i*Quser0)./(3*(Vg*cos(delta0)+j*sin(delta0))));

        S = Puser0+j*Quser0;
        angleS = angle(S);

        inituser.angleS = angleS;

        angle_Ig = -(angleS-delta0);

        inituser.angle_Ig = angle_Ig;

        Iga_nangle = abs(Ig)*sin(angle_Ig)*sqrt(2);
        Igb_nangle = abs(Ig)*sin(angle_Ig - 2*pi/3)*sqrt(2);
        Igc_nangle = abs(Ig)*sin(angle_Ig + 2*pi/3)*sqrt(2);

        inituser.Iga_nangle = Iga_nangle;
        inituser.Igb_nangle = Igb_nangle;
        inituser.Igc_nangle = Igc_nangle;
        

        init_user{user} = inituser;
    end
end
