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
        T_lines.type{idx_line} = 1;
    end
end

% Define spacing between blocks
    deltax = 200; %75 
    deltay = 150; %50
    deltax_pqv = 50;
    deltay_pqv = 50;
% Generating units, loads and lines
    width_pqv  = 70;
    height_pqv = 50;
% Buses (Measurement V&I)
    width_bus = 20;
    height_bus  = 50;
% Lines and trafos
    width_line = 70;
    height_line  = 50;
% Dimensions for measurement blocks
    dx = 25;
    dy = 25;

% xy limits = [-1073740824;1073740823]

%% Create system graph
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
        nodeNames = string(1:size(Madj,1));
        NET_graph = graph(Madj,nodeNames);

%Code with raw node numbering
    nodes         = (1:size(Madj,1))'; % CHNAGE to 1:length(T_busEquiv.Bus_tool);
    T_coord       = table('Size',[length(nodes) 4], 'VariableTypes', {'double','double','double','double'}, 'VariableNames',{'bus','x','y','alloc'}); % table for coordinates
    T_coord.bus   = nodes;
    T_coord.alloc = zeros(length(nodes),1);

    n_in = zeros(length(nodes),1); 
    n_out = zeros(length(nodes),1);   
    for idx_node = 1:length(nodes)
        currentNode = nodes(idx_node);
        n_in(idx_node) = sum(T_NET.bus_to == currentNode);
        n_out(idx_node) = sum(T_NET.bus_from == currentNode);
    end

    T_degree    = table(double(nodeNames'),degree(NET_graph),n_in,n_out,'VariableNames',["bus","degree","n_in","n_out"]);
    T_degree    = sortrows(T_degree,{'degree'},{'descend'});



%% Build linear

%try
 
% % Create empty simulink moddel
    fileName = 'test_01';
%     sys = new_system(fileName);
%     load_system(fileName);
%     save_system(fileName,['00_tool/Non Linear Models/' fileName]);
%     open(fileName)

% Define origin
    x0   = 0;
    y0   = 0;
 
% Counter to determine if all nodes have been visited
    count = 1;
    linesQueue = []; % LIFO queue of next nodes to visit

% Set Start node
    linesQueue(1,1) = T_degree.bus(1);  %allocated node
    linesQueue(2,1) = 0;    % parent node
    linesQueue(3,1) = 0;  % from parent to node --> 1 / from node to parent --> -1
    T_coord{T_degree.bus(1),"x"} = x0;
    T_coord{T_degree.bus(1),"y"} = y0;
    T_coord{T_degree.bus(1),"alloc"} = 1;

%%
while ~isempty(linesQueue)

    % Get coordinates for currentNode
        currentNode = linesQueue(1,1)
        x0 = T_coord{currentNode,"x"};
        y0 = T_coord{currentNode,"y"};
        parentNode = linesQueue(2,1);

    % if current node has not been visited
    if ~ismember(currentNode,visited)

        % Draw currentNode node
        add_block('myLibrary/BUS', [fileName '/BUS-' num2str(currentNode)],'Position', [x0 y0 x0+width_bus y0+height_bus]); %measurement VI
        set_param([fileName '/BUS-' num2str(currentNode)],'LabelV',['V_ll_' num2str(currentNode)],'LabelI',['I_' num2str(currentNode)]);
        hbus = get_param([fileName '/BUS-' num2str(currentNode)],'PortHandles');
        visited(end+1) = currentNode;
   
        % Draw line & connection to parentNode                 
        T_lines = draw_line(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus);       

        % 1 - Find current node neighbors and connected elements
        N_in    = [T_NET{T_NET.bus_to == currentNode,'bus_from'}; T_trafo{T_trafo.bus_to == currentNode,'bus_from'}]; % bus_to --> currentNode 
        N_out   = [T_NET{T_NET.bus_from == currentNode,'bus_to'}; T_trafo{T_trafo.bus_from == currentNode,'bus_to'}]; % currentNode --> bus_from
        N_pqv   = T_nodes{T_nodes.Node == currentNode,2:end};
        
        % 2 - If generator units or loads in current node --> allocate and draw them
        if ~isempty(N_pqv)
                
                n_elements = nnz(~ismissing(N_pqv));
                for idx_el = 1:n_elements
    
                    % Set coordinates for V&I measurement element block
                    % If left terminal node (N_top = empty) --> allocate on left
                    if isempty(N_in)             
                        x    = x0 - height_bus*(idx_el-1) - deltax_pqv*idx_el;
                        side = 'l';
                    % If not left terminal node (lines at both sides or right side) --> allocate right
                    else
                        x    = x0 + height_bus*(idx_el-1) + deltax_pqv*idx_el;   
                        side = 'r';
                    end
                    y = y0 + width_bus + deltay_pqv;
                    
                    element = split(N_pqv(idx_el));
                    name    = element(1);
                    num     = char(element(2));
                    switch name
                        case "Load"
                            add_block('myLibrary/BUS', [fileName '/BUS-Load-' num],'Position', [x y x+height_bus y+width_bus],'Orientation','down'); %measurement VI
                            set_param([fileName '/BUS-Load-' num],'LabelV',['V_Load_' num],'LabelI',['I_Load' num]);
                            add_block('myLibrary/Load', [fileName '/Load-' num],'Position', [x y+width_bus+deltay_pqv/2 x+height_pqv y+width_bus+deltay_pqv/2+height_pqv]); %load
                            set_param([fileName '/Load-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-Load-' num],'PortHandles');
                            hblock = get_param([fileName '/Load-' num],'PortHandles');
                            connect_buses_load(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.RConn(1),hblock.LConn(1))
                            add_line(fileName,hbusblock.RConn(2),hblock.LConn(2))
                            add_line(fileName,hbusblock.RConn(3),hblock.LConn(3))
                        case "TH"
                            add_block('myLibrary/BUS', [fileName '/BUS-TH-' num],'Position', [x y x+height_bus y+width_bus],'Orientation','up'); %measurement VI
                            set_param([fileName '/BUS-TH-' num],'LabelV',['V_TH_' num],'LabelI',['I_TH' num]);
                            add_block('myLibrary/TH', [fileName '/TH-' num],'Position', [x y+width_bus+deltay_pqv/2 x+height_pqv y+width_bus+deltay_pqv/2+height_pqv],'Orientation','up'); %TH
                            set_param([fileName '/TH-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-TH-' num],'PortHandles');
                            hblock = get_param([fileName '/TH-' num],'PortHandles');
                            connect_buses_gen(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                        case "user"
                            add_block('myLibrary/BUS', [fileName '/BUS-User-' num],'Position', [x y x+height_bus y+width_bus],'Orientation','up'); %measurement VI
                            set_param([fileName '/BUS-User-' num],'LabelV',['V_User_' num],'LabelI',['I_User' num]);
                            add_block('myLibrary/TH', [fileName '/User-' num],'Position', [x y+width_bus+deltay_pqv/2 x+height_pqv y+width_bus+deltay_pqv/2+height_pqv],'Orientation','up'); %user
                            set_param([fileName '/User-' num],'num',num);
                            hbusblock = get_param([fileName '/BUS-User-' num],'PortHandles');
                            hblock = get_param([fileName '/User-' num],'PortHandles');
                            connect_buses_gen(fileName,hbus,hbusblock,side)
                            add_line(fileName,hbusblock.LConn(1),hblock.RConn(1))
                            add_line(fileName,hbusblock.LConn(2),hblock.RConn(2))
                            add_line(fileName,hbusblock.LConn(3),hblock.RConn(3))
                    end    
    
                end
                % update corner coordinates of next V&I                           
                if isempty(N_in)   
                    % If left terminal node (N_top = empty) 
                    x0 = x0 + width_bus + deltax + width_line + deltax; 
                else
                    x0 = x0 + width_bus + height_bus*(n_elements) + deltax_pqv*(n_elements+1) + deltax + width_line ; 
                end   
        else
            % update corner coordinates of next V&I    
            x0 = x0 + width_bus + deltax + width_line + deltax; 
        end
        
    
        % 2 - Neighbour nodes allocation
    
        % Set coordinates for nodes on the right
            % Allocate first the ones with least left-childs to avoid potential future overlaps
            if any(N_out)
                childs_right = sortrows(T_degree(ismember(T_degree.bus,N_out),:),'n_in','ascend'); 
        
                % Delete already allocated nodes   
                idx_node = 1;
                while idx_node <= height(childs_right)
                    node = childs_right.bus(idx_node);
                    if T_coord{node,"alloc"}
                        childs_right(idx_node,:) = [];
                    end
                    idx_node = idx_node+1;
                end

            T_coord = generate_ycoordinate(childs_right,T_coord,deltay,height_bus,width_bus,height_pqv,Madj,x0,y0);

            end
    
        % Allocate neighbour nodes on the left
            if any(N_in)
                childs_left = sortrows(T_degree(ismember(T_degree.bus,N_in),:),'n_in','ascend'); 
                x0 = T_coord{currentNode,"x"} - 2*width_bus - 2*deltax; %move to the left
        
                % Delete already allocated nodes
                % and Allocate in same y coordinates neighbors left that are connected to neighbors right
            idx_node = 1;
            while idx_node <= height(childs_left)
                node = childs_left.bus(idx_node);
                if T_coord{node,"alloc"} 
                    childs_left(idx_node,:) = [];
                else
                    Madj_red = Madj(node,N_out')'; 
                    if any(Madj_red)
                        T_coord{T_coord.bus == node,"x"} = x0; 
                        T_coord{T_coord.bus == node,"y"} = T_coord{T_coord.bus == N_out(find(Madj==1,1)),"y"}; 
                        T_coord{T_coord.bus == node,"alloc"} = 1;                              
                        childs_left(childs_left.bus == node,:) = [];
                    end
                    idx_node = idx_node+1;
                end
            end

            T_coord = generate_ycoordinate(childs_left,T_coord,deltay,height_bus,width_bus,height_pqv,Madj,x0,y0);    
                
            end

    %if current node has already been visited, draw the line
    else        
        T_lines = draw_line(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus);    
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
                   
            linesQueue = [ [N_out_new; currentNode*ones(1,length(N_out_new)); ones(1,length(N_out_new))], [N_in_new; currentNode*ones(1,length(N_in_new)); -1*ones(1,length(N_in_new))], linesQueue_clean ]
            drawnow
end

%%

% Get empty coordinates
x0 = max(T_coord.x) + 3*deltax;
y0 = min(T_coord.y);

% Add powergui and set simulation parameters

    % Read Simulation data
    T_sim = readtable(excel,'Sheet','sim'); 
    sim_config.Type = T_sim.Type{:};
    sim_config.Ts   = T_sim.Ts_s;
    % Add powergui block
    add_block('spspowerguiLib/powergui', [fileName '/powergui'],'Position', [x0 y0 x0+75 y0+25]); 
    set_param([fileName '/powergui'],'SimulationMode',sim_config.Type,'SampleTime','sim_config.Ts');



% Add reference angle block if TH as reference 

    if num_slk == 0 
      x0 = add_angleRef(fileName,fb,x0,y0,dx,dy,deltax);
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
            else
                num         = regexp(var_name{1},'\d*','match');
                elementName = erase(var_name{1},num);    
                switch elementName
                    case 'Load'
                        bus = T_load{T_load.number == str2double(num),"bus"};
                    case 'TH'
                        bus = T_TH{T_TH.number == str2double(num),"bus"};
                    case  'SG'
                        bus = T_SG{T_SG.number == str2double(num),"bus"};
                    case  'user'
                        bus = T_user{T_user.number == str2double(num),"bus"};
                    otherwise
                        T_XX = eval(['T_' elementName]);
                        bus = T_XX{T_XX.number == str2double(num),"bus"};
                end            
                list_pqv = [list_pqv; cell2table({str2double(num),bus,elementName},'VariableNames',{'num', 'bus', 'elementName'})]; 
                list_buses(end+1) = bus;
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

    end
    
    % Add qd0 transforms


% -------------------------------------------------------------------------

%%

%catch 
    1
%     save_system(fileName,['00_tool/Non Linear Models/' fileName])
%     delete(['00_tool/Non Linear Models/' fileName '.slx'])
%end
