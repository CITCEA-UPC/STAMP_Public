%% Reads all the data from the main excel file and generates tables with it    

    % USE OF GLOBAL VARIABLES
    % All tables are defined as global variables. To use them as global inside a file, 
    % include the following line at the top of the file or inside the function:
    %   setup_globals; % Import global variables names
    % You can still pass the variables "as always" to the functions
    
    setup_globals; % Import global variables names

    sheets = sheetnames(excel);

    T_global        = readtable(excel,'Sheet','global');        %global data table 
    if ismember('global_DC',sheets)
        T_global_DC     = readtable(excel,'Sheet','global_DC');     %global DC data table 
    end
    T_NET           = readtable(excel,'Sheet','AC-NET');        %Net table
    T_DC_NET        = readtable(excel,'Sheet','DC-NET');        %DC Net table
    T_trafo         = readtable(excel,'Sheet','trafo');         %Transformer table
    T_load          = readtable(excel,'Sheet','load');          %Load table
    if ismember('SHUNT',sheets)
        T_shunt          = readtable(excel,'Sheet','SHUNT');          %Shunt table
    end
    T_TH            = readtable(excel,'Sheet','TH');            %TH table
    T_SG            = readtable(excel,'Sheet','SG');            %SG table
    T_VSC           = readtable(excel,'Sheet','VSC');           %VSC table: GFOL, GFOR, STATCOM
    if ismember('IPC',sheets)
        T_IPC           = readtable(excel,'Sheet','IPC');           %MMC table: MMC_Pac_Gfll, MMC_Vdc_Gfll
    end
    T_b2b           = readtable(excel,'Sheet','b2b');           %b2b table
    T_PF            = readtable(excel,'Sheet','PF');            %buses data and power-flow Vm,theta results (if fanals=0)
    if ismember('PF_DC',sheets)
        T_PF_DC         = readtable(excel,'Sheet','PF_DC');         %buses data and power-flow Vm,theta results (if fanals=0)
    end
    if ismember('user',sheets)
        T_user          = readtable(excel,'Sheet','user');          %user-custom additional elements table
    end

    % Simulation parameters
    if any(contains(sheets,'sim'))
        T_sim = readtable(excel,'Sheet','sim'); 
        sim_config.Type    = T_sim.Type{:};
        sim_config.Ts      = T_sim.Ts_s;
        sim_config.Tsim    = T_sim.Tsim_s;
        sim_config.solver  = T_sim.solver;
        sim_config.tstep   = T_sim.tstep_s;
        sim_config.Tsample = T_sim.Tsample_s;
        sim_config.DR      = T_sim.step_factor;
    end


    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % THIS TO BE DELETED ONCE OLD T_MMC NAMES & T_STATCOM HAVE BEEN REPLACED IN OLD SCRIPTS 
    T_MMC_Pac_GFll = T_IPC; 
    T_MMC_Vdc_GFll = T_IPC;
    T_STATCOM      = T_VSC;
    
    T_MMC_Pac_GFll(:,:) = []; 
    T_MMC_Vdc_GFll(:,:) = [];
    T_STATCOM(:,:)      = [];
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Stores original topology (t=0) for updating the state of breakers 

    T_NET_0           = T_NET;
    T_DC_NET_0        = T_DC_NET;
    T_trafo_0         = T_trafo;
    T_shunt_0          = T_shunt;
    T_load_0          = T_load;
    T_TH_0            = T_TH;
    T_SG_0            = T_SG;
    T_VSC_0           = T_VSC;
    T_IPC_0           = T_IPC;
    T_user_0          = T_user;
    T_PF_0            = T_PF;
    T_PF_DC_0         = T_PF_DC;
