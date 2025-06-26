%% ARRANGE INPUT DATA TO APPROPRIATE FORMAT

% 0) Force bus number starting at 1    
    
    if T_PF{1,'bus'} ~= 1

        disp('Buses will be renumbered to start at 1.')

        % Keep original bus numbering
        T_bus_equiv = array2table(T_PF.bus, 'VariableNames',{'bus'});
        T_bus_equiv.bus_tool = [1:height(T_PF)]';

        % Replace bus numbers
        joinedTable = join(T_global,T_bus_equiv,'LeftKeys','ref_bus','RightKeys','bus');
        T_global.ref_bus = joinedTable.bus_tool;

        T_NET           = rename_buses_NET(T_bus_equiv, T_NET);
        T_DC_NET        = rename_buses_NET(T_bus_equiv, T_DC_NET);
        T_trafo         = rename_buses_NET(T_bus_equiv, T_trafo);
        T_load          = rename_buses(T_bus_equiv, T_load);
        T_shunt          = rename_buses(T_bus_equiv, T_shunt);
        T_TH            = rename_buses(T_bus_equiv, T_TH);
        T_SG            = rename_buses(T_bus_equiv, T_SG);
        T_VSC           = rename_buses(T_bus_equiv, T_VSC);
        T_MMC           = rename_buses(T_bus_equiv, T_MMC);
        T_user          = rename_buses(T_bus_equiv, T_user);
        T_PF            = rename_buses(T_bus_equiv, T_PF);
    
        T_NET_0           = rename_buses_NET(T_bus_equiv, T_NET_0);
        T_DC_NET_0        = rename_buses_NET(T_bus_equiv, T_DC_NET_0);
        T_trafo_0         = rename_buses_NET(T_bus_equiv, T_trafo_0);
        T_load_0          = rename_buses(T_bus_equiv, T_load_0);
        T_TH_0            = rename_buses(T_bus_equiv, T_TH_0);
        T_SG_0            = rename_buses(T_bus_equiv, T_SG_0);
        T_VSC_0           = rename_buses(T_bus_equiv, T_VSC_0);
        T_MMC_0           = rename_buses(T_bus_equiv, T_MMC_0);
        T_user_0          = rename_buses(T_bus_equiv, T_user_0);
        T_PF_0            = rename_buses(T_bus_equiv, T_PF_0);

    end
    

% 1) Ensure lines numbering in ascending order

    T_NET.number     = [1:height(T_NET)]';
    T_NET_0.number   = [1:height(T_NET_0)]';
    T_trafo.number   = [1:height(T_trafo)]';
    T_trafo_0.number = [1:height(T_trafo_0)]';
    T_load.number   = [1:height(T_load)]';
    T_load_0.number = [1:height(T_load_0)]';

% 2) Ensure bus_from < bus_to 

    T_NET = reorder_buses_lines(T_NET);
    T_NET_0 = reorder_buses_lines(T_NET_0);
    T_trafo = reorder_buses_lines(T_trafo);
    T_trafo_0 = reorder_buses_lines(T_trafo_0);

% 3) Ensure only one line between two buses

    % Remove parallel lines
    [T_NET, numDuplicated] = remove_parallel_lines(T_NET);
    if ~isempty(numDuplicated); disp(['Lines number ' num2str(numDuplicated') ' were removed because they were in parallel with another.']); end
    T_NET_0 = remove_parallel_lines(T_NET_0);

    % Remove parallel trafos
    [T_trafo, numDuplicated] = remove_parallel_lines(T_trafo);
    if ~isempty(numDuplicated); disp(['Trafos number ' num2str(numDuplicated') ' were removed because they were in parallel with another.']); end
    T_trafo_0 = remove_parallel_lines(T_trafo_0);

    % Remove parallel lines-trafos
    [T_NET, T_trafo, numDuplicatedTrafo] = remove_parallel_lines_and_trafos(T_NET, T_trafo);
    if ~isempty(numDuplicatedTrafo); disp(['Trafos number ' num2str(numDuplicatedTrafo') ' were removed because they were in parallel with a line.']); end
    [T_NET_0, T_trafo_0] = remove_parallel_lines_and_trafos(T_NET_0, T_trafo_0);   


% 4) No capacitive loads
    % 
    % for idx = 1:height(T_load)
    %     if T_load.type(idx) == "PQ"           
    %         num = T_load{idx,"number"};
    %         if T_load.Q(idx) < 0
    %             T_load.Q(idx) = abs(T_load.Q(idx));
    %             disp(['Load number ' num2str(num) ' had negative reactive power.'])
    %         end
    %     end
    % end

% 5) Add multiple loads in same bus

    [T_load, numDuplicated] = remove_parallel_loads(T_load);
    if ~isempty(numDuplicated); disp(['Loads number ' num2str(numDuplicated') ' were removed because they were in same bus than another.']); end

%% FUNCTIONS

% RENAME BUSES

function T_XX = rename_buses(T_bus_equiv, T_XX)
    % Join for 'bus'
    joinedTable = join(T_XX,T_bus_equiv,'LeftKeys','bus','RightKeys','bus');
    T_XX.bus = joinedTable.bus_tool;
end

function T_XX = rename_buses_NET(T_bus_equiv, T_XX)
    % Join for 'bus_from'
    joinedTable = join(T_XX,T_bus_equiv,'LeftKeys','bus_from','RightKeys','bus');
    T_XX.bus_from = joinedTable.bus_tool;
  
    % Join for 'bus_from'
    joinedTable = join(T_XX,T_bus_equiv,'LeftKeys','bus_to','RightKeys','bus');
    T_XX.bus_to = joinedTable.bus_tool;
end



% REORDER BUSES

function T_XX = reorder_buses_lines(T_XX)
    for line = 1:1:size(T_XX,1)    
        if T_XX.bus_from(line) > T_XX.bus_to(line)
            bus_from = T_XX.bus_from(line);
            bus_to = T_XX.bus_to(line);
            T_XX{line,"bus_from"} = bus_from;
            T_XX{line,"bus_to"} = bus_to;
            disp(['Order of buses changed in Line number ' num2str(T_XX{line,"number"}) '.'])
        end
    end
end


% REMOVE PARALLEL LINES

function [T_XX_clean, numDuplicated] = remove_parallel_lines(T_XX)

    % [T_XX_clean, numDuplicated] = remove_parallel_lines(T_XX)
    %
    % Removes rows in T_XX that have equal bus_from and bus_to values
    % (parallel lines). The first occurrence is kept, and the equivalent
    % R,X,B values are calculated. 
    %
    % 'numDuplicated' is an array indicating the deleted lines numbers.

    T_XX_clean = T_XX; %to not mess with the old row indices

    % Find rows with duplicate 'bus_from' and 'bus_to' values
    [~,idxUnique,~]=unique((T_XX(:,["bus_from", "bus_to"])),'rows');  
    idxDuplicated = setdiff(1:height(T_XX),idxUnique); 
    numDuplicated = T_XX.number(idxDuplicated);
        
    % Iterate over the duplicate groups
    while ~isempty(idxDuplicated)

        idx_dup = idxDuplicated(1);
        i = T_XX.bus_from(idx_dup);
        j = T_XX.bus_to(idx_dup);

        % Get the rows of the current group
        group_rows = T_XX((T_XX.bus_from == i) & (T_XX.bus_to == j), :);

        % Calculate the equivalent values for 'R', 'X', and 'B'
        r_values = group_rows.R;
        x_values = group_rows.X;
        b_values = group_rows.B;
        
        % Calculate the equivalent values using the parallel combination formula
        z_values = r_values + 1i*(x_values);
        equivalent_z = 1 / sum(1 ./ z_values);
        equivalent_r = real(equivalent_z);
        equivalent_x = imag(equivalent_z);
        equivalent_b = sum(b_values);
        
        % Update the original rows of the group with the new values
        num2keep = group_rows{1,"number"};
        num2remove = group_rows{2:end,"number"};
        T_XX_clean((T_XX_clean.number == num2keep), {'R', 'X', 'B'}) = {equivalent_r, equivalent_x, equivalent_b};

        % Drop the duplicated rows
        T_XX_clean(ismember(T_XX_clean.number,num2remove), :) = [];

        % Remove the duplicated indices that belong to the current group
        idx2remove = find(ismember(T_XX.number,num2remove)==1);
        idxDuplicated = idxDuplicated(~ismember(idxDuplicated,idx2remove));
    end
    
    % Reset the 'number' column
    T_XX_clean.number = [1:height(T_XX_clean)]';
end


% REMOVE PARALLEL LINES AND TRAFOS

function [T_NET, T_trafo_clean, numDuplicatedTrafo] = remove_parallel_lines_and_trafos(T_NET, T_trafo)

    % [T_NET_clean, T_trafo_clean, numDuplicatedTrafo]  = remove_parallel_lines_and_trafos(T_NET, T_trafo)
    %
    % Removes rows trafos that have equal bus_from and bus_to values with a
    % lines (parallel). The line is kept and the trafo is removed, and the equivalent
    % R,X,B values are calculated. 
    %
    % 'numDuplicatedTrafo' is an array indicating the deleted trafos numbers.

    T_trafo_clean = T_trafo; %to not mess with the old row indices
    T_lines = [T_NET;  T_trafo(:,T_NET.Properties.VariableNames)];

    % Find rows with duplicate 'bus_from' and 'bus_to' values
    [~,idxUnique,~]=unique((T_lines(:,["bus_from", "bus_to"])),'rows');  
    idxDuplicated = setdiff(1:height(T_lines),idxUnique); 
    numDuplicatedTrafo = T_lines.number(idxDuplicated);
        
    % Iterate over the duplicate groups
    while ~isempty(idxDuplicated)

        idx_dup = idxDuplicated(1);
        i = T_lines.bus_from(idx_dup);
        j = T_lines.bus_to(idx_dup);

        % Get the rows of the current group
        group_rows = T_lines((T_lines.bus_from == i) & (T_lines.bus_to == j), :);

        % Calculate the equivalent values for 'R', 'X', and 'B'
        r_values = group_rows.R;
        x_values = group_rows.X;
        b_values = group_rows.B;
        
        % Calculate the equivalent values using the parallel combination formula
        z_values = r_values + 1i*(x_values);
        equivalent_z = 1 / sum(1 ./ z_values);
        equivalent_r = real(equivalent_z);
        equivalent_x = imag(equivalent_z);
        equivalent_b = sum(b_values);
        
        % Update the original rows of the group with the new values
        num2keep = group_rows{1,"number"};
        num2remove = group_rows{2:end,"number"};
        T_NET((T_NET.number == num2keep), {'R', 'X', 'B'}) = {equivalent_r, equivalent_x, equivalent_b};

        % Drop the duplicated rows
        T_trafo_clean(ismember(T_trafo_clean.number,num2remove), :) = [];

        % Remove the duplicated indices that belong to the current group
        idx2remove = find(ismember(T_lines.number,num2remove)==1);
        idxDuplicated = idxDuplicated(~ismember(idxDuplicated,idx2remove(2:end)));
    end
    
    % Reset the 'number' column
    T_trafo_clean.number = [1:height(T_trafo_clean)]';
end


% REMOVE PARALLEL LOADS

function [T_XX_clean, numDuplicated] = remove_parallel_loads(T_XX)

    % [T_XX_clean, numDuplicated] = remove_parallel_lines(T_XX)
    %
    % Removes rows in T_XX that have equal bus values (multiple loads in same bus). 
    % The first occurrence is kept, and the equivalent R,X,B values are calculated. 
    %
    % 'numDuplicated' is an array indicating the deleted loads numbers.

    T_XX_clean = T_XX; %to not mess with the old row indices

    % Find rows with duplicate 'bus_from' and 'bus_to' values
    [~,idxUnique,~]=unique((T_XX(:,["bus"])),'rows');  
    idxDuplicated = setdiff(1:height(T_XX),idxUnique); 
    numDuplicated = T_XX.number(idxDuplicated);
        
    % Iterate over the duplicate groups
    while ~isempty(idxDuplicated)

        idx_dup = idxDuplicated(1);
        i = T_XX.bus(idx_dup);

        % Get the rows of the current group
        group_rows = T_XX(T_XX.bus == i, :);

        % Calculate the equivalent load values

        % Check load types within group            
        if isequal(group_rows.type,repmat("PQ",height(group_rows),1))

            % if PQ
            p_values = group_rows.P;
            q_values = group_rows.Q;      
            % Calculate the equivalent values using the parallel combination formula
            equivalent_P = sum(p_values);
            equivalent_Q = sum(q_values);
            % Update the original rows of the group with the new values
            num2keep = group_rows{1,"number"};
            num2remove = group_rows{2:end,"number"};
            T_XX_clean((T_XX_clean.number == num2keep), {'P', 'Q'}) = {equivalent_P, equivalent_Q};

        elseif isequal(group_rows.type,repmat("RX",height(group_rows),1))

            % if RX        
            r_values = group_rows.R;
            x_values = group_rows.X;
            % Calculate the equivalent values using the parallel combination formula
            z_values = r_values + 1i*(x_values);
            equivalent_z = 1 / sum(1 ./ z_values);
            equivalent_r = real(equivalent_z);
            equivalent_x = imag(equivalent_z);
            % Update the original rows of the group with the new values
            num2keep = group_rows{1,"number"};
            num2remove = group_rows{2:end,"number"};
            T_XX_clean((T_XX_clean.number == num2keep), {'R', 'X'}) = {equivalent_r, equivalent_x};

        else 

            % if there are PQ and RX, first convert to PQ at V=1.0pu
            for idx_group=1:height(group_rows)
                if group_rows.type(idx_group) == "RX"
                    idx = find(T_XX_clean.number == group_rows.number(idx_group),1);
                    T_XX_clean.type(idx) = {'PQ'};
                    T_XX_clean.P(idx) = abs(1/T_XX_clean.R(idx));
                    T_XX_clean.Q(idx) = 1/T_XX_clean.X(idx);
                    if isinf(T_XX_clean.P(idx)); T_XX_clean.P(idx) = 0; end
                    if isinf(T_XX_clean.Q(idx)); T_XX_clean.Q(idx) = 0; end
                end
            end

            % then, as PQ
            group_rows = T_XX_clean(T_XX_clean.bus == i, :);
            p_values = group_rows.P;
            q_values = group_rows.Q;      
            % Calculate the equivalent values using the parallel combination formula
            equivalent_P = sum(p_values);
            equivalent_Q = sum(q_values);
            % Update the original rows of the group with the new values
            num2keep = group_rows{1,"number"};
            num2remove = group_rows{2:end,"number"};
            T_XX_clean((T_XX_clean.number == num2keep), {'P', 'Q'}) = {equivalent_P, equivalent_Q};

        end        

        % Drop the duplicated rows
        T_XX_clean(ismember(T_XX_clean.number,num2remove), :) = [];

        % Remove the duplicated indices that belong to the current group
        idx2remove = find(ismember(T_XX.number,num2remove)==1);
        idxDuplicated = idxDuplicated(~ismember(idxDuplicated,idx2remove));
    end
    
    % Reset the 'number' column
    T_XX_clean.number = [1:height(T_XX_clean)]';
end
