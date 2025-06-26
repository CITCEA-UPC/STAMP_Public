% GENERATE STATE-SPACE MODEL OF SYNCHRONOUS GENERATOR IN PU
% SG base: peak phase-to-ground
% System base: rms line-to-line

function l_blocks = generate_SHUNT_pu_with_functions(l_blocks,T_shunt, T_global)

    %s = tf('s');
    
    for shunt_element = 1:1:size(T_shunt.number,1) 
    
        ss_list = {};      

        type = T_shunt.type{shunt_element};

        % Base values and conversions
        S_shunt  = T_shunt.Sn(shunt_element);       % SG rated power, SG power base  
        Sb   = T_global.Sb(T_global.Area == T_shunt.Area(shunt_element)); % System power base
        Zl2g = T_shunt.Zbpu_l2g(shunt_element);
        Sl2g = T_shunt.Sbpu_l2g(shunt_element);
        Vl2g = T_shunt.Vbpu_l2g(shunt_element);
        Vg2l = 1/Vl2g;
        Il2g = T_shunt.Ibpu_l2g(shunt_element);
        Ig2l = 1/Il2g;
        wb   = T_shunt.wb(shunt_element);
        area = T_shunt.Area(shunt_element);
        syncarea = T_shunt.SyncArea(shunt_element);
        state= T_shunt.state(shunt_element);
        type = T_shunt.type{shunt_element};

        num = shunt_element;
        bus = T_shunt.bus(shunt_element);
       
        switch type         
            % -------------------------------------------------------------
            case 'RLC'
                Rshunt=T_shunt.R(shunt_element);
                Lshunt=T_shunt.L(shunt_element);
                Cshunt=T_shunt.C(shunt_element);
                shunt_RLC = build_RLC(num,Rshunt, Lshunt, Cshunt, bus,wb,state,Vg2l,Il2g);
                
                l_blocks{end+1}=shunt_RLC;  

            % -------------------------------------------------------------
            case 'C-type'
                C1=T_shunt.C1(shunt_element);
                L=T_shunt.L(shunt_element);
                C2=T_shunt.C2(shunt_element);
                R=T_shunt.R(shunt_element);
                ctype = build_ctype(num,C1,L, C2, R, bus,wb,state,Vg2l,Il2g);

                l_blocks{end+1}=ctype;  

        end



    end
end