function TH_ref = calcul_ref_th(P,Q,V,R,L)
        Z = R + 1j*2*pi*60*L;
        S = P + 1j*Q;
        I = conj(S/(3*V));
        Uth = (V+Z*I);
        TH_ref.angle = angle(Uth)*180/pi;
        TH_ref.mag = abs(Uth);%*sqrt(2)/sqrt(3);
end