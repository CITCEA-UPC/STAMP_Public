%% Calculates the linearization point per each MMC
function lp_stat = generate_linearization_point_STAT(T_STATCOM,results)

lp_stat = cell(1,height(T_STATCOM));

    for stat = 1:1:height(T_STATCOM)
        %Data from the MMC:
        Req = T_STATCOM.Req(stat);
        Leq = T_STATCOM.Leq(stat);
        w = 2*pi*T_STATCOM.fn(stat);

        %Data from the power-flow
        bus    = T_STATCOM.bus(stat);   
        theta0 = results.global.theta(bus)*pi/180; %In radians
        V      = results.global.Vm(bus)*sqrt(2)/sqrt(3);  % PCC Voltage Magnitude sqrt(uq^2+ud^2)/sqrt(2) 
        P      = results.stat.P(stat);
        Q      = results.stat.Q(stat);

        %Liniearization point calculation:
        %AC side:
        %AC voltage MMC reference:
        V_q_c = V;
        V_d_c = 0;
        
        %AC voltage NET reference:
        Rotation = [cos(theta0) sin(theta0); -sin(theta0) cos(theta0)];
        V_0 = Rotation*[V_q_c ; V_d_c];
        V_q_0 = V_0(1);
        V_d_0 = V_0(2);
        
        %AC current MMC reference:
        is_q_c = (2*P)/(3*V_q_c);
        is_d_c = (2*Q)/(3*V_q_c);
        
        %AC current NET reference:
        is_0 = Rotation*[is_q_c ; is_d_c];
        is_q_0 = is_0(1);
        is_d_0 = is_0(2);
        
        %Vdiff voltage MMC reference:
        Vdiff_q_c = V_q_c + Req*is_q_c + w*Leq*is_d_c;
        Vdiff_d_c = V_d_c + Req*is_d_c - w*Leq*is_q_c;

        %Vdiff voltage NET reference:
        Vdiff_q_0 = V_q_0 + Req*is_q_0 + w*Leq*is_d_0 ;
        Vdiff_d_0 = V_d_0 + Req*is_d_0 - w*Leq*is_q_0;
                
        %Generate output:
        lp.vnq0       = V_q_0;
        lp.vnd0       = V_d_0;
        lp.vnq0_c     = V_q_c;
        lp.vnd0_c     = V_d_c;
        lp.idiffq0    = is_q_0;
        lp.idiffd0    = is_d_0;
        lp.idiffq0_c  = is_q_c;
        lp.idiffd0_c  = is_d_c;
        lp.vdiffq0    = Vdiff_q_0;
        lp.vdiffd0    = Vdiff_d_0;
        lp.vdiffq0_c  = Vdiff_q_c;
        lp.vdiffd0_c  = Vdiff_d_c;
        lp.etheta0    = theta0;

        lp_stat{stat} = lp;
    end
end