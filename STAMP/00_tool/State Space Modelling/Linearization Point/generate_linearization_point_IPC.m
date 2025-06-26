%% Calculates the linearization point per each IPC
function lp_ipc = generate_linearization_point_IPC(T_IPC, T_global, delta_slk_ll)

lp_ipc = cell(1,height(T_IPC));

    for ipc = 1:1:height(T_IPC)

        Sipc = T_IPC.Sb(ipc);       % IPC rated power, IPC power base  
        Sb  = T_global.Sb(T_global.Area == T_IPC.Area(ipc)); % System power base

        delta_slk = delta_slk_ll(T_IPC.Area(ipc));
        %Data from the power-flow
        theta   = T_IPC.theta(ipc)*pi/180 - delta_slk;
        V       = T_IPC.V(ipc)/sqrt(3)*sqrt(2); 
        P       = T_IPC.P(ipc)*(Sb/Sipc);
        Q       = T_IPC.Q(ipc)*(Sb/Sipc);
        Vdc     = T_IPC.Vdc(ipc);
        Pdc     = T_IPC.Pdc(ipc);
        Isum    = Pdc/(3*Vdc);

        Rc = T_IPC.Rc(ipc);
        Lc = T_IPC.Lc(ipc);
        Ra = T_IPC.Ra(ipc);
        La = T_IPC.La(ipc);
        Req = Rc + Ra/2;
        Leq = Lc + La/2;
        w = 2*pi*T_IPC.fb(ipc);

        %Liniearization point calculation:
        %AC side:
        %AC voltage IPC reference:
        V_q_c = V;
        V_d_c = 0;
        
        %AC voltage NET reference:
        Rotation = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        V_0 = Rotation*[V_q_c ; V_d_c];
        V_q_0 = V_0(1);
        V_d_0 = V_0(2);
        
        %AC current IPC reference:
        is_q_c = (2*P)/(3*V_q_c);
        is_d_c = (2*Q)/(3*V_q_c);
        
        %AC current NET reference:
        is_0 = Rotation*[is_q_c ; is_d_c];
        is_q_0 = is_0(1);
        is_d_0 = is_0(2);
        
        %Vdiff voltage IPC reference:
        Vdiff_q_c = V_q_c + Req*is_q_c + w*Leq*is_d_c;
        Vdiff_d_c = V_d_c + Req*is_d_c - w*Leq*is_q_c;

        %Vdiff voltage NET reference:
        Vdiff_q_0 = V_q_0 + Req*is_q_0 + w*Leq*is_d_0 ;
        Vdiff_d_0 = V_d_0 + Req*is_d_0 - w*Leq*is_q_0;
        
        %DC side:        
        %Vsum:
        Vsum = Vdc - 2*Ra*Isum - 2*La*Isum;
        
        %Generate output:
        lp.vnq0 = V_q_0;
        lp.vnd0 = V_d_0;
        lp.vnq0_c = V_q_c;
        lp.vnd0_c = V_d_c;
        lp.idiffq0 = is_q_0;
        lp.idiffd0 = is_d_0;
        lp.idiffq0_c = is_q_c;
        lp.idiffd0_c = is_d_c;
        lp.vdiffq0 = Vdiff_q_0;
        lp.vdiffd0 = Vdiff_d_0;
        lp.vdiffq0_c = Vdiff_q_c;
        lp.vdiffd0_c = Vdiff_d_c;
        lp.isum0 = Isum;
        lp.vsum0 = Vsum;
        lp.vDC0 = Vdc;
        lp.etheta0 = theta;

        lp_ipc{ipc} = lp;
    end
end