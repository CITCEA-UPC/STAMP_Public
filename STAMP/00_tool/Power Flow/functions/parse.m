function g = parse(g, T_nodes, T_global, T_NET, T_DC_NET, T_trafo, T_load, T_TH, T_SG, T_STATCOM, T_VSC, T_MMC_Pac_GFll, T_MMC_Vdc_GFll, T_b2b, T_user)

    % Add branch type into AC-NET and T_trafo     

        T_trafo.type = cellstr(repmat("",height(T_trafo),1)); 
        for idx = 1:height(T_trafo)
            T_trafo.type(idx) = {'trafo'}; 
        end       
        T_NET.type = cellstr(repmat("",height(T_NET),1)); 
        T_NET.type(T_NET.B == 0) = {'RL'};
        T_NET.type(T_NET.B ~= 0) = {'PI'};

    % Combine AC-NET and T_trafo into --> T_branch       

        T_branch = outerjoin(T_NET, T_trafo,'MergeKeys',true);
        %T_branch.tap_module(isnan(T_branch.tap_module)) =  1;
        %T_branch.tap_angle(isnan(T_branch.tap_angle))   =  0;
        T_branch.tap_module = ones(height(T_branch),1); %force one
        T_branch.tap_angle  = zeros(height(T_branch),1); %force zero
        
    % Add Loads = 0 in empty buses 

        for node = 1:height(T_nodes)
            if ismissing(T_nodes(node,2:width(T_nodes)))
                T_load = [T_load; {height(T_load)+1, node, 0, 0, 0, 0, {'RX'}, 1, 0}];     
            end
        end                     

    % Add DC cable parameters to b2b
    
        for nb2b = 1:height(T_b2b)
            bus1 = T_b2b.bus1(nb2b);
            bus2 = T_b2b.bus2(nb2b);
            
            MMC1 = T_MMC_Pac_GFll;
            MMC2 = T_MMC_Vdc_GFll;
            if (T_MMC_Pac_GFll.NodeAC == bus2); MMC1 = T_MMC_Vdc_GFll; MMC2 = T_MMC_Pac_GFll; end

            T_b2b.Vdc(nb2b) = T_MMC_Vdc_GFll.vDC;
            T_b2b.R1(nb2b)  = MMC1.Rc + MMC1.Ra/2;
            T_b2b.X1(nb2b)  = (MMC1.Lc + MMC1.La/2)*2*pi*MMC1.f;
            T_b2b.R2(nb2b)  = MMC2.Rc + MMC2.Ra/2;
            T_b2b.X2(nb2b)  = (MMC2.Lc + MMC2.La/2)*2*pi*MMC2.f;
            T_b2b.Rdc(nb2b) = 1/(1/T_DC_NET.Ra + 1/T_DC_NET.Rb + 1/T_DC_NET.Rc) + 2*MMC1.Ra + 2*MMC2.Ra;
        end

    % Save data tables

    g.glob    = T_global;
    g.branch  = T_branch;
    g.load    = T_load;
    g.th      = T_TH;
    g.sg      = T_SG;
    g.stat    = T_STATCOM;
    g.vsc     = T_VSC;
    g.b2b     = T_b2b;
    g.user    = T_user;
 
    
    g = parse_global(g);
    g = parse_branch(g);
    g = parse_init(g);

    [g, g.bus_th]   = parse_xx(g, g.th,  g.bus_th);   
    [g, g.bus_sg]   = parse_xx(g, g.sg,  g.bus_sg);    
    [g, g.bus_stat] = parse_xx(g, g.stat,g.bus_stat);  
    [g, g.bus_vsc]  = parse_xx(g, g.vsc, g.bus_vsc);  
    [g, g.bus_user] = parse_xx(g, g.user,g.bus_user); 

    g = parse_b2b(g); 
    g = parse_load(g);
    g = parse_final(g);

end

