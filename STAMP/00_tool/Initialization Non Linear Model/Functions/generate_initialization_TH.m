function ini_TH = generate_initialization_TH(T_TH,results,f)

ini_TH = cell(1,height(T_TH));

    for th = 1:1:height(T_TH)
        bus = T_TH.bus(th);  
        Vrms = results.bus.Vm(results.bus.bus == bus); %rms phase-to-phase
        theta = results.bus.theta(results.bus.bus == bus)*pi/180;
        
        R = T_TH.R(th);
        L = T_TH.L(th);
        P_TH = results.th.P(th);
        Q_TH = results.th.Q(th);


        Z = R+1i*2*pi*f*L;
        %Operator a:
        a=cos(2*pi/3) + 1i*sin(2*pi/3);
        
        %Initial value calculation:
        [U_PCC_r,U_PCC_i]   = pol2cart(theta, Vrms/sqrt(3)); % phase-to-ground RMS
        U_PCC_vec           = U_PCC_r+1i*U_PCC_i;
        S_TH                = P_TH+1i*Q_TH;
        Is_Th               = conj(S_TH/(3*U_PCC_vec)); % phase current rms

        % Phase-to-ground peak
        TH_ref.Vtha = (U_PCC_vec+Z*Is_Th)*sqrt(2);
        TH_ref.Vthb = (U_PCC_vec+Z*Is_Th)*sqrt(2)*a^2;
        TH_ref.Vthc = (U_PCC_vec+Z*Is_Th)*sqrt(2)*a;

        TH_ref.angle = angle(TH_ref.Vtha);
        TH_ref.Vmag = abs(TH_ref.Vtha)*sqrt(3)/sqrt(2); %phase-to-phase rms

        Isa_Th = Is_Th*sqrt(2);
        Isb_Th = Is_Th*sqrt(2)*a^2;
        Isc_Th = Is_Th*sqrt(2)*a;

        TH_ref.Itha = abs(Isa_Th)*sin(angle(Isa_Th));
        TH_ref.Ithb = abs(Isb_Th)*sin(angle(Isb_Th));
        TH_ref.Ithc = abs(Isc_Th)*sin(angle(Isc_Th));



%         TH_ref.Q = Q;
%         Vpeak = Vrms*sqrt(2)/sqrt(3);
%         Rotation = [cos(theta) sin(theta); -sin(theta) cos(theta)];
% 
%         iqc = (2*P)/(3*abs(Vpeak));
%         idc = (2*Q)/(3*abs(Vpeak));
%         
%         %Uqc = abs(Vpeak) + R*iqc + 2*pi*f*L*idc;
%         Uqc = abs(Vrms) + R*iqc + 2*pi*f*L*idc;
%         Udc = +R*idc - 2*pi*f*L*iqc;
% 
%         %Uth = -Rotation*[Uqc;Udc];
%         Uth = Rotation*[Uqc;Udc];
%         Uth = Uth(1)-1j*Uth(2);
% 
%         TH_ref.angle = angle(Uth);
%         TH_ref.Vmag = abs(Uth)*sqrt(2)/sqrt(3);
% 
%         Ith = Rotation*[iqc;idc];
% 
%         Ith = Ith(1)-1j*Ith(2);
%         Ithmag = abs(Ith);
%         Ithangle = angle(Ith);
% 
%         TH_ref.Itha = Ithmag*sin(Ithangle);
%         TH_ref.Ithb = Ithmag*sin(Ithangle-2*pi/3);
%         TH_ref.Ithc = Ithmag*sin(Ithangle+2*pi/3);
% 
%         TH_ref.Vtha = abs(Uth)*sin(angle(Uth));
%         TH_ref.Vthb = abs(Uth)*sin(angle(Uth)-2*pi/3);
%         TH_ref.Vthc = abs(Uth)*sin(angle(Uth)+2*pi/3);

        ini_TH{th} = TH_ref;
    end
end