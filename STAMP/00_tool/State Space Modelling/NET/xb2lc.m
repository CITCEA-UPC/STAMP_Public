function [T_NET,T_trafo,T_load,T_TH] =  xb2lc(T_NET,T_trafo,T_load,T_TH,f) 
    
    T_NET.L   = T_NET.X./(2*pi*f(T_NET.Area));
    T_NET.C   = T_NET.B./(2*pi*f(T_NET.Area))/2;

    T_trafo.L = T_trafo.X./(2*pi*f(T_trafo.Area));
    T_trafo.C = T_trafo.B./(2*pi*f(T_trafo.Area));
    
    for l=1:1:size(T_load,1)
        if T_load.X(l)>0
            T_load.L(l)  = T_load.X(l)/(2*pi*f(T_load.Area(l)));
            T_load.C(l) = 0;
        elseif T_load.X(l)<0
            T_load.C(l)  = -1/(T_load.X(l)*(2*pi*f(T_load.Area(l))));
            T_load.L(l) = 0;
        else
            T_load.C(l)=0;
            T_load.L(l)=0;
        end
    end

    T_TH.L = T_TH.X./(2*pi*f(T_TH.Area));
end


