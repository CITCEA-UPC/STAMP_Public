%% Create list to store subsystems blocks

l_blocks = {};

%% Convert X,B columns to L,C

[T_NET,T_trafo,T_load,T_TH] = xb2lc(T_NET,T_trafo,T_load,T_TH,T_global.f_Hz);

%% AC Grid:

% Generate the Connectivity Matrix and the Table of nodes for the AC grid:
[connect_mtx, connect_mtx_PI, connect_mtx_rl, T_nodes] = generate_general_connectivity_matrix(T_NET,T_trafo, T_load, T_TH, T_SG, T_STATCOM, T_VSC, T_IPC, T_b2b, T_user);

%% RL NET: trafos and TH

% Manage transformers:
[connect_mtx_rl,T_NET_wTf,T_trafo_missing] = add_trafo(T_trafo,connect_mtx_rl,T_NET,connect_mtx_PI);

% rl_T_nodes: includes nodes where any RL/trafo is connected + "Additional TH" nodes
rl_T_nodes = generate_specific_T_nodes_v2(connect_mtx_rl,T_nodes);

% Manage TH: 
[connect_mtx_rl,T_NET_wTf_wTh,T_TH_missing,rl_T_nodes] = add_TH(T_TH,connect_mtx_rl,connect_mtx_PI,T_NET_wTf,rl_T_nodes); 

% rl_T_NET: includes RL lines + trafos connected to any RL + "Additional TH" lines
rl_T_NET = get_specific_NET(connect_mtx_rl,T_NET_wTf_wTh);

%% RL NET:

% PI T_nodes:
PI_T_nodes = generate_specific_T_nodes_v2(connect_mtx_PI,T_nodes);

% Generates the State-Space of the AC RL grid:
rl_NET = generate_general_rl_NET_v3(connect_mtx_rl, rl_T_nodes, PI_T_nodes, rl_T_NET, T_global);

if ~(isempty(rl_NET.SS))
    l_blocks{end+1} = rl_NET.SS;
end

%% PI NET:

% Generates the State-Space of the AC PI grid:

PI_T_NET = get_specific_NET(connect_mtx_PI,T_NET);
PI_NET = generate_general_PI_NET(connect_mtx_PI, connect_mtx_rl,PI_T_nodes,T_NET,T_trafo_missing,T_global);

if ~(isempty(PI_NET))
    l_blocks{end+1} = PI_NET;
end

%% Trafos:

% Trafos connected to ALL PI-lines ("missing") are added

for tf=1:1:size(T_trafo_missing,1)
    trafo = build_trafo(T_trafo_missing.number(tf),T_trafo_missing.bus_from(tf),T_trafo_missing.bus_to(tf),T_trafo_missing.R(tf),T_trafo_missing.X(tf),T_global.f_Hz(1));
    l_trafo{tf} = trafo;
    l_blocks{end+1} = trafo;
end
clear tf trafo

%% TH:

% TH connected to ANY PI-line ("missing") are added

for th=1:1:size(T_TH_missing,1)
    thevenin = build_TH(T_TH_missing.bus(th),T_TH_missing.number(th),T_global.f_Hz(1),T_TH_missing.R(th),T_TH_missing.L(th));
    l_Thevenin{th} = thevenin;
    l_blocks{end+1} = thevenin;
end
clear th thevenin

%% Loads:

% Generates the State-Space for each load based on their connection to either ANY PI-line or ALL RL-lines

% For loads in PI-lines:
%   - RL or R load: R can be either be a CONSTANT or an INPUT variable
% For loads in RL-lines:
%   - R load: R can be either be a CONSTANT or an INPUT variable
%   - RL load: R can only be a CONSTANT. R as INPUT is not implemented yet

for l=1:1:size(T_load,1)

    bus = T_load{l,"bus"};    

    if bus <= size(connect_mtx_PI,1) && sum(connect_mtx_PI(bus,:)) % Load is connected to any PI-line
          
          if T_load.L(l) == 0 % R Load 
            %load = build_Load_in_PI_R(T_load.bus(l),T_load.number(l),T_load.R(l)); % R is CONSTANT 
            load = build_Load_in_PI_R_addR(T_load.bus(l),T_load.number(l),T_load.R(l),results.bus(results.bus.bus==bus,:),delta_slk); % R is INPUT          
          else % RL load
             %load = build_Load_in_PI(T_load.bus(l),T_load.number(l),T_global.f_Hz(1),T_load.R(l),T_load.L(l)); % R is CONSTANT           
             load = build_Load_in_PI_addR(T_load.bus(l),T_load.number(l),T_global.f_Hz(1),T_load.R(l),T_load.L(l),results.bus(results.bus.bus==bus,:),delta_slk); % R is INPUT
          end
    
    else % Load is connected to all RL-lines
        
        if T_load.L(l) == 0 % R Load 
            load = build_Load_in_rl_R_addR(T_load.bus(l),T_load.number(l),connect_mtx_rl,T_nodes,T_global.f_Hz(1),T_load.R(l),results.bus(results.bus.bus==bus,:),delta_slk); % R is INPUT        
        else % RL Load
            load = build_Load_in_rl(T_load.bus(l),T_load.number(l),connect_mtx_rl,T_nodes,T_global.f_Hz(1),T_load.R(l),T_load.L(l)); % R is CONSTANT 
        end

    end
    l_load{l} = load;
    l_blocks{end+1} = load;

end
clear l bus load

%% DC Grid

if ~(isempty(T_DC_NET))
    % Generates the Connectivity Matrix and the table of nodes for the DC grid:
    [DC_connect_mtx, T_DC_nodes] = generate_DC_connectivity_matrix(T_DC_NET, T_IPC);
    % Generates a graph of the DC grid:
    %DC_NET_graph = generate_NET_graph(DC_connect_mtx);
    % Generates the State-Space of the DC grid:
    DC_NET = generate_DC_NET(DC_connect_mtx,T_DC_nodes,T_DC_NET,T_IPC);
    warning('DC NET is being implemented')
    l_blocks{end+1} = DC_NET;
end

%% Display system graph

graphPlot = generate_NET_graph(T_trafo, T_DC_NET, T_NET, T_nodes, T_load, T_TH, T_SG, T_VSC,T_IPC, T_user);
