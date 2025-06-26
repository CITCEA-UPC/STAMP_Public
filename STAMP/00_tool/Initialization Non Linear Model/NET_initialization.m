%% Initialization NET

% Lines
init_line = generate_initialization_line(T_NET,results);

% DC Lines
if fanals==3
    init_DCline = generate_initialization_DCline(T_DC_NET,results_dc);
end

% Trafos
init_trafo = generate_initialization_line(T_trafo,results);

% TH
init_TH = generate_initialization_TH(T_TH,results,T_global.f_Hz(1));

% Loads
init_load = generate_initialization_Load(T_load,results);

% Shunt
init_shunt = generate_initialization_Shunt(T_shunt,results);

% % B2B 
% init_MMC_Pac = generate_initialization_MMCs(T_MMC_Pac_GFll,results);
% init_MMC_Vdc = generate_initialization_MMCs(T_MMC_Vdc_GFll,results);

% % STATCOM
% init_STATCOM = generate_initialization_STATCOM(T_STATCOM,results);

% SG
[init_SG, initMachineBlocks] = generate_initialization_SG(T_SG,T_global);

% VSC
init_VSC = generate_initialization_VSC(T_VSC,T_global);

% IPC
if fanals==3
    init_IPC = generate_initialization_IPC(T_IPC,T_global);
end

% User
init_user = generate_initialization_user(T_user,delta_slk);

% User-defined models initialization

% Create cell for each type of model
% T_count = groupcounts(T_user,"element");
% for idx = 1:height(T_count)
%     type = T_count.element{idx};
%     switch type
%     end
% end


%% Blocks with optional TRAFO

% load_system(nonlinear);
% 
% blocks = {T_MMC_Pac_GFll; T_MMC_Vdc_GFll; T_STATCOM};
% names = {'MMC-Pac-'; 'MMC-Vdc-'; 'STATCOM-'}; %SG, VSC should be included
% nonlinear_trafos(nonlinear,blocks, names)
% 
% clear blocks names
