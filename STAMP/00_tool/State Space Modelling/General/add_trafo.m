function [connect_mtx_rl,T_NET,T_trafo_missing] = add_trafo(T_trafo, connect_mtx_rl, T_NET, connect_mtx_PI)

    % 1 -  Check if there are trafos in series
    %      I don't remember the reason but code does not work well if there
    %      are trafos in series (i.e. not connected to any line in the "inner"
    %      bus between them)
    if sum(ismember(T_trafo.bus_from, T_trafo.bus_to)) || sum(ismember(T_trafo.bus_to, T_trafo.bus_from))
        buses_series = unique(T_trafo.bus_from(ismember(T_trafo.bus_from, T_trafo.bus_to)));
        buses_AC_NET = [T_NET.bus_from; T_NET.bus_to];

        if any((~ismember(buses_series,buses_AC_NET))) %check if any line connected to the bus_series.    
            bs = buses_series((~ismember(buses_series,buses_AC_NET)));
            fprintf('The following trafos are in series. They are put as RL lines in AC-NET: \n')
            for idx = 1:length(bs)
                inner_bus = bs(idx);
                rows = [T_trafo(T_trafo.bus_from == inner_bus,:); T_trafo(T_trafo.bus_to == inner_bus,:)];
                % Put the series trafos in T_NET
                T_NET = [T_NET;  rows(:,T_NET.Properties.VariableNames)];
                % Remove the series trafos from T_trafo
                T_trafo(ismember(T_trafo.number,rows.number),:) = []; 
                disp(rows)
            end
            % restore T_NET, T_trafo numbers
            T_NET.number = [1:height(T_NET)]';
            T_NET.number = [1:height(T_NET)]';
        end
    end

    % 2 - Expand connect_mtx with zeros in order to match the size defined by the highest bus in T_trafo

    max_bus_trafo = max([T_trafo.bus_from; T_trafo.bus_to]);
    max_bus_rl_net = size(connect_mtx_rl,1);
    if max_bus_trafo > max_bus_rl_net
        connect_mtx_rl(end:max_bus_trafo,end:max_bus_trafo) = 0;
    end

    max_bus_pi_net = size(connect_mtx_PI,1);
    if max_bus_trafo > max_bus_pi_net
        connect_mtx_PI(end:max_bus_trafo,end:max_bus_trafo) = 0;
    end

    % 3 - Add trafos to connectivity matrix  

    missing = [];
    for tf = 1:1:size(T_trafo,1)

        % A) Trafos that are connected to an RL line in ANY bus are added to connect_mtx_RL and to T_NET
        if sum(connect_mtx_rl(T_trafo.bus_from(tf),:))>0 || sum(connect_mtx_rl(T_trafo.bus_to(tf),:))>0

            connect_mtx_rl(T_trafo.bus_from(tf),T_trafo.bus_to(tf))=1;
            connect_mtx_rl(T_trafo.bus_to(tf),T_trafo.bus_from(tf))=1;
            T_NET(end+1,:) = {height(T_NET)+1,T_Trafo.Area(tf),T_Trafo.SyncArea(tf),T_trafo.bus_from(tf),T_trafo.bus_to(tf),T_trafo.R(tf),T_trafo.X(tf),0,1,T_trafo.L(tf),T_trafo.C(tf)};

        % B) Trafos connected between PI lines in BOTH buses --> "missing"
        % are not added to any connect_mtx because are built as independent elements
        elseif sum(connect_mtx_PI(T_trafo.bus_from(tf),:))>0 && sum(connect_mtx_PI(T_trafo.bus_to(tf),:))>0
            missing = [missing,tf];

        % C) The Trafo is connected to a PI line and to a terminal element in one of the buses   
        % the terminal element cannot be a current source !!
        else
            missing = [missing,tf];
            warning("Ensure that Trafo %d is connected to a voltage source.",T_trafo.number(tf))
            warning("SGs and VSCs are current sources --> You can add a Load to the bus.")
            warning("THs are current sources -->  You can add the trafo as an RL in AC-NET.")
        end
    end
    T_trafo_missing = T_trafo(missing,:);

end