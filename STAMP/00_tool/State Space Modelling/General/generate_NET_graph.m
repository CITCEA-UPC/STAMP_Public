function  graphPlot = generate_NET_graph(T_trafo, T_DC_NET, T_NET, T_nodes, T_load, T_shunt, T_TH, T_SG, T_VSC,T_IPC, T_user, fanals)

    % AC lines:
    n_nodes = max([max(T_NET.bus_from),max(T_NET.bus_to)]);
    connect_mtx_rl = zeros(n_nodes);
    connect_mtx_PI = zeros(n_nodes);
    for i=1:1:size(T_NET.bus_from,1)
        if T_NET.B(i)==0
            connect_mtx_rl(T_NET.bus_from(i),T_NET.bus_to(i))=1;
        else
            connect_mtx_PI(T_NET.bus_from(i),T_NET.bus_to(i))=1;
        end
    end
    connect_mtx_rl = connect_mtx_rl + connect_mtx_rl';
    connect_mtx_PI = connect_mtx_PI + connect_mtx_PI';
    Connectivity_Matrix = connect_mtx_PI+connect_mtx_rl;

    %Add DC lines
    for i=1:1:size(T_DC_NET,1)
        busf = T_DC_NET.bus_from(i);
        bust = T_DC_NET.bus_to(i);

        [num_ipc,pos] = find(T_IPC.busdc==busf);
        busf_ac = T_IPC.bus(num_ipc);
        [num_ipc,pos] = find(T_IPC.busdc==bust);
        bust_ac = T_IPC.bus(num_ipc);
        Connectivity_Matrix(busf_ac,bust_ac) = 1;
        Connectivity_Matrix(bust_ac,busf_ac) = 1;

        T_DC_NET.busac_from(i) = busf_ac;
        T_DC_NET.busac_to(i) = bust_ac;
    end

    Madj = Connectivity_Matrix;

    if any(Madj,'all')

        % Add lines corresponding to trafos
        for tf = 1:height(T_trafo)
            Madj(T_trafo.bus_from(tf), T_trafo.bus_to(tf)) = 1;
            Madj(T_trafo.bus_to(tf), T_trafo.bus_from(tf)) = 1;
        end
    
        % for dc = 1:height(T_DC_NET)
        %     Madj(T_DC_NET.bus_from(dc), T_DC_NET.bus_to(dc)) = 1;
        %     Madj(T_DC_NET.bus_to(dc), T_DC_NET.bus_from(dc)) = 1;
        % end
    
        nodes = (1:size(Madj, 1))';
        nodeNames = string(1:size(Madj, 1));
        
        NET_graph = graph(Madj, nodeNames);
    
        n_in = zeros(length(nodes), 1);
        n_out = zeros(length(nodes), 1);
        nodes = (1:size(Madj, 1))';
        
        for idx_node = 1:length(nodes)
            currentNode = nodes(idx_node);
            n_in(idx_node) = sum(T_NET.bus_to == currentNode);
            n_out(idx_node) = sum(T_NET.bus_from == currentNode);
        end
    
        T_degree = table(nodes, degree(NET_graph), n_in, n_out, 'VariableNames', ["bus", "degree", "n_in", "n_out"]);
        T_degree = sortrows(T_degree, {'degree'}, {'descend'});
    
        % Add nodes corresponding to generating units 
        for bus = 1:height(T_nodes)
            for col = 2:width(T_nodes)
                if ~ismissing(T_nodes{bus, col})
                    if ~contains(T_nodes{bus, col},'IPC')
                        NET_graph = addnode(NET_graph, T_nodes{bus, col});
                        NET_graph = addedge(NET_graph, num2str(bus), T_nodes{bus, col}, 1);
                        nodeNames(end + 1) = T_nodes{bus, col};

                        if contains(T_nodes{bus, col},"VSC") % display type of converter
                            num = regexp(T_nodes{bus, col},'\d*','match');
                            mode = T_VSC{T_VSC.number == str2num(num),"mode"};
                            nodeNames(end) = T_nodes{bus, col} + ' (' + mode{:} +')';
                        end
                    end
                 
                end
            end
        end

        %change node names if a IPC is connected there
        for i = 1:1:size(T_IPC,1)
            bus_ac = T_IPC.bus(i);
            nodeNames(bus_ac) = ['IPC ',num2str(T_IPC.number(i))];
        end
    
        graphPlot = plot(NET_graph, "NodeLabel", nodeNames, 'Layout', 'force', 'MarkerSize', 4, 'LineWidth', 1, 'UseGravity', true, 'NodeColor', 'k');

        % Graph colouring
       

        % PI-lines
        color_pi = [0.9020    0.6549    0.1608]; % orange
        nodes_in = T_NET{T_NET.C ~= 0, "bus_from"};
        nodes_out = T_NET{T_NET.C ~= 0, "bus_to"};        
        highlight(graphPlot, nodes_in, nodes_out,'EdgeColor', color_pi,'LineWidth',1.5)

        % HVDC-lines
        color_hvdc = [0.6350 0.0780 0.1840]; % dark red
        
        if fanals==3
            nodes_in = T_DC_NET.busac_from;
            nodes_out = T_DC_NET.busac_to;        
            highlight(graphPlot, nodes_in, nodes_out,'EdgeColor', color_hvdc,'LineWidth',1.5)
        end

        % RL-lines
        color_rl = [0.9294    0.4745    0.2784]; %light red
        nodes_in = T_NET{T_NET.C == 0, "bus_from"};
        nodes_out = T_NET{T_NET.C == 0, "bus_to"};        
        highlight(graphPlot, nodes_in, nodes_out,'EdgeColor', color_rl,'LineWidth',1.5)

        % Trafos
        color_tf = [0.5608    0.3882    0.0392]; %brown
        nodes_in = T_trafo{T_trafo.C == 0, "bus_from"};
        nodes_out = T_trafo{T_trafo.C == 0, "bus_to"};        
        highlight(graphPlot, nodes_in, nodes_out,'EdgeColor', color_tf,'LineWidth',1.5)

        % Loads
        if ~isempty(T_load)
            color = [0.8510    0.3255    0.0980]; %dark red
            id = cell(1,height(T_load));
            for num = 1:height(T_load)
                id{num} = ['Load ' num2str(num)];
            end
            idx = findnode(NET_graph,id); %find nodes  
            highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
            highlight(graphPlot, cellstr(string(T_load.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
        end

        % Shunt elements
        if ~isempty(T_shunt)
            color = [0.8510    0.3255    0.0980]; %dark red
            id = cell(1,height(T_shunt));
            for num = 1:height(T_shunt)
                id{num} = ['Shunt ' num2str(num)];
            end
            idx = findnode(NET_graph,id); %find nodes  
            highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
            highlight(graphPlot, cellstr(string(T_shunt.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
        end

        % TH
        if ~isempty(T_TH)
            color = [0.2784    0.6275    0.9294]; % blue
            id = cell(1,height(T_TH));
            for num = 1:height(T_TH)
                id{num} = ['TH ' num2str(num)];
            end        
            idx = findnode(NET_graph,id); %find nodes
            highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
            highlight(graphPlot,  cellstr(string(T_TH.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
        end

        % SG
        if ~isempty(T_SG)
            color = [0.5020    0.5020    0.5020]; %gray
            id = cell(1,height(T_SG));
            for num = 1:height(T_SG)
                id{num} = ['SG ' num2str(num)];
            end
            idx = findnode(NET_graph,id); %find nodes  
            highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
            highlight(graphPlot,  cellstr(string(T_SG.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
        end

        % VSC
        if ~isempty(T_VSC)
            color = [0.3922    0.8314    0.0745]; %green
            id = cell(1,height(T_VSC));
            for num = 1:height(T_VSC)
                id{num} = ['VSC ' num2str(num)];
            end
            idx = findnode(NET_graph,id); %find nodes    
            highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
            highlight(graphPlot,  cellstr(string(T_VSC.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
        end

        % IPC
         if ~isempty(T_IPC)
               color = [1 0 0]; %red
               id = cell(1,height(T_IPC));
               for num = 1:height(T_IPC)
                   id{num} = num2str(T_IPC.bus(num));
               end
               idx = findnode(NET_graph,id); %find nodes   
               highlight(graphPlot, idx,'NodeColor', color, 'Marker', "square", 'MarkerSize', 6, 'NodeLabelColor', color)
        %       %highlight(graphPlot,  cellstr(string(T_IPC.bus)), id, 'EdgeColor', color, 'LineStyle', ':','LineWidth',1.5)
         end

        % Legend
        hold on;                                      %to retain current plot
        ax1=plot(NaN,NaN,'Color',color_pi); %plotting invisible points of desired colors
        ax2=plot(NaN,NaN,'Color',color_hvdc); %plotting invisible points of desired colors
        ax3=plot(NaN,NaN,'Color',color_rl); %plotting invisible points of desired colors
        ax4=plot(NaN,NaN,'Color',color_tf); %plotting invisible points of desired colors
        [~, hobj, ~, ~] = legend([ax1,ax2,ax3,ax4],'PI-line','HVDC-line','RL-line','Trafo','Location','best','FontSize',8); %adding the legend     
        hl = findobj(hobj,'type','line');
        set(hl,'LineWidth',1.5);
        hl = findobj(gcf,'Type','Legend');
        hl.ItemTokenSize = [13,1];  
        legend boxoff 

    end
end

%% Code for testing Layout Algorithms

%{

 T_degree = table(nodeNames',degree(NET_graph),'VariableNames',["bus","degree"]);
 sortrows(T_degree,{'degree'},{'descend'})

 bus = 49
 N = neighbors(NET_graph,bus); 
 H = subgraph(NET_graph, unique([bus; N; neighbors(NET_graph,69); neighbors(NET_graph,54)]));
 
 figure
    plot(H,'Layout','layered','MarkerSize',4,'LineWidth',1)


figure
    graphPlot = plot(NET_graph,"NodeLabel",nodeNames,'Layout','force','MarkerSize',4,'LineWidth',1,'UseGravity',true);

figure
    p = plot(NET_graph,"NodeLabel",nodeNames,'Layout','layered','MarkerSize',4,'LineWidth',1)
    p.XData = 1:1:118;
    p.YData = 1:1:118;

%}
