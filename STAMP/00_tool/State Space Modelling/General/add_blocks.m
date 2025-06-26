function [l_blocks] = add_blocks(l_blocks, T_MMC_Pac_GFll, T_MMC_Vdc_GFll, T_STATCOM, T_SG, T_Rsnub, connect_mtx_PI, T_nodes)

    for idx = 1:height(T_MMC_Pac_GFll)
        l_blocks{end+1} = T_MMC_Pac_GFll{idx,"ss"}{:};
    end

    for idx = 1:height(T_MMC_Vdc_GFll)
        l_blocks{end+1} = T_MMC_Vdc_GFll{idx,"ss"}{:};
    end

    for idx = 1:height(T_STATCOM)
        l_blocks{end+1} = T_STATCOM{idx,"ss"}{:};
    end

    for idx = 1:height(T_SG)
        l_blocks{end+1} = T_SG{idx,"ss"}{:};
        
        % Rsnub is only included if SG is the only element in a RL bus
        bus = T_SG{idx,"bus"};
        if ~sum(connect_mtx_PI(bus,:)) && ismissing(T_nodes{bus,2})
            l_blocks{end+1} = T_Rsnub{idx,"ss"}{:};
        end
    end

end