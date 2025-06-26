function ini_mmc = generate_initialization_MMCs_user(T_MMC,results) 

ini_mmc = cell(1,height(T_MMC));

    for mmc = 1:1:height(T_MMC)

        %Data from the power-flow
        bus = T_MMC.NodeAC(mmc);  
        num = T_MMC.number(mmc);
        theta0    = results.global.theta(bus)*pi/180;
        U_PCC_VSC = results.global.Vm(bus)/sqrt(3);  %(Vll rms)
        P_VSC = results.user.P(num);
        Q_VSC = results.user.Q(num);
        Vdc   = T_MMC.vDC(mmc);
        P_DC  = results.b2b.Vdc2(1)*results.b2b.Idc2(1);
        
        %Data from the MMC
        Req_n     = T_MMC.Rc+T_MMC.Ra/2;
        Leq_n     = T_MMC.Lc+T_MMC.La/2;
        wb        = 2*pi*T_MMC.f;
        Z_eq      = Req_n+1j*wb*Leq_n;
        Ra_n      = T_MMC.Ra;

        C_SM = T_MMC.Carm;
        N = 100;
        V_SM = Vdc/N;
        
        %Operator a:
        a=cos(2*pi/3) + 1i*sin(2*pi/3);
        
        %Initial value calculation:
        [U_PCC_r,U_PCC_i] = pol2cart(theta0, U_PCC_VSC); % phase voltage RMS
        U_PCC_vec = U_PCC_r+1i*U_PCC_i;
        U_PCC_ph = abs(U_PCC_vec);
        S_VSC = P_VSC+1i*Q_VSC;
        Is_VSC = conj(S_VSC/(3*U_PCC_vec)); % phase current RMS

        Udiff_a = (U_PCC_vec+Z_eq*Is_VSC)*sqrt(2);
        Udiff_b = (U_PCC_vec+Z_eq*Is_VSC)*sqrt(2)*a^2;
        Udiff_c = (U_PCC_vec+Z_eq*Is_VSC)*sqrt(2)*a;

        Isa_VSC = Is_VSC*sqrt(2);
        Isb_VSC = Is_VSC*sqrt(2)*a^2;
        Isc_VSC = Is_VSC*sqrt(2)*a;

%         initMMCs.Isa = abs(Isa_VSC)*sin(angle(Isa_VSC)-pi/2);
%         initMMCs.Isb = abs(Isb_VSC)*sin(angle(Isb_VSC)-pi/2);
%         initMMCs.Isc = abs(Isc_VSC)*sin(angle(Isc_VSC)-pi/2);

         initMMCs.Isa = abs(Isa_VSC)*sin(angle(Isa_VSC));
         initMMCs.Isb = abs(Isb_VSC)*sin(angle(Isb_VSC));
         initMMCs.Isc = abs(Isc_VSC)*sin(angle(Isc_VSC));

        %PLL 
        thetaPLL = theta0-pi/2;
        initMMCs.thetaPLL_init = theta0-pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!

        initMMCs.ud = real(U_PCC_vec*sqrt(2)*exp(-1i*(thetaPLL)));
        initMMCs.uq = imag(U_PCC_vec*sqrt(2)*exp(-1i*(thetaPLL)));

        Udiff_d = real(Udiff_a*exp(-1i*(thetaPLL)));
        Udiff_q = imag(Udiff_a*exp(-1i*(thetaPLL)));

        initMMCs.idiffd = real(Is_VSC*sqrt(2)*exp(-1i*(thetaPLL)));
        initMMCs.idiffq = imag(Is_VSC*sqrt(2)*exp(-1i*(thetaPLL)));

        % Differential current loops 
        initMMCs.PI_idiffq =  Udiff_q-initMMCs.uq-Leq_n*wb*initMMCs.idiffd;
        initMMCs.PI_idiffd =  Udiff_d-initMMCs.ud+Leq_n*wb*initMMCs.idiffq;
        initMMCs.PI_idiff0 = 0;

        % Isum
        initMMCs.isum0_DC = P_DC/(3*Vdc);
        Vsum0_DC = (-2*Ra_n*initMMCs.isum0_DC+Vdc);
        initMMCs.PI_isum0_DC = -(-Vdc+Vsum0_DC);

        %Total energy PI
        initMMCs.PI_Et = initMMCs.isum0_DC;

        %vDC multivariable controller
        initMMCs.PI_eVdc = -initMMCs.idiffq + 2/3*(3*initMMCs.isum0_DC)*Vdc;
        initMMCs.PI_Wt = 0;

        %Electrical part
        C = 1/3*[2 -1 -1; 0 -sqrt(3) sqrt(3); 1 1 1];
        Usum_abc = inv(C)*[0;0;Vsum0_DC];
        Isum_abc = inv(C)*[0;0;initMMCs.isum0_DC];
        initMMCs.Usum_abc = Usum_abc;

        initMMCs.Udiff_a = Udiff_a;
        initMMCs.Udiff_b = Udiff_b;
        initMMCs.Udiff_c = Udiff_c;

        U_ua = -abs(Udiff_a) + 1/2*Usum_abc(1);
        U_ub = -abs(Udiff_b) + 1/2*Usum_abc(2);
        U_uc = -abs(Udiff_c) + 1/2*Usum_abc(3);
        
        U_la = abs(Udiff_a) + 1/2*Usum_abc(1);
        U_lb = abs(Udiff_b) + 1/2*Usum_abc(2);
        U_lc = abs(Udiff_c) + 1/2*Usum_abc(3);
        
        U_ua_abs = -(abs(Udiff_a)) + 1/2*Usum_abc(1);
        lU_ub_abs = -(abs(Udiff_b)) + 1/2*Usum_abc(2);
        lU_uc_abs = -(abs(Udiff_c)) + 1/2*Usum_abc(3);
        lU_la_abs = (abs(Udiff_a) + 1/2*Usum_abc(1));
        lU_lb_abs = (abs(Udiff_b) + 1/2*Usum_abc(2));
        lU_lc_abs = (abs(Udiff_c) + 1/2*Usum_abc(3));
        
        U_ua_ini = -abs(Udiff_a)*cos(angle(Udiff_a))+1/2*Usum_abc(1);
        U_ub_ini = -abs(Udiff_b)*cos(angle(Udiff_b))+1/2*Usum_abc(2);
        U_uc_ini = -abs(Udiff_c)*cos(angle(Udiff_c))+1/2*Usum_abc(3);
        U_la_ini = abs(Udiff_a)*cos(angle(Udiff_a))+1/2*Usum_abc(1);
        U_lb_ini = abs(Udiff_b)*cos(angle(Udiff_b))+1/2*Usum_abc(2);
        U_lc_ini = abs(Udiff_c)*cos(angle(Udiff_c))+1/2*Usum_abc(3);
        
        
        U_ua_ang = angle(-Udiff_a)*180/pi;
        U_ub_ang = angle(-Udiff_b)*180/pi;
        U_uc_ang = angle(-Udiff_c)*180/pi;
        U_la_ang = angle(Udiff_a)*180/pi;
        U_lb_ang = angle(Udiff_b)*180/pi;
        U_lc_ang = angle(Udiff_c)*180/pi;
        
        
        I_ua_abs = 1/2*abs(Isa_VSC) + 1*Isum_abc(1);
        I_ub_abs = 1/2*abs(Isb_VSC) + 1*Isum_abc(2);
        I_uc_abs = 1/2*abs(Isc_VSC) + 1*Isum_abc(3);
        I_la_abs = -1/2*abs(Isa_VSC) + 1*Isum_abc(1);
        I_lb_abs = -1/2*abs(Isb_VSC) + 1*Isum_abc(2);
        I_lc_abs = -1/2*abs(Isc_VSC) + 1*Isum_abc(3);
        
        I_ua_ini = 1/2*abs(Isa_VSC)*cos(angle(Isa_VSC))+Isum_abc(1);
        I_ub_ini = 1/2*abs(Isb_VSC)*cos(angle(Isb_VSC))+Isum_abc(2);
        I_uc_ini = 1/2*abs(Isc_VSC)*cos(angle(Isc_VSC))+Isum_abc(3);
        I_la_ini = -1/2*abs(Isa_VSC)*cos(angle(Isa_VSC))+Isum_abc(1);
        I_lb_ini = -1/2*abs(Isb_VSC)*cos(angle(Isb_VSC))+Isum_abc(2);
        I_lc_ini = -1/2*abs(Isc_VSC)*cos(angle(Isc_VSC))+Isum_abc(3);
        
        I_ua_ang = angle(Isa_VSC)*180/pi;
        I_ub_ang = angle(Isb_VSC)*180/pi;
        I_uc_ang = angle(Isc_VSC)*180/pi;
        I_la_ang = angle(-Isa_VSC)*180/pi;
        I_lb_ang = angle(-Isb_VSC)*180/pi;
        I_lc_ang = angle(-Isc_VSC)*180/pi;
        
        
        Isa_in = abs(Isa_VSC)*cos(angle(Isa_VSC));
        Isb_in = abs(Isb_VSC)*cos(angle(Isb_VSC));
        Isc_in = abs(Isc_VSC)*cos(angle(Isc_VSC));
        


        t = 0; %0.0125; desfasament 
        phi_w=-pi/2;
        phi_2w=pi;
        Udiff_a = (U_PCC_vec+Z_eq*Is_VSC);
        Udiff_b = (U_PCC_vec+Z_eq*Is_VSC)*a^2;
        Udiff_c = (U_PCC_vec+Z_eq*Is_VSC)*a;
        Isa_VSC = Is_VSC;
        Isb_VSC = Is_VSC*a^2;
        Isc_VSC = Is_VSC*a;

        initMMCs.Uc_ua = Vdc;
        initMMCs.Uc_ub = Vdc;
        initMMCs.Uc_uc = Vdc;
        initMMCs.Uc_la = Vdc;
        initMMCs.Uc_lb = Vdc;
        initMMCs.Uc_lc = Vdc;

%         initMMCs.Uc_ua = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isa_VSC)*abs(Udiff_a)*sin(angle(Isa_VSC) + angle(-Udiff_a) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isa_VSC)*1/2*Usum_abc(1)*sin(angle(Isa_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(1)*abs(Udiff_a)*sin(angle(-Udiff_a) + t*wb+phi_w))/wb)*N)/(C_SM)));
%         initMMCs.Uc_ub = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isb_VSC)*abs(Udiff_b)*sin(angle(Isb_VSC) + angle(-Udiff_b) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isb_VSC)*1/2*Usum_abc(2)*sin(angle(Isb_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(2)*abs(Udiff_b)*sin(angle(-Udiff_b) + t*wb+phi_w))/wb)*N)/(C_SM)));
%         initMMCs.Uc_uc = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isc_VSC)*abs(Udiff_c)*sin(angle(Isc_VSC) + angle(-Udiff_c) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isc_VSC)*1/2*Usum_abc(3)*sin(angle(Isc_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(3)*abs(Udiff_c)*sin(angle(-Udiff_c) + t*wb+phi_w))/wb)*N)/(C_SM)));
%         initMMCs.Uc_la = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isa_VSC)*abs(Udiff_a)*sin(angle(-Isa_VSC) + angle(Udiff_a) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isa_VSC)*1/2*Usum_abc(1)*sin(angle(-Isa_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(1)*abs(Udiff_a)*sin(angle(Udiff_a) + t*wb+phi_w))/wb)*N)/(C_SM)));
%         initMMCs.Uc_lb = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isb_VSC)*abs(Udiff_b)*sin(angle(-Isb_VSC) + angle(Udiff_b) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isb_VSC)*1/2*Usum_abc(2)*sin(angle(-Isb_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(2)*abs(Udiff_b)*sin(angle(Udiff_b) + t*wb+phi_w))/wb)*N)/(C_SM)));
%         initMMCs.Uc_lc = (sqrt(2*((1/2*(C_SM*V_SM^2*N)+1*((1/2*abs(Isc_VSC)*abs(Udiff_c)*sin(angle(-Isc_VSC) + angle(Udiff_c) + 2*t*wb+phi_2w))/2 + 2^(1/2)*1/2*abs(Isc_VSC)*1/2*Usum_abc(3)*sin(angle(-Isc_VSC) + t*wb+phi_w) + 2^(1/2)*Isum_abc(3)*abs(Udiff_c)*sin(angle(Udiff_c) + t*wb+phi_w))/wb)*N)/(C_SM)));
% 
        ini_mmc{mmc} = initMMCs;
    end
end
