function TH_ref = calcul_ref_th3(P,Q,Vrms,theta,R,L)
        Vpeak=Vrms*sqrt(2)/sqrt(3);
        theta=theta*pi/180;
        Rotation = [cos(theta) sin(theta); -sin(theta) cos(theta)];

        iqc = (2*P)/(3*abs(Vpeak));
        idc = (2*Q)/(3*abs(Vpeak));
        
        Uqc = abs(Vpeak) + R*iqc + 2*pi*60*L*idc;
        Udc = +R*idc - 2*pi*60*L*iqc;

        %Uth = -Rotation*[Uqc;Udc];
        Uth = Rotation*[Uqc;Udc];
        Uth = Uth(1)-1j*Uth(2);

        TH_ref.angle = angle(Uth);
        TH_ref.mag = abs(Uth);%*sqrt(2)/sqrt(3);

        Ith = Rotation*[iqc;idc];
        a=cos(2*pi/3) + 1i*sin(2*pi/3);
        Iqtha = Ith(1)-1j*Ith(2);
        Iqthb=Iqtha*a^2;
        Iqthc=Iqthc*a;

end