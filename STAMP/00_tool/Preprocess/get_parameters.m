%% COMPUTE SYSTEM BASE VALUES

% The pu base values of the system (RMS, L-L) are calculated and added to
% the T_global table. 

% Areas can have different power bases, but different base frequencies feature 
% is not implemented yet. Hence, base frequency from first Area is taken as 
% base frequency for all the system (in delta_slack.m and generate_NET.m)

for idx_area = 1:height(T_global)
    T_global.Sb(idx_area) = T_global.Sb_MVA(idx_area)*1e6;
    T_global.Vb(idx_area) = T_global.Vb_kV(idx_area)*1e3; %RMS L-L
    T_global.Zb(idx_area) = (T_global.Vb(idx_area)^2)/T_global.Sb(idx_area);
    T_global.Ib(idx_area) = T_global.Sb(idx_area)/T_global.Vb(idx_area); %RMS line
end

T_global.fb = T_global.f_Hz; 

%% GET AND CALCULATE PARAMETERS OF GENERATOR UNITS

% In this section, data in parameters excel file (data_XX) is read and 
% added to the corresponding element table (T_XX).

% Synchronous generators

    T_SG = add_area(T_SG, T_PF);
    T_SG = generate_parameters_SG(T_SG, T_global, data_sg);

% VSC converters 

    T_VSC = add_area(T_VSC, T_PF);
    T_VSC = generate_parameters_VSC(T_VSC, T_global, data_vsc);

% IPC converters

    % T_MMC = add_area(T_MMC, T_PF);
    T_IPC = generate_parameters_IPC(T_IPC, T_global, data_ipc);

% Shunt elements (passive filters etc)

   T_shunt = generate_parameters_SHUNT(T_shunt, T_global, data_shunt);

% Back to back

    % T_b2b = generate_parameters_b2b(T_b2b,T_global);

% user models

    % write your own function ...