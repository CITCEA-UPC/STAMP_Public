function TH_ref = calcul_ref_th2(P,Q,V,R,L)
        theta = pi-angle(V);
        Rotation = [cos(theta) sin(theta); -sin(theta) cos(theta)];

        iqc = (2*P)/(3*abs(V));
        idc = (2*Q)/(3*abs(V));
        
        Uqc = abs(V) + R*iqc + 2*pi*60*L*idc;
        Udc = +R*idc - 2*pi*60*L*iqc;

        Uth = -Rotation*[Uqc;Udc]
        Uth = Uth(1)-1j*Uth(2);

        TH_ref.angle = angle(Uth);
        TH_ref.mag = abs(Uth);%*sqrt(2)/sqrt(3);
end