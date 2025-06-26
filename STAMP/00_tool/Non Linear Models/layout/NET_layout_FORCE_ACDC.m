%% Generate NET graph

    Madj = connect_mtx;
    % Add lines corresponding to trafos & DC_NET
        for tf = 1:height(T_trafo)
                Madj(T_trafo.bus_from(tf), T_trafo.bus_to(tf)) = 1;
                Madj(T_trafo.bus_to(tf), T_trafo.bus_from(tf)) = 1;
        end
        
        for dc=1:1:height(T_DC_NET)
            Madj(T_DC_NET.bus_from(dc),T_DC_NET.bus_to(dc))=1;
            Madj(T_DC_NET.bus_to(dc),T_DC_NET.bus_from(dc))=1;
        end
        
    nodes         = (1:size(Madj,1))'; % CHNAGE to 1:length(T_busEquiv.Bus_tool);
    nodeNames = string(1:size(Madj,1));
    NET_graph = graph(Madj,nodeNames);


    n_in  = zeros(length(nodes),1); 
    n_out = zeros(length(nodes),1);
    nodes = (1:size(Madj,1))'; % CHNAGE to 1:length(T_busEquiv.Bus_tool);
    for idx_node = 1:length(nodes)
        currentNode = nodes(idx_node);
        n_in(idx_node) = sum(T_NET.bus_to == currentNode);
        n_out(idx_node) = sum(T_NET.bus_from == currentNode);
    end

    T_degree    = table(nodes,degree(NET_graph),n_in,n_out,'VariableNames',["bus","degree","n_in","n_out"]);
    T_degree    = sortrows(T_degree,{'degree'},{'descend'});
    
    % Add nodes corresponding to generating units    
        for bus = 1:height(T_nodes)
            for col = 2:width(T_nodes)
                if ~ismissing(T_nodes{bus,col})
                    NET_graph = addnode(NET_graph,T_nodes{bus,col});
                    NET_graph = addedge(NET_graph,num2str(bus),T_nodes{bus,col},1);
                    nodeNames(end+1) = T_nodes{bus,col};
                end
            end
        end

    graphPlot = plot(NET_graph,"NodeLabel",nodeNames,'Layout','force','MarkerSize',4,'LineWidth',1,'UseGravity',true);

% Store element coordinates in T_coord
    T_coord           = table('Size',[length(nodeNames) 4], 'VariableTypes', {'string','double','double','double'}, 'VariableNames',{'element','x','y','alloc'}); % table for coordinates
    T_coord.element   = nodeNames';
    T_coord.x         = 70*graphPlot.XData';
    T_coord.y         = -70*graphPlot.YData';    
    T_coord.alloc     = zeros(length(nodeNames),1);





%% Definitions

% Buses:
% Allocated: xy coordinates have been assigned to the node
% Visited  : node has been drawn in simulink
visited           = [];

% Lines:
% type = 0 --> PI line, type = 1 --> RL line, type = 2 --> trafo
T_lines          = [T_NET(:,["number","bus_from","bus_to"]); T_trafo(:,["number","bus_from","bus_to"])];
T_lines.drawn    = zeros(height(T_lines),1);
T_lines.type     = [zeros(height(T_NET),1); 2*ones(height(T_trafo),1)]; 
T_lines.x0       = zeros(height(T_lines),1);
T_lines.y0       = zeros(height(T_lines),1);

for idx_line = 1:height(T_NET)
    if T_NET{idx_line,"B"} == 0
        T_lines.type(idx_line) = 1;
    end
end

% Define spacing between blocks
    deltax = 10; %75 
    deltay = 10; %50
    deltax_pqv = 10;
    deltay_pqv = 10;
% Generating units, loads and lines
    width_pqv  = 10;
    height_pqv = 5;
% Buses (Measurement V&I)
    width_bus = 5;
    height_bus  = 10;
% Lines and trafos
    width_line = 5;
    height_line  = 10;
% Dimensions for measurement blocks
    dx = 25;
    dy = 25;

% xy limits = [-1073740824;1073740823]


%% Build linear

try
 
% Create empty simulink moddel
    fileName = nonlinear;
    sys = new_system(fileName);
    load_system(fileName);
    save_system(fileName,['00_tool/Non Linear Models/models/' fileName]);
    open(fileName)
 
% LIFO queue of next nodes to visit
    linesQueue = []; 

% Set Start node
    linesQueue(1,1) = T_degree.bus(1);  %allocated node
    linesQueue(2,1) = 0;    % parent node
    linesQueue(3,1) = 0;  % from parent to node --> 1 / from node to parent --> -1

%%
while ~isempty(linesQueue)

    % Get coordinates for currentNode
        currentNode = linesQueue(1,1);
        x0   = T_coord{T_coord.element == num2str(currentNode),"x"};
        y0   = T_coord{T_coord.element == num2str(currentNode),"y"};
        parentNode = linesQueue(2,1);

    % if current node has not been visited
    if ~ismember(currentNode,visited)

        % Draw currentNode node
        add_block('myLibrary/BUS', [fileName '/BUS-' num2str(currentNode)],'Position', [x0 y0 x0+width_bus y0+height_bus]); %measurement VI
        set_param([fileName '/BUS-' num2str(currentNode)],'LabelV',['V_ll_' num2str(currentNode)],'LabelI',['I_' num2str(currentNode)]);
        hbus = get_param([fileName '/BUS-' num2str(currentNode)],'PortHandles');
        visited(end+1) = currentNode;
   
        % Draw line & connection to parentNode                 
        T_lines = draw_line_force(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus);       

        % 1 - Find current node neighbors and connected elements
        N_in    = [T_NET{T_NET.bus_to == currentNode,'bus_from'}; T_trafo{T_trafo.bus_to == currentNode,'bus_from'}]; % bus_to --> currentNode 
        N_out   = [T_NET{T_NET.bus_from == currentNode,'bus_to'}; T_trafo{T_trafo.bus_from == currentNode,'bus_to'}]; % currentNode --> bus_from
        N_pqv   = T_nodes{T_nodes.Node == currentNode,2:end};
        
        % 2 - If generator units or loads in current node --> allocate and draw them
        if ~isempty(N_pqv)                
                n_elements = nnz(~ismissing(N_pqv));
                for idx_el = 1:n_elements                   
                    element = split(N_pqv(idx_el));
                    name    = element(1);
                    num     = char(element(2));
                    x = T_coord{T_coord.element == N_pqv(idx_el),"x"};
                    y = T_coord{T_coord.element == N_pqv(idx_el),"y"};

                    % Side and orientation depending on assigned coordinates
                    if x0 < x            
                        side = 'r';
                    else
                        side = 'l';
                    end

                    if y < y0 
                        orientation = 'down';
                        if name == "Load"
                            orientation = 'up';
                        end                     
                        element_xy = [x y-width_bus-deltay_pqv-height_pqv x+height_pqv y+-width_bus-deltay_pqv+height_pqv];
                    else
                        orientation = 'up';
                        if name == "Load"
                            orientation = 'down';
                        end
                        element_xy = [x y+width_bus+deltay_pqv x+height_pqv y+width_bus+deltay_pqv+height_pqv];
                    end

                    switch name
                        case "Load"
                            add_block('myLibrary/BUS', [fileName '/BUS-Load-' num],'Position', [x y x+height_bus y+width_bus],'Orientation',orientation); %measurement VI
                            set_param([fileName '/BUS-Load-' num],'LabelV',['V_Load_' num],'LabelI',['I_Load' num],'ShowName','off');
                            if T_load{T_load.number == str2double(num),"L"} == 0 && T_load{T_load.number == str2double(num),"C"} == 0
                                add_block('myLibrary/Load_R', [fileName '/Load-' num],'Position', element_xy,'Orientation',orientation); %load
                            elseif T_load{T_load.number == str2double(num),"L"}>0
                                add_block('myLibrary/Load', [fileName '/Load-' num],'Position', element_xy,'Orientation',orientation); %load
                            elseif T_load{T_load.number == str2double(num),"C"}>0
                                add_block('myLibrary/LoadC', [fileName '/Load-' num],'Position', element_xy,'Orientation',orientation); %load
                            end
                            set_param([fileName '/Load-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-Load-' num],'PortHandles');
                            hblock = get_param([fileName '/Load-' num],'PortHandles');
                            connect_buses_load_force(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.RConn(1),hblock.LConn(1))
                            add_line(fileName,hbusblock.RConn(2),hblock.LConn(2))
                            add_line(fileName,hbusblock.RConn(3),hblock.LConn(3))
                        case "TH"
                            add_block('myLibrary/BUS', [fileName '/BUS-TH-' num],'Position', [x y x+height_bus y+width_bus],'Orientation',orientation); %measurement VI
                            set_param([fileName '/BUS-TH-' num],'LabelV',['V_TH_' num],'LabelI',['I_TH' num],'ShowName','off');
                            add_block('myLibrary/TH', [fileName '/TH-' num],'Position', element_xy,'Orientation',orientation); %TH
                            set_param([fileName '/TH-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-TH-' num],'PortHandles');
                            hblock = get_param([fileName '/TH-' num],'PortHandles');
                            connect_buses_gen_force(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                        case "SG"
                            add_block('myLibrary/BUS', [fileName '/BUS-SG-' num],'Position', [x y x+height_bus y+width_bus],'Orientation',orientation); %measurement VI
                            set_param([fileName '/BUS-SG-' num],'LabelV',['V_SG_' num],'LabelI',['I_SG' num],'ShowName','off');
                            add_block('myLibrary/SG', [fileName '/SG-' num],'Position', element_xy,'Orientation',orientation); %user
                            set_param([fileName '/SG-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-SG-' num],'PortHandles');
                            hblock = get_param([fileName '/SG-' num],'PortHandles');
                            connect_buses_gen_force(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                        case "VSC"
                            add_block('myLibrary/BUS', [fileName '/BUS-VSC-' num],'Position', [x y x+height_bus y+width_bus],'Orientation',orientation); %measurement VI
                            set_param([fileName '/BUS-VSC-' num],'LabelV',['V_VSC_' num],'LabelI',['I_VSC' num],'ShowName','off');
                            mode = T_VSC{T_VSC.number == str2double(num), "mode"}{:};
                            add_block(['myLibrary/' mode], [fileName '/VSC-' num],'Position', element_xy,'Orientation',orientation); %user
                            set_param([fileName '/VSC-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-VSC-' num],'PortHandles');
                            hblock = get_param([fileName '/VSC-' num],'PortHandles');
                            connect_buses_gen_force(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                        case "user"
                            % find name of connected element
                            name = T_user.element{T_user.bus == currentNode};
                            add_block('myLibrary/BUS', [fileName '/BUS-User-' num],'Position', [x y x+height_bus y+width_bus],'Orientation',orientation); %measurement VI
                            set_param([fileName '/BUS-User-' num],'LabelV',['V_USER_' num],'LabelI',['I_USER' num],'ShowName','off');
                            add_block('myLibrary/TH', [fileName '/User-' num],'Position', element_xy,'Orientation',orientation); %user
                            %add_block(['myLibrary/' name], [fileName '/User-' num],'Position', element_xy,'Orientation',orientation); %user
                            set_param([fileName '/User-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-User-' num],'PortHandles');
                            hblock = get_param([fileName '/User-' num],'PortHandles');
                            connect_buses_gen_force(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                    end    
    
                end
        end
        
    
    %if current node has already been visited, draw the line
    else        
        T_lines = draw_line_force(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus);    
    end

            % Delete current node from queue
            linesQueue(:,1) = [];
            % Add all neighbours to queue of nodes 
                % except parent node
                if ~ismember(currentNode,visited)
                    N_in  = N_in(~ismember(N_in,parentNode));
                end
                % except already drawn lines
                N_out_new = [];
                for idx_node = 1:length(N_out)
                    if ~T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == N_out(idx_node),"drawn"}
                        N_out_new(end+1) = N_out(idx_node);
                    end
                end
                N_in_new = [];
                for idx_node = 1:length(N_in)
                    if ~T_lines{T_lines.bus_to == currentNode & T_lines.bus_from == N_in(idx_node),"drawn"}
                        N_in_new(end+1) = N_in(idx_node);
                    end
                end
                % delete drawn line from queue, if exists
                linesQueue_clean = [];
                for idx_line = 1:size(linesQueue,2)
                    line = linesQueue(:,idx_line);
                    if line(3) == 1
                        if ~T_lines{T_lines.bus_from == line(2) & T_lines.bus_to == line(1),"drawn"}
                            linesQueue_clean = [linesQueue_clean, line];
                        end
                    else
                        if ~T_lines{T_lines.bus_to == line(2) & T_lines.bus_from == line(1),"drawn"}
                            linesQueue_clean = [linesQueue_clean, line];
                        end
                    end
                end
                   
            linesQueue = [ [N_out_new; currentNode*ones(1,length(N_out_new)); ones(1,length(N_out_new))], [N_in_new; currentNode*ones(1,length(N_in_new)); -1*ones(1,length(N_in_new))], linesQueue_clean ];
            drawnow
end

%%

deltax = 100;

% Get empty coordinates
x0 = max(T_coord.x) + 3*deltax;
y0 = min(T_coord.y);

% Add powergui and set simulation parameters

    set_param(fileName, 'Solver', sim_config.solver{:}, 'StopTime', 'sim_config.Tsim')
    % Add powergui block
    add_block('spspowerguiLib/powergui', [fileName '/powergui'],'Position', [x0 y0 x0+75 y0+25]); 
    set_param([fileName '/powergui'],'SimulationMode',sim_config.Type,'SampleTime','sim_config.Ts');

% Add clock

    h_clock   = add_block('simulink/Sources/Clock', [fileName '/clock'],'Position', [x0      y0+25+dy x0+dx   y0+25+2*dy],'ShowName','off'); 
    h_display = add_block('simulink/Sinks/Display', [fileName '/display'],'Position', [x0+2*dx y0+25+dy x0+4*dx y0+25+2*dy],'ShowName','off'); 
    add_line(fileName,get_param(h_clock,'PortHandles').Outport(1), get_param(h_display,'PortHandles').Inport(1))

% Add reference angle block 
    switch element_slk
        case 'TH' % TH as reference 
          fb = T_global.fb(T_global.Area == T_TH.Area(T_TH.bus == bus_slk));
          x0 = add_angleRef(fileName,x0,y0,dx,dy,deltax,fb);
        case 'SG'
          x0 = add_SGRef(fileName,x0,y0,dx,dy,deltax,num_slk);
        case 'GFOR'
          x0 = add_GFORRef(fileName,x0,y0,dx,dy,deltax,num_slk); 
    end


% Add measurements and "to workspace" blocks
% - bus voltages
% - current and power in loads/generator units
% -------------------------------------------------------------------------
    % Get input/output buses
    list_buses = [];
    list_pqv   = array2table(zeros(0,3),'VariableNames',{'num', 'bus', 'elementName'});
    ports   = [input,output];

    for io_idx   = 1:length(ports)
        io_port  = ports{io_idx};
    
        if ~contains(io_port,'NET.i') %line currents --> skip
            var_name = split(io_port,'.');
       
            if contains(io_port,'NET.vn') %bus voltages
                list_buses(end+1) = str2double(regexp(var_name{2},'\d*','match'));
            elseif contains(io_port,'NET.Rl') %load input
                num = str2double(regexp(var_name{2},'\d*','match'));
                bus = T_load{T_load.number == str2double(num),"bus"};
            else
                num         = regexp(var_name{1},'\d*','match');
                elementName = erase(var_name{1},num);    
                switch elementName
                    case 'Load'
                        bus = T_load{T_load.number == str2double(num),"bus"};
                        list_pqv = [list_pqv; cell2table({str2double(num),bus,elementName},'VariableNames',{'num', 'bus', 'elementName'})]; 
                        list_buses(end+1) = bus;
                    case  'USER'
                        bus = T_user{T_user.number == str2double(num),"bus"};
                        list_pqv = [list_pqv; cell2table({str2double(num),bus,elementName},'VariableNames',{'num', 'bus', 'elementName'})]; 
                        list_buses(end+1) = bus;
                    case {'REF_w','GFOL','GFOR','STAT'}
                        % pass
                    otherwise
                        T_XX = eval(['T_' elementName]);
                        bus = T_XX{T_XX.number == str2double(num),"bus"};
                        list_pqv = [list_pqv; cell2table({str2double(num),bus,elementName},'VariableNames',{'num', 'bus', 'elementName'})]; 
                        list_buses(end+1) = bus;
                end            
                
            end
        end
    end

    list_buses  = unique(list_buses);
    list_pqv    = unique(list_pqv);

    % Add Line-to-Line Voltages

        y = add_annotation(fileName, 'Line-to-Line Voltages', x0, y0, dx, dy);
    
        for bus_idx = 1:length(list_buses)
             h_from = add_block('simulink/Signal Routing/From',  [fileName '/From'], 'MakeNameUnique','on','Position',[x0 y x0+3*dx y+dy]);
                      set_param(h_from,'GotoTag',['V_ll_' num2str(list_buses(bus_idx))],'TagVisibility','global','ShowName','off');
             h_scope = add_block('simulink/Sinks/Scope',[fileName '/Scope'], 'MakeNameUnique','on','Position',[x0+4*dx y x0+5*dx y+dy],'ShowName','off'); 
                       add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_scope,'PortHandles').Inport(1))
             y = y+1.5*dy;
        end
        x0 = x0+5*dx + deltax;
           
    % Add Line-to-neutral Voltages

        y = add_annotation(fileName, 'Line-to-Neutral Voltages', x0, y0, dx, dy) + dy;
   
        for bus_idx = 1:length(list_buses)
             h_from  = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',   [x0      y+dy x0+3*dx   y+2*dy]);
                       set_param(h_from,'GotoTag',['V_ll_' num2str(list_buses(bus_idx))],'TagVisibility','global','ShowName','off');
             h_demux = add_block('simulink/Signal Routing/Demux',[fileName '/Demux'], 'MakeNameUnique','on','Position', [x0+4*dx y x0+4*dx+3 y+3*dy]);
                       set_param(h_demux,'Outputs','3')
             h_mux  = add_block('simulink/Signal Routing/Mux',[fileName '/Mux'], 'MakeNameUnique','on','Position',      [x0+5*dx y x0+5*dx+3 y+2*dy]);
                      set_param(h_mux,'Inputs','2')
             h_const = add_block('simulink/Sources/Constant',[fileName '/Constant'], 'MakeNameUnique','on','Position',  [x0      y-dy    x0+dx     y]);
                       set_param(h_const,'VectorParams1D',1,'Value','[2/3 1/3; -1/3 1/3 ; -1/3 -2/3]','ShowName','off');             
             h_mtx  = add_block('simulink/Math Operations/Product',[fileName '/mtx'], 'MakeNameUnique','on','Position', [x0+7*dx y+dy x0+8*dx y+2*dy]);
                      set_param(h_mtx,'Multiplication','Matrix','ShowName','off');    
             h_goto  = add_block('simulink/Signal Routing/Goto',[fileName '/Goto'], 'MakeNameUnique','on','Position',   [x0+9*dx y+dy x0+12*dx   y+2*dy]);
                       set_param(h_goto,'GotoTag',['V_fn_' num2str(list_buses(bus_idx))],'TagVisibility','global','ShowName','off');
             h_scope = add_block('simulink/Sinks/Scope',[fileName '/Scope'], 'MakeNameUnique','on','Position',          [x0+9*dx y-dy x0+10*dx y],'ShowName','off'); 
             add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_demux,'PortHandles').Inport(1))
             add_line(fileName,get_param(h_demux,'PortHandles').Outport(1), get_param(h_mux,'PortHandles').Inport(1))
             add_line(fileName,get_param(h_demux,'PortHandles').Outport(2), get_param(h_mux,'PortHandles').Inport(2))
             add_line(fileName,get_param(h_mux,'PortHandles').Outport(1), get_param(h_mtx,'PortHandles').Inport(2),'autorouting','smart')  
             add_line(fileName,get_param(h_const,'PortHandles').Outport(1), get_param(h_mtx,'PortHandles').Inport(1),'autorouting','smart')    
             add_line(fileName,get_param(h_mtx,'PortHandles').Outport(1), get_param(h_goto,'PortHandles').Inport(1))
             add_line(fileName,get_param(h_mtx,'PortHandles').Outport(1), get_param(h_scope,'PortHandles').Inport(1),'autorouting','smart')    
             y = y+4*dy;
        end
        x0 = x0+10*dx + deltax;

    
    % Add Power Measurements

    y = add_annotation(fileName, 'Power Measurements', x0, y0, dx, dy);

    for pqv_idx = 1:height(list_pqv)
        bus        = list_pqv.bus(pqv_idx);
        num        = list_pqv.num(pqv_idx);
        h_fromV    = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',   [x0      y+dy   x0+3*dx   y+2*dy]);
                     set_param(h_fromV,'GotoTag',['V_fn_' num2str(bus)],'TagVisibility','global','ShowName','off');
        h_fromI    = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',   [x0      y+3*dy x0+3*dx   y+4*dy]);
                     set_param(h_fromI,'GotoTag',['I_' list_pqv.elementName{pqv_idx} num2str(num)],'TagVisibility','global','ShowName','off');
        h_power    = add_block('spsPower3phInstantaneousLib/Power (3ph, Instantaneous)',[fileName '/Power'], 'MakeNameUnique','on','Position',   [x0+4*dx      y+dy   x0+6*dx   y+4*dy]);
                     set_param(h_power,'ShowName','off');
        h_2work_P   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_P_' list_pqv.elementName{pqv_idx} num2str(num)], 'Position',   [x0+7*dx      y+dy   x0+9*dx   y+2*dy]);
                     set_param(h_2work_P,'VariableName',['P_' list_pqv.elementName{pqv_idx} num2str(num)],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        h_2work_Q   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_Q_' list_pqv.elementName{pqv_idx} num2str(num)], 'Position',   [x0+7*dx      y+3*dy   x0+9*dx   y+4*dy]);
                     set_param(h_2work_Q,'VariableName',['Q_' list_pqv.elementName{pqv_idx} num2str(num)],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        h_displayP = add_block('simulink/Sinks/Display',[fileName '/Scope'], 'MakeNameUnique','on','Position',[x0+10*dx  y+dy    x0+12*dx    y+2*dy],'ShowName','off');
        h_displayQ = add_block('simulink/Sinks/Display',[fileName '/Scope'], 'MakeNameUnique','on','Position',[x0+10*dx  y+3*dy  x0+12*dx    y+4*dy],'ShowName','off');
        h_scope    = add_block('simulink/Sinks/Scope',[fileName '/Scope'], 'MakeNameUnique','on','Position',  [x0+10*dx  y-0.5*dy    x0+11*dx y+0.5*dy],'ShowName','off');
                     set_param(h_scope,'NumInputPorts','2');
        add_line(fileName,get_param(h_fromV,'PortHandles').Outport(1), get_param(h_power,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_fromI,'PortHandles').Outport(1), get_param(h_power,'PortHandles').Inport(2))
        add_line(fileName,get_param(h_power,'PortHandles').Outport(1), get_param(h_2work_P,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_power,'PortHandles').Outport(2), get_param(h_2work_Q,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_power,'PortHandles').Outport(1), get_param(h_displayP,'PortHandles').Inport(1),'autorouting','smart') 
        add_line(fileName,get_param(h_power,'PortHandles').Outport(2), get_param(h_displayQ,'PortHandles').Inport(1),'autorouting','smart') 
        add_line(fileName,get_param(h_power,'PortHandles').Outport(1), get_param(h_scope,'PortHandles').Inport(1),'autorouting','smart') 
        add_line(fileName,get_param(h_power,'PortHandles').Outport(2), get_param(h_scope,'PortHandles').Inport(2),'autorouting','smart') 
        y = y+4*dy + dy;
    end
    x0 = x0+11*dx + deltax;
                    

    % Add qd0 transforms

    y = add_annotation(fileName, 'qd0 transforms', x0, y0, dx, dy);

    for bus_idx = 1:length(list_buses)
        h_from      = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',[x0      y+dy   x0+3*dx   y+2*dy]);
                      set_param(h_from,'GotoTag',['V_fn_' num2str(list_buses(bus_idx))],'TagVisibility','global','ShowName','off');
        h_angle     = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position', [x0      y+3*dy    x0+3*dx   y+4*dy]);
                      set_param(h_angle,'GotoTag','angle_ref','TagVisibility','global','ShowName','off');
        h_qd        = add_block('myLibrary/qd transform', [fileName '/qd'],'MakeNameUnique','on', 'Position', [x0+4*dx  y+dy    x0+6*dx   y+4*dy]); 
        h_2work_q   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_NET.vn' num2str(list_buses(bus_idx)) 'q'], 'Position',   [x0+7*dx      y+dy   x0+9*dx   y+2*dy]);
                      set_param(h_2work_q,'VariableName',['vn' num2str(list_buses(bus_idx)) 'q'],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        h_2work_d   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_NET.vn' num2str(list_buses(bus_idx)) 'd'], 'Position',   [x0+7*dx      y+3*dy   x0+9*dx   y+4*dy]);
                      set_param(h_2work_d,'VariableName',['vn' num2str(list_buses(bus_idx)) 'd'],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_qd,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_angle,'PortHandles').Outport(1), get_param(h_qd,'PortHandles').Inport(2))
        add_line(fileName,get_param(h_qd,'PortHandles').Outport(1), get_param(h_2work_q,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_qd,'PortHandles').Outport(2), get_param(h_2work_d,'PortHandles').Inport(1))
        y = y+4*dy + dy;
    end

    for pqv_idx = 1:height(list_pqv)
        bus        = list_pqv.bus(pqv_idx);
        num        = list_pqv.num(pqv_idx);
        h_from      = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',[x0      y+dy   x0+3*dx   y+2*dy]);
                      set_param(h_from,'GotoTag',['I_' list_pqv.elementName{pqv_idx} num2str(num)],'TagVisibility','global','ShowName','off');
        h_angle     = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position', [x0      y+3*dy    x0+3*dx   y+4*dy]);
                      set_param(h_angle,'GotoTag','angle_ref','TagVisibility','global','ShowName','off');
        h_qd        = add_block('myLibrary/qd transform', [fileName '/qd'],'MakeNameUnique','on', 'Position', [x0+4*dx  y+dy    x0+6*dx   y+4*dy]); 
        h_2work_q   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_I_' list_pqv.elementName{pqv_idx} num2str(num) '_q'], 'Position',   [x0+7*dx      y+dy   x0+9*dx   y+2*dy]);
                      set_param(h_2work_q,'VariableName',['I_' list_pqv.elementName{pqv_idx} num2str(num) '_q'],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        h_2work_d   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' '_I_' list_pqv.elementName{pqv_idx} num2str(num) '_d'], 'Position',   [x0+7*dx      y+3*dy   x0+9*dx   y+4*dy]);
                      set_param(h_2work_d,'VariableName',['I_' list_pqv.elementName{pqv_idx} num2str(num) '_d'],'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');
        add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_qd,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_angle,'PortHandles').Outport(1), get_param(h_qd,'PortHandles').Inport(2))
        add_line(fileName,get_param(h_qd,'PortHandles').Outport(1), get_param(h_2work_q,'PortHandles').Inport(1))
        add_line(fileName,get_param(h_qd,'PortHandles').Outport(2), get_param(h_2work_d,'PortHandles').Inport(1))
        y = y+4*dy + dy;
    end
    x0 = x0+9*dx +deltax;

    % Add omega
    y = add_annotation(fileName, 'omega', x0, y0, dx, dy);

    for pqv_idx = 1:height(list_pqv)
        if ~any(strcmp({'Load','TH'},list_pqv.elementName{pqv_idx}))
            bus        = list_pqv.bus(pqv_idx);
            num        = list_pqv.num(pqv_idx);
            elementName = list_pqv.elementName{pqv_idx};

            switch elementName
                case 'VSC'
                    elementName = T_VSC{T_VSC.number == num, "mode"}{:};
            end

            name_w = [elementName num2str(num) '_w'];
            h_from      = add_block('simulink/Signal Routing/From',[fileName '/From'], 'MakeNameUnique','on','Position',[x0      y+dy   x0+3*dx   y+2*dy]);
                          set_param(h_from,'GotoTag',['w_' elementName num2str(num) ],'TagVisibility','global','ShowName','off');   
            h_2work_q   = add_block('simulink/Sinks/To Workspace',[fileName '/To Workspace' name_w], 'Position',   [x0+4*dx      y+dy   x0+6*dx   y+2*dy]);
                          set_param(h_2work_q,'VariableName',name_w,'SaveFormat','Array','SampleTime','sim_config.Tsample','ShowName','off');                              
            add_line(fileName,get_param(h_from,'PortHandles').Outport(1), get_param(h_2work_q,'PortHandles').Inport(1))
            y = y+2*dy + dy;      
        end
    end
% -------------------------------------------------------------------------

save_system(fileName,['00_tool/Non Linear Models/models/' fileName])

catch ME
    errorMessage = sprintf('Error at line %d.\n\nError Message:\n%s', ME.stack(1).line, ME.message);
    fprintf(1, '%s\n', errorMessage);
    save_system(fileName,['00_tool/Non Linear Models/models/' fileName])
    delete(['00_tool/Non Linear Models/models/' fileName '.slx'])
end
