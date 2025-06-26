%% CLEAR WORKING ENVIRONMENT and SET PATHS

close all;
clearvars 
% clc
path(pathdef)
addpath(genpath(pwd))

%% SET INPUT DATA

% Case name as in Excel files
    caseName = 'IEEE39'; 

% Relative path to the Folder for storing results
    path_results = '02_results\'; 

% Set power-flow source (0: Excel, 1: Fanals, 2: MATACDC) 
    fanals = 2; 

% Flag to indicate if T_case should be used (REE)
    shared_power = 0;

%% READ GRID TOPOLOGY DATA
 
% Create excel files and simulink models names 
    run set_file_names.m

% Read excel file and generate tables of grid elements
    run read_data.m

% Clean input data
    run preprocess_data.m

%% POWER-FLOW
 
% Update state of switches (open/close lines)
    set_breaker_state('line',1,'close')

% Get Power-Flow results
    run PF_results.m;

% Update operation point of generator elements
    run update_OP.m
        
%% READ PARAMETERS DATA

% Get parameters of generator units from excel files & compute pu base
    run get_parameters.m

% Compute reference angle (delta_slk)
    run delta_slack_acdc.m

ii=1;
factor = [1:1:10]./(2*pi*60);

for d = factor

T_VSC.ki_P=ones(9,1)*0;
T_VSC.ki_Q=ones(9,1)*0;

T_VSC.kp_P=ones(9,1)*0;
T_VSC.kp_Q=ones(9,1)*0;

T_VSC.ki_s=ones(9,1)*0;
T_VSC.kp_s=ones(9,1)*0;

% T_VSC.Ltr = ones(9,1)*d;
% T_VSC.Lc = ones(9,1)*d;

T_VSC.Cac = ones(9,1)*d;

%% GENERATE STATE-SPACE MODEL

% Generate AC & DC NET State-Space Model
    %run generate_NET.m 
    run generate_NET_with_Qneg.m
% Generate generator units State-Space Model
    run generate_elements.m

%% BUILD FULL SYSTEM STATE-SPACE MODEL

% Script inputs/outputs
    input = {'NET.Rld1'};
    select_all_outputs

    %%% Save all device linear model for impedance analysis
    l_blocks_list{ii} = l_blocks;
    
    ss_sys{ii} = connect(l_blocks{:}, input, output);
    ii=ii+1;
% % or ... Display only variables in specified buses 
%     bus_in   = 12; %bus to apply disturbance
%     user_out =  [];
%     th_out   = [];
%     load_out = [12 14];
%     sg_out = [12 19];
%     vsc_out = [12 19];    
%     run display_io_reduced.m
%     ss_sys = connect(l_blocks{:}, input, output);

end

%% SMALL-SIGNAL ANALYSIS

get_sensitivy_eigenvalues_figure(ss_sys,factor)

% Eigenvalues
    T_EIG   = FEIG(ss_sys{end},[0.25 0.25 0.25],'o',true)
    % head(T_EIG)

    % Export T_EIG to excel
    % writetable(T_EIG, [path_results caseName '_EIG.xlsx'])

    % Save eigenavalue map figure
    % T_EIG   = FEIG(ss_sys,[0.25 0.25 0.25],'o',true); 
    % exportgraphics(gcf,[path_results caseName 'EIG.emf'])


% Participation factors
    % Obtain all participation factors
    T_modal = FMODAL(ss_sys{1});
    % Save participation factors map figrue
    % exportgraphics(gcf,[path_results caseName '_pf.emf'])

    % Obtain the participation factors for the selected modes
    % FMODAL_REDUCED(ss_sys,[1,2]); 

    % Obtain the participation factors >= x, for the selected mode
    % FMODAL_REDUCED_th(ss_sys,[1,2,4], 0.2);     

