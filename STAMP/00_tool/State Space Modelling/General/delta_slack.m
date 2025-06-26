%% CALCULATE delta_slk

% Variable name for w_slack (ref)
    REF_w  = 'REF_w';

% Find slack bus
T_global.delta_slk = zeros(height(T_global),1);
T_global.num_slk = zeros(height(T_global),1);

for idx = 1:height(T_global)
    element = T_global{idx,"ref_element"}{:};
    bus = T_global{idx,"ref_bus"};

    switch element
        case 'TH'                
            num_slk = 0;
            %num_slk     = T_TH.number(T_TH.bus == bus_slk);
            delta_slk = 0;
            %delta_slk   = th_slack(T_TH(num_slk,:), T_global{idx,"Sb"});
        case 'SG'
            num_slk     = T_SG.number(T_SG.bus == bus);
            delta_slk   = sg_slack(T_SG(num_slk,:), T_global{idx,"Sb"});
        case 'GFOR'
            num_slk     = T_VSC.number(T_VSC.bus == bus & strcmp(T_VSC.mode,'GFOR'));
            delta_slk   = gfor_slack(T_VSC(num_slk,:), T_global{idx,"Sb"});
        case 'user'
            num_slk     = T_user.number(T_user.bus == bus);
            T_XX        = T_user(num_slk,:);
            elementName = T_XX.element{:};
            % WRITE YOUR OWN CODE
        otherwise
            warning('Could not find reference bus')
    end
    T_global{idx,'num_slk'} = num_slk;
    T_global{idx,'delta_slk'} = delta_slk;

    % assuming only one slack in the system
    element_slk{idx} = T_global{1,"ref_element"}{:};
    bus_slk{idx} = T_global{1,"ref_bus"};
    num_slk{idx} = T_global{1,'num_slk'};
    delta_slk{idx} = T_global{1,'delta_slk'};
end    
                                                       


