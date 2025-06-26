function ini_stat = generate_initialization_STATCOM(T_STATCOM,results) 

ini_stat = cell(1,height(T_STATCOM));

    for stat = 1:1:height(T_STATCOM)

        %Data from the power-flow
        bus         = T_STATCOM.bus(stat);   
        theta0      = results.bus.theta(bus)*pi/180;
        U_PCC_VSC   = results.bus.Vm(bus)/sqrt(3);  %(Vll rms) PCC Voltage Magnitude sqrt(uq^2+ud^2)/sqrt(2) 
        P_VSC       = results.stat.P(stat);
        Q_VSC       = results.stat.Q(stat);

        %Data from the STATCOM
        Req_n     = T_STATCOM.Req;
        Leq_n     = T_STATCOM.Leq;
        wb        = 2*pi*T_STATCOM.fn;
        Z_eq      = Req_n+1j*wb*Leq_n;
        
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

        initSTATCOM.Isa = abs(Isa_VSC)*sin(angle(Isa_VSC));
        initSTATCOM.Isb = abs(Isb_VSC)*sin(angle(Isb_VSC));
        initSTATCOM.Isc = abs(Isc_VSC)*sin(angle(Isc_VSC));

        %PLL 
        thetaPLL = theta0-pi/2;
        initSTATCOM.thetaPLL_init = theta0-pi/2; % the -pi/2 is necessary due to the PLL being locked in the peak value of the waveform and the theta must be the one from the power flow... same signal!

        initSTATCOM.ud = real(U_PCC_vec*sqrt(2)*exp(-1i*(thetaPLL)));
        initSTATCOM.uq = imag(U_PCC_vec*sqrt(2)*exp(-1i*(thetaPLL)));

        Udiff_d = real(Udiff_a*exp(-1i*(thetaPLL)));
        Udiff_q = imag(Udiff_a*exp(-1i*(thetaPLL)));

        initSTATCOM.idiffd = real(Is_VSC*sqrt(2)*exp(-1i*(thetaPLL)));
        initSTATCOM.idiffq = imag(Is_VSC*sqrt(2)*exp(-1i*(thetaPLL)));

        initSTATCOM.Vref = initSTATCOM.uq + T_STATCOM.KfeedVac*initSTATCOM.idiffd;

        % Differential current loops 
        initSTATCOM.PI_idiffq =  Udiff_q-initSTATCOM.uq-Leq_n*wb*initSTATCOM.idiffd;
        initSTATCOM.PI_idiffd =  Udiff_d-initSTATCOM.ud+Leq_n*wb*initSTATCOM.idiffq;
        initSTATCOM.PI_idiff0 = 0;

        %Voltage controller
        initSTATCOM.PI_V = initSTATCOM.idiffd;

        %Electrical part
        initSTATCOM.Udiff_a = Udiff_a;
        initSTATCOM.Udiff_b = Udiff_b;
        initSTATCOM.Udiff_c = Udiff_c;
        
        ini_stat{stat} = initSTATCOM;
    end
end
