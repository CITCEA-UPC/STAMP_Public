function ini_shunt = generate_initialization_Shunt(T_shunt,results)
    
ini_shunt = cell(1,height(T_shunt));

    for shunt_element = 1:1:height(T_shunt)

        %Operator a:
        a=cos(2*pi/3) + 1i*sin(2*pi/3);

        %Frequency
        wb   = T_shunt.wb(shunt_element);

        %Data from the power-flow
        bus         = T_shunt.bus(shunt_element);   
        theta0      = results.bus.theta(bus)*pi/180;
        U_PCC_OUT   = results.bus.Vm(bus)/sqrt(3);  %(Vll rms) PCC Voltage Magnitude sqrt(uq^2+ud^2)/sqrt(2) 
        [U_PCC_r,U_PCC_i] = pol2cart(theta0, U_PCC_OUT); % phase voltage RMS
        %U_PCC_vec = U_PCC_r+1i*U_PCC_i;
        U_PCC_vec = U_PCC_r+1i*U_PCC_i;
        % % U_PCC_ph = abs(U_PCC_vec);
        % P_OUT       = results.stat.P(shunt_element);
        % Q_OUT       = results.stat.Q(shunt_element);
        % S_OUT       = P_OUT+1i*Q_OUT;
        % Is_OUT      = conj(S_OUT/(3*U_PCC_vec)); % phase current RMS

        type=T_shunt.type{shunt_element};

        switch type  
    
            case 'RLC'            
    
            %Data from the RLC Filter
            R_RLC=T_shunt.R(shunt_element);
            L_RLC=T_shunt.L(shunt_element);
            C_RLC=T_shunt.C(shunt_element);
            if C_RLC == 0
                % RLC Filter electrical variables  
                Z_L=1i*wb*L_RLC/T_shunt.Zbpu_l2g(shunt_element);
                Z_R=R_RLC/T_shunt.Zbpu_l2g(shunt_element);
                Z_RLC=Z_L+Z_R;
                I_RLC=U_PCC_vec/Z_RLC;
                VC = inf;
            else
                % RLC Filter electrical variables  
                Z_C=-1i/(wb*C_RLC)/T_shunt.Zbpu_l2g(shunt_element);
                Z_L=1i*wb*L_RLC/T_shunt.Zbpu_l2g(shunt_element);
                Z_R=R_RLC/T_shunt.Zbpu_l2g(shunt_element);
                Z_RLC=Z_C+Z_L+Z_R;
                I_RLC=U_PCC_vec/Z_RLC;
                VC=I_RLC*Z_C;
            end
          
            %RLC Filter state calculation
            if T_shunt.L(shunt_element) ~= 0
                iL_a=I_RLC*sqrt(2);
                iL_b=I_RLC*sqrt(2)*a^2;
                iL_c=I_RLC*sqrt(2)*a;
            else
                iL_a=0;
                iL_b=0;
                iL_c=0;
            end
            vc_a=VC*sqrt(2);
            vc_b=VC*sqrt(2)*a^2;
            vc_c=VC*sqrt(2)*a;

            %RLC Filter
            init_shunt.iL_a =abs(iL_a)*sin(angle(iL_a));
            init_shunt.iL_b =abs(iL_b)*sin(angle(iL_b));
            init_shunt.iL_c =abs(iL_c)*sin(angle(iL_c));
    
            init_shunt.vC_a =abs(vc_a)*sin(angle(vc_a));
            init_shunt.vC_b =abs(vc_b)*sin(angle(vc_b));
            init_shunt.vC_c =abs(vc_c)*sin(angle(vc_c));

            case 'C-type'

            %Data from the C-type Filter
            R_ctype=T_shunt.R(shunt_element);
            L_ctype=T_shunt.L(shunt_element);
            C1_ctype=T_shunt.C1(shunt_element);
            C2_ctype=T_shunt.C2(shunt_element);    

            %C-type filter electrical equations
            Z_C1=-1i/(wb*C1_ctype)/T_shunt.Zbpu_l2g(shunt_element);
            Z_C2=-1i/(wb*C2_ctype)/T_shunt.Zbpu_l2g(shunt_element);
            Z_R=R_ctype/T_shunt.Zbpu_l2g(shunt_element);
            Z_L=1i*wb*L_ctype/T_shunt.Zbpu_l2g(shunt_element);
            Z_LC=Z_L+Z_C2;
            Z_c=Z_C1+(Z_R*Z_LC/(Z_R+Z_LC));
            I_ctype=U_PCC_vec/Z_c;
            %C-type Kirchoff rules
            VC1=I_ctype*Z_C1;
            IL=I_ctype*Z_R/(Z_R+Z_LC);
            VC2=IL*Z_C2;
            %C-type state initialisation
            vc1_a=VC1*sqrt(2);
            vc1_b=VC1*sqrt(2)*a^2;
            vc1_c=VC1*sqrt(2)*a;
            vc2_a=VC2*sqrt(2);
            vc2_b=VC2*sqrt(2)*a^2;
            vc2_c=VC2*sqrt(2)*a;
            iL_a=IL*sqrt(2);
            iL_b=IL*sqrt(2)*a^2;
            iL_c=IL*sqrt(2)*a;
                   
            %C-type
            init_shunt.iL_a =abs(iL_a)*sin(angle(iL_a));
            init_shunt.iL_b =abs(iL_b)*sin(angle(iL_b));
            init_shunt.iL_c =abs(iL_c)*sin(angle(iL_c));
    
            init_shunt.vC1_a =abs(vc1_a)*sin(angle(vc1_a));
            init_shunt.vC1_b =abs(vc1_b)*sin(angle(vc1_b));
            init_shunt.vC1_c =abs(vc1_c)*sin(angle(vc1_c));
    
            init_shunt.vC2_a =abs(vc2_a)*sin(angle(vc2_a));
            init_shunt.vC2_b =abs(vc2_b)*sin(angle(vc2_b));
            init_shunt.vC2_c =abs(vc2_c)*sin(angle(vc2_c));

        end
        ini_shunt{shunt_element} = init_shunt;
    end
end