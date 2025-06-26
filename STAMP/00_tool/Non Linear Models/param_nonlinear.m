% Set Nonlinear Simulation parameters

% Get disturbance type
    var_name = split(input,'.');

    if ~newSys
        disp('Remember to restore manually the step block from last simulation if you changed the disturbance, or delete and create a new model.')
    end

    if  contains(input,'NET.Rl') % load input

        % Compute disturbance value
        num = regexp(var_name{2},'\d*','match');
        num = num{:};
        bus = T_load{T_load.number == str2double(num),"bus"};
        Rload_init = T_load.R(T_load.bus == bus);
        DR = sim_config.DR;
        Rload_add = Rload_init/DR; %Rload_init/(1+DR);

        % Replace simulink block
        block       = [nonlinear '/Load-' num];
        loc         = get_param(block,'Position');
        orientation = get_param(block,'Orientation');
        delete_block(block); % delete old load block
        if T_load{T_load.number == str2double(num),"L"} == 0 && T_load{T_load.number == str2double(num),"C"} == 0
            add_block('myLibrary/Load_R_Rstep', block,'Position', loc,'Orientation',orientation); % new load block with Rstep
        elseif T_load{T_load.number == str2double(num),"L"} > 0
            add_block('myLibrary/Load_Rstep', block,'Position', loc,'Orientation',orientation); % new load block with Rstep
        elseif T_load{T_load.number == str2double(num),"C"} > 0
            add_block('myLibrary/LoadC_Rstep', block,'Position', loc,'Orientation',orientation); % new load block with Rstep
        end
        set_param(block,'num',num,'tstep','sim_config.tstep','Radd','Rload_add');

%         % Restore block
%         block       = [nonlinear '/Load-' num];
%         loc         = get_param(block,'Position');
%         orientation = get_param(block,'Orientation');
%         delete_block(block); % delete old load block
%         add_block('myLibrary/Load', block,'Position', loc,'Orientation',orientation,'num',num); 

    elseif  contains(input,'TH') || contains(input,'NET') % TH input
        if contains(input,'NET')
            num='1';
        else
            num = regexp(var_name{1},'\d*','match');
            num = num{:};
        end
        bus = T_TH{T_TH.number == str2double(num),"bus"};   
        DR = sim_config.DR;
        V1 = init_TH{str2double(num)}.Vmag*(1+DR);

        % Replace simulink block
        block       = [nonlinear '/TH-' num];
        loc         = get_param(block,'Position');
        orientation = get_param(block,'Orientation');
        delete_block(block); % delete old load block
        add_block('myLibrary/TH_step', block,'Position', loc,'Orientation',orientation)
        set_param(block,'num',num,'tstep','sim_config.tstep','V1','V1')
 
%         % Restore block
%         block       = [nonlinear '/TH-' num];
%         loc         = get_param(block,'Position');
%         orientation = get_param(block,'Orientation');
%         delete_block(block); % delete old load block
%         add_block('myLibrary/TH', block,'Position', loc,'Orientation',orientation,'num',num); 

    elseif  contains(input,'SG') % SG

            num = regexp(var_name{1},'\d*','match');
            num = num{:};
            bus = T_SG{T_SG.number == str2double(num),"bus"};   
        
            % Replace simulink block
            block       = [nonlinear '/SG-' num];
            loc         = get_param(block,'Position');
            orientation = get_param(block,'Orientation');
            delete_block(block); % delete old load block
            add_block('myLibrary/SG_step', block,'Position', loc,'Orientation',orientation); 
            set_param(block,'num',num,'step_var',var_name{2});
     
%             % Restore block
%             block       = [nonlinear '/SG-' num];
%             loc         = get_param(block,'Position');
%             orientation = get_param(block,'Orientation');
%             delete_block(block); % delete old load block
%             add_block('myLibrary/SG', block,'Position', loc,'Orientation',orientation,'num',num);        

    end


