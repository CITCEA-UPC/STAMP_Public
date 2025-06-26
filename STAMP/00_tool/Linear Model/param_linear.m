% Define case study for linear model simulation

if ~newSys
    warning('Ensure that the variables selected for the state-space match the outputs of the linear simulation.')
end

tstep_lin = 0.05; %0.05;
Tsim_lin = sim_config.Tsim-sim_config.tstep;

% Get disturbance type
    var_name = split(input,'.');

    if  contains(input,'NET.Rl') % load input
        num = regexp(var_name{2},'\d*','match');
        bus = T_load{T_load.number == str2double(num),"bus"};
        Rload_init = T_load.R(T_load.bus == bus);
        DR = sim_config.DR;
        delta_u = -DR/(1+DR)*Rload_init;

    elseif  contains(input,'TH') || contains(input, 'NET') % TH input
        if contains(input,'NET')
            num='1';
        else
            num = regexp(var_name{1},'\d*','match');
            num = num{:};
        end
        bus = T_TH{T_TH.number == str2double(num),"bus"};   
        DR = sim_config.DR;
        delta_u = init_TH{str2double(num)}.Vmag*DR/(sqrt(3)/sqrt(2));

    elseif  contains(input,'SG') % SG
        if contains(input,'Pref')
            num = regexp(var_name{1},'\d*','match');
            num = num{:};
            bus = T_SG{T_SG.number == str2double(num),"bus"};   
            DR = sim_config.DR;
            delta_u = init_SG{str2double(num)}.Pm*DR;
        end
    end


