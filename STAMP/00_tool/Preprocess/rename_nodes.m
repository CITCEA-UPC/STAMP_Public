%% ARRANGE INPUT DATA TO APPROPIATE FORMAT

% Create table of equivalence between buses numbering
    bus_raw   = sort(unique([T_NET.bus_from; T_NET.bus_to; T_trafo.bus_from; T_trafo.bus_to; T_SG.bus; T_VSC.bus; T_user.bus; T_load.bus; T_TH.bus ...
                             T_MMC.NodeAC; T_MMC.NodeDC])); %T_b2b.bus1; T_b2b.bus2])); 
    T_busEquiv  = table(bus_raw, (1:length(bus_raw))', 'VariableNames',["Bus_raw","Bus_tool"]);

% Arrange lines according to new buses numbering
    T_NET    = renameNodes(T_NET,1,T_busEquiv);
    T_trafo  = renameNodes(T_trafo,1,T_busEquiv);
    T_load   = renameNodes(T_load,0,T_busEquiv);
    T_TH     = renameNodes(T_TH,0,T_busEquiv);
    T_SG     = renameNodes(T_SG,0,T_busEquiv);
    T_VSC    = renameNodes(T_VSC,0,T_busEquiv);
    % T_MMC  = renameNodes(T_MMC_Pac_GFll,0,T_busEquiv); % adapt for Node AC and DC
    % T_b2b  = renameNodes(T_b2b,0,T_busEquiv); % adapt for bus1 and bus2
    T_user   = renameNodes(T_user,0,T_busEquiv);

