function [connect_mtx_rl,T_NET,T_TH_missing,rl_T_nodes] = add_TH(T_TH,connect_mtx_rl,connect_mtx_PI,T_NET,rl_T_nodes)
    nodeACmax   = max(size(connect_mtx_rl,1),size(connect_mtx_PI,1))+1;
    number      = max(T_NET.number)+1;
    index_table = size(rl_T_nodes,1)+1;
    missing     = [];

    for th = 1:1:size(T_TH,1)
        % If the Thevenin is ONLY connected to RL/trafo lines
        if sum(connect_mtx_rl(T_TH.bus(th),:))>0 && sum(connect_mtx_PI(T_TH.bus(th),:))==0
          connect_mtx_rl(T_TH.bus(th),nodeACmax) = 1;
          connect_mtx_rl(nodeACmax,T_TH.bus(th)) = 1;
          T_NET(end+1,:) = {number,T_TH.Area(th),T_TH.SyncArea(th),T_TH.bus(th),nodeACmax,T_TH.R(th), T_TH.X(th), 0, 1, T_TH.L(th), 0};
          rl_T_nodes{index_table,1} = nodeACmax;
          rl_T_nodes{index_table,2} = {join(['Additional TH',num2str(T_TH.number(th))])};
          index_table = index_table+1;
          nodeACmax                 = nodeACmax+1;
          number                    = number+1;

        % If the Thevenin is connected to ANY PI-line
        else
          missing = [missing,th];
        end

    end

    T_TH_missing = T_TH(missing,:);
    
end