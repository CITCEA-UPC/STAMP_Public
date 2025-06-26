% Generate state-space of generator elements: SG, VSC, MMC, user

%% SYNCHRONOUS GENERATOR

lp_SG    = generate_linearization_point_SG(T_SG, T_global, delta_slk);
l_blocks = generate_SG_pu(l_blocks,T_SG, lp_SG, T_global, num_slk, element_slk, REF_w);

%% VSC

%lp_VSC   = generate_linearization_point_VSC(T_VSC, T_global, delta_slk);
lp_VSC_peak   = generate_linearization_point_VSC_PEAK(T_VSC, T_global, delta_slk);
%l_blocks = generate_VSC_pu_with_functions(l_blocks,T_VSC, lp_VSC, T_global, num_slk, element_slk, REF_w);
l_blocks = generate_VSC_pu_with_functions_PEAK(l_blocks,T_VSC, lp_VSC_peak, T_global, num_slk, element_slk, REF_w);
%l_blocks = generate_VSC_pu(l_blocks,T_VSC, lp_VSC, T_global, num_slk, element_slk, REF_w);

%% IPC
lp_IPC = generate_linearization_point_IPC(T_IPC, T_global, delta_slk);
l_blocks = generate_IPC_pu_with_functions(l_blocks,T_IPC, lp_IPC, T_global, num_slk, element_slk, REF_w);

%% Shunt Elements
% NO linearization is necessary since passive filters are linear
l_blocks = generate_SHUNT_pu_with_functions(l_blocks,T_shunt, T_global);

%% User
[l_blocks T_user] = generate_user(l_blocks,T_user);

% Go through all rows in T_user and call the dedicated script for each element type

%     % Arrays to store linearization points
%     lp_SG = {};
%     lp_GFOL = {};
%     lp_GFOR = {};
%     
%     for idx = 1:height(T_user)    
%             T_XX = T_user(idx,:);
%             elementName = T_XX.element{:};   
%             switch elementName
%                 case 'SG' 
%                     run generate_SG_pu.m      % generate SS    
%                     l_blocks{end+1} = SS_SG;  % append ss to l_blocks   
%                 case 'GFOL'    
%                     run generate_GFOL.m         % generate SS    
%                     l_blocks{end+1} = SS_GFOL;  % append ss to l_blocks   
%                 case 'GFOR' 
%                     run generate_GFOR.m         % generate SS    
%                     l_blocks{end+1} = SS_GFOR;  % append ss to l_blocks   
%             end
%     end
