%% CLEAR WORKING ENVIRONMENT and SET PATHS

close all;
clearvars 
clc
path(pathdef)
addpath(genpath(pwd))

%% SET INPUT DATA

% Case name as in Excel files
    caseName = 'INELFE'; 

% Relative path to the Folder for storing results
    path_results = '02_results\'; 

% Set power-flow source (0: Excel, 1: STAMP POWER FLOW, 2: MATPOWER, 3: MATACDC) 
    fanals = 3; 

%% READ GRID TOPOLOGY DATA
 
% Create excel files and simulink models names 
    run set_file_names.m

% Read excel file and generate tables of grid elements
    run read_data.m

% Clean input data
    run preprocess_data.m

%% READ PARAMETERS DATA

% Get parameters of generator units from excel files & compute pu base
    run get_parameters.m

%% POWER-FLOW
 
% Update state of switches (open/close lines)
    set_breaker_state('line',1,'close')

% Get Power-Flow results
    run PF_results.m;

% Update operation point of generator elements
    run update_OP.m

% Compute reference angle (delta_slk)
    run delta_slack_acdc.m
        
%% GENERATE STATE-SPACE MODEL
% Generate AC & DC NET State-Space Model
    run generate_NET_with_Qneg.m

 %% Display system graph

graphPlot = generate_NET_graph(T_trafo, T_DC_NET, T_NET, T_nodes, T_load, T_shunt, T_TH, T_SG, T_VSC,T_IPC, T_user, fanals);

%% Generate generator units State-Space Model
    run generate_elements.m

%% SELECT GLOBAL INPUT & OUTPUTS

% Display dialog box to select inputs/outputs 
    run display_io.m  

% Or select inputs/outputs with commands 
     %input = {'NET.Rld1'};
     %select_all_outputs;

%% CONNECT FULL STATE-SPACE MODEL

    ss_sys = connect(l_blocks{:}, input, output);

    if ~isfile(['00_tool/Non Linear Models/models/' nonlinear '.slx'])
        newSys = 1;
    else
        newSys = 0;
    end

%% BUILD AND SIMULATE NON-LINEAR MODEL

% Initialization
     run NET_initialization.m

% Create simulink nonlinear model

    if newSys
        if fanals==3
            run NET_layout_FORCE_ACDC0.m % create AC/DC simulink nonlinear model 
        else
            run NET_layout_FORCE.m % create simulink nonlinear model
        end
    else
        open(nonlinear) % open already existing model
    end

% Avoid redundant initialization
    run dependent_states.m

% Set disturbance
    run param_nonlinear.m

% Simulate
    out_nolin = sim(nonlinear);  

    MsgBoxH = findall(0,'Type','figure','Name','Initial state conflict');
    close(MsgBoxH);

%% SIMULATE LINEAR MODEL

% Set Linear Simulation parameters
     run param_linear.m

% Create simulink linear model
     if ~isfile(['00_tool/Linear Model/models/' linear '.slx'])
         generate_linear(ss_sys,linear,tstep_lin,Tsim_lin,delta_u) % create simulink linear model
     else
         open(linear) % open already existing model       
     end

% Simulate

     %simConfig.Solver = "ode1";
     %simConfig.StopTime = "Tsim_lin";
     %simConfig.FixedStep="1e-08";
     %out_lin = sim(linear,simConfig);

     out_lin = sim(linear); 

%% VALIDATE LINEAR MODEL

run validate_linear.m

%% SMALL-SIGNAL ANALYSIS

% Eigenvalues
     T_EIG   = FEIG(ss_sys,[0.25 0.25 0.25],'o',true)

% Participation factors
  % Obtain all participation factors
     T_modal = FMODAL(ss_sys);
  % Obtain the participation factors for the selected modes
     FMODAL_REDUCED(ss_sys,[32,33,34,35]); 

  % Obtain the participation factors above a cutoff value for the selected mode
     FMODAL_REDUCED_th(ss_sys,[1,2], 0.2);     
