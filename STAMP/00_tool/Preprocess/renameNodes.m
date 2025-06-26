function T_XX = renameNodes(T_XX,itsLine,T_busEquiv)

    for idx_row = 1:height(T_XX)
        if itsLine
            node_raw               = T_XX.bus_from(idx_row);
            T_XX.bus_from(idx_row) = T_busEquiv{T_busEquiv.Bus_raw == node_raw,"Bus_tool"};
            node_raw               = T_XX.bus_to(idx_row);
            T_XX.bus_to(idx_row)   = T_busEquiv{T_busEquiv.Bus_raw == node_raw,"Bus_tool"};
        else
            node_raw           = T_XX.bus(idx_row);
            T_XX.bus(idx_row)  = T_busEquiv{T_busEquiv.Bus_raw == node_raw,"Bus_tool"};
        end
    end

end