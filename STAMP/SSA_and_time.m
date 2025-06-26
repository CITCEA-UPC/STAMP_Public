%% CLEAR WORKING ENVIRONMENT and SET PATHS

close all;
clearvars 
clc
path(pathdef)
addpath(genpath(pwd))

%% SET INPUT DATA
    full_running_time = tic;

% Case name as in Excel files
    caseName = 'WSCC_SG_GFOR_GFOL'; 

% Relative path to the Folder for storing results
    path_results = '02_results\'; 

% Set power-flow source (0: Excel, 1: STAMP POWER FLOW, 2: MATPOWER, 3: MATACDC) 
    fanals = 2; 

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
    tic
    run PF_results.m;
    pf_time=toc;

% Update operation point of generator elements
    run update_OP.m

% Compute reference angle (delta_slk)
    run delta_slack_acdc.m
        
%% GENERATE STATE-SPACE MODEL
% Generate AC & DC NET State-Space Model
    tic
    run generate_NET_with_Qneg.m

%% Generate generator units State-Space Model
    run generate_elements.m
    linear_subsystem_time=toc;
%% SELECT GLOBAL INPUT & OUTPUTS

% Display dialog box to select inputs/outputs 
    %run display_io.m  

% Or select inputs/outputs with commands 
     input = {'NET.Rld1'};
     select_all_outputs;

%% CONNECT FULL STATE-SPACE MODEL
    tic
    ss_sys = connect(l_blocks{:}, input, output);
    connect_ss_model_time=toc;

%% SMALL-SIGNAL ANALYSIS

% Eigenvalues
     tic
     T_EIG   = FEIG(ss_sys,[0.25 0.25 0.25],'o',true)
     calculate_eig_time=toc;

%% DISPLAY COMPUTATION TIMES
    
    finish_running_time = toc(full_running_time);
    
    msg1=strcat('The time for the power flow calculation is:',num2str(pf_time),'s');
    msg2=strcat('The time for the linear subsystem model construction is:', num2str(linear_subsystem_time), 's');
    msg3=strcat('The time for the linear subsystem model interconnection is:', num2str(connect_ss_model_time), 's');
    msg4=strcat('The time for eigenvalue calculation and plotting is:', num2str(calculate_eig_time), 's');
    msg5=strcat('The total running time is:', num2str(finish_running_time), 's');

    disp(msg1)
    disp(msg2)
    disp(msg3)
    disp(msg4)
    disp(msg5)