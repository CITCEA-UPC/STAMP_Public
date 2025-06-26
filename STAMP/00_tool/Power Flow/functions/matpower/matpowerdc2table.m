function results_f_dc = matpowerdc2table(bus_pf, ipc_pf)

    setup_globals; % Import global variables names

    baseMVA = T_global.Sb_MVA(1); %System power base in power-flow

    % results: struct with fields 'bus', 'ipc'
        
    % bus
    results_f_dc.busdc = T_PF_DC;
    results_f_dc.busdc.Vm  = bus_pf(:,5);
    results_f_dc.busdc.Pac = ipc_pf(:,4)/baseMVA;
    %results_f_dc.busdc.Pdc = ipc_pf(:,27)/baseMVA;%ipc_pf(:,29)/baseMVA.*sign(ipc_pf(:,27));
    results_f_dc.busdc.Pdc = bus_pf(:,4)/baseMVA;
    results_f_dc.busdc.Q = ipc_pf(:,5)/baseMVA;
    
    type = cell(height(T_PF_DC),1);
    for idx = 1:height(T_PF_DC)
        if ipc_pf(idx,2) == 1
                type{idx,1} = "P";
        elseif ipc_pf(idx,2) == 2
                type{idx,1} = "Slack";
        end
    end
     results_f_dc.busdc(:,"type") = cell2table(type);
end

