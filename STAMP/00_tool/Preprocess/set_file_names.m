%% SET FILE NAMES

% Create excel file names

excel    = [caseName '.xlsx']; 
data_sg  = [caseName '_data_sg.xlsx'];
data_vsc = [caseName '_data_vsc.xlsm'];
data_ipc = [caseName '_data_ipc.xlsx'];
data_shunt = [caseName '_data_shunt.xlsx'];

% Simulink models names
linear    =  [caseName '_LIN'];
nonlinear = [caseName];

% Flag to indicate if T_case should be used (Obsolete)
shared_power = 0;