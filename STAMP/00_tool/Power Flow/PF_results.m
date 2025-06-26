%% POWER-FLOW CALCULATION
format long
% The function version of this script is "get_powerFlow_results" and is
% found in "/Power Flow" folder. It is more elegant but difficulties the
% user interaction with the powerflow calculation

% - "results" is a struct with fields:
        % bus:      bus, Vm, theta, V, type
        % PQ_lines: bus_from, bus_to, Pf, Qf, Pt, Qt
        % load:     number, bus, P (cons), Q (cons)
        % th:       number, bus, P (gen), Q (gen)
        % sg:       number, bus, P (gen), Q (gen)
        % stat      number, bus, P (gen), Q (gen) --> to be removed
        % vsc:      number, bus, P (gen), Q (gen)
        % user:     number, bus, P (gen), Q (gen)
        % b2b:      bus1, bus2, P1, Q1, P2, Q2

% Import global variables names
setup_globals; 

%% Selection of power-flow engine

if fanals == 0      % Read power-flow results from excel 

    disp("Power-flow results are read from excel file")    

    results.bus = T_PF;  
    results.load = T_load;
    results.th = T_TH;
    results.sg = T_SG;
    results.vsc = T_VSC;
    results.user = T_user;

elseif fanals == 1  % Run built-in power-flow (Fanals)   

    disp("Running Fanals power-flow")    

    %Convert X,B columns to R,L
    [T_NET,T_trafo,T_load,T_TH] = xb2lc(T_NET,T_trafo,T_load,T_TH,T_global.f_Hz(1));
    
    % Generates the Connectivity Matrix and the Table of nodes for the AC grid:
    [connect_mtx, connect_mtx_PI, connect_mtx_rl, T_nodes] = generate_general_connectivity_matrix(T_NET,T_trafo, T_load, T_TH, T_SG, T_STATCOM, T_VSC, T_MMC_Pac_GFll,T_MMC_Vdc_GFll, T_b2b, T_user);
    
    % Compute power-flow
    results = powerFlow(T_nodes, T_global, T_DC_NET, T_NET,T_trafo, T_load, T_TH, T_SG, T_STATCOM, T_VSC, T_MMC_Pac_GFll,T_MMC_Vdc_GFll, T_b2b, T_user);


elseif fanals == 2  % Run MATPOWER    

    disp("Running MATPOWER power-flow")

    % Option for Reading from raw file (not implemented yet)
    % raw = '01_data\raw\IEEE118busREE_Winter Solved_mod_PQ.raw';
    % define_constants;
    % [mpc, warnings] = psse2mpc(raw, 1, 34, 34); %drama

    % Generate case from Excel
    mpc = parse_excel2mpc(shared_power);
    % mpc.bus(T_VSC.type==1,2)=1; %%% Hack to change vsc generators to PQ
    % Compute power-flow
    [~, bus, gen, ~, ~, ~] = runpf(mpc);
    disp("To change bus type, run: [results,mpc] = change_bus_type(mpc) or manually edit 'mpc' struct")
    results = matpower2table(bus, gen);

elseif fanals == 3  % Run MATACDC    

    disp("Running MATACDC power-flow")

    % Option for Reading from raw file (not implemented yet)
    % raw = '01_data\raw\IEEE118busREE_Winter Solved_mod_PQ.raw';
    % define_constants;
    % [mpc, warnings] = psse2mpc(raw, 1, 34, 34); %drama

    % Generate case from Excel
    mpc_ac = parse_excel2mpc(shared_power);
    if isempty(T_DC_NET)
        disp("No DC NET mpc_dc set to []")
        mpc_dc = [];
    else
        mpc_dc = parse_excel2mpc_dc();
    end
    
    % mpc.bus(T_VSC.type==1,2)=1; %%% Hack to change vsc generators to PQ
    % Compute power-flow
    [results_ac, results_dc] = runacdcpf(mpc_ac,mpc_dc);
    bus = results_ac.bus;
    gen = results_ac.gen;
    disp("To change bus type, run: [results,mpc] = change_bus_type(mpc) or manually edit 'mpc' struct")
    results = matpower2table(bus, gen);

    bus_dc = results_dc.busdc;
    ipc = results_dc.convdc;

    results_dc = matpowerdc2table(bus_dc,ipc);

end


