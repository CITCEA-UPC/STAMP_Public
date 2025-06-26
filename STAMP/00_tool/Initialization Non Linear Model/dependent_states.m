% -------------------------------------------------------------------------
% Code to disable initialization of dependent states
% -------------------------------------------------------------------------

% PI-lines

% Capacitor initial voltage

    % If connected to another PI_line, only initialize 3 (first) + 1 (next) caps
    for idx = 1:height(T_nodes)
        if (T_nodes.Node(idx) < size(connect_mtx_PI,1)) && (sum(connect_mtx_PI(idx,:)) >=2)  % 2 PI lines in bus
            list_lines = T_NET((T_NET.bus_from==idx | T_NET.bus_to==idx) & T_NET.B~=0,:); %list of all PI-lines connected to the node
            % we initialize 3 caps from the first line and 1 in the next ones
            for idx_line = 2:height(list_lines)
                num = list_lines.number(idx_line);
                if list_lines{idx_line,"bus_from"} == idx
                    init_cap = [1 0 0 1 1 1];
                    set_param([nonlinear '/Line-' num2str(num)],'set_C0',['[' num2str(init_cap) ']']);
                elseif list_lines{idx_line,"bus_to"} == idx
                    init_cap = [1 1 1 1 0 0];
                    set_param([nonlinear '/Line-' num2str(num)],'set_C0',['[' num2str(init_cap) ']']);
                end    
            end
        end
    end

% Inductor initial current

    % Inside cycles, initialize 2 of 3 inductors in all PI-lines except one

    % Generate NET Graph
        Madj = connect_mtx;
        % Add lines corresponding to trafos & DC_NET
            for trafo_idx = 1:height(T_trafo)
                    Madj(T_trafo.bus_from(trafo_idx), T_trafo.bus_to(trafo_idx)) = 1;
                    Madj(T_trafo.bus_to(trafo_idx), T_trafo.bus_from(trafo_idx)) = 1;
            end
            
    %         for dc=1:1:height(T_DC_NET)
    %             Madj(T_DC_NET.bus_from(dc),T_DC_NET.bus_to(dc))=1;
    %             Madj(T_DC_NET.bus_to(dc),T_DC_NET.bus_from(dc))=1;
    %         end
            
        nodeNames = string(1:size(Madj,1));
        NET_graph = graph(Madj,nodeNames);
    
        % Find cycles
        cycles = allcycles(NET_graph,'MaxNumCycles',1000);
        T_lines          = [T_NET(:,["number","bus_from","bus_to"]); T_trafo(:,["number","bus_from","bus_to"])];
        for idx = 1:size(cycles,1)
            cycle = cycles{idx};
            nodeA = str2double(cycle{end-1});
            nodeB = str2double(cycle{end});
            %numline = T_lines{(T_lines.bus_from == nodeA & T_lines.bus_to == nodeB) | (T_lines.bus_from == nodeB & T_lines.bus_to == nodeA), "number"}; % TRAFOS AND RL INIT MASK NOT IMPLEMENTED YET
            numline = T_NET{((T_NET.bus_from == nodeA & T_NET.bus_to == nodeB) | (T_NET.bus_from == nodeB & T_NET.bus_to == nodeA)) & T_NET.B~=0, "number"}; % TRAFOS AND RL INIT MASK NOT IMPLEMENTED YET
            if numline
                set_param([nonlinear '/Line-' num2str(numline)],'set_iL0','1');
            end
        end

%[x0,states] = power_init(nonlinear)