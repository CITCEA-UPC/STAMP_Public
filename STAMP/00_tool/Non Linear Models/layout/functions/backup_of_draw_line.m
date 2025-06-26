function T_lines = draw_line(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus)
        hbus = get_param([fileName '/BUS-' num2str(currentNode)],'PortHandles');

        if linesQueue(3,1) == 1
            lineNum  = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "number"};
            lineType = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "type"};
            switch lineType
                case 0 
                element = '/Line-';
                add_block('myLibrary/PI_line', [fileName element num2str(lineNum)],'Position', [x0-width_line-deltax y0 x0-deltax y0+height_line]);                                                                                                                                           
                case 1
                element = '/Line-';    
                add_block('myLibrary/RL_line', [fileName element num2str(lineNum)],'Position', [x0-width_line-deltax y0 x0-deltax y0+height_line]);   
                case 2
                element = '/Trafo-';
                add_block('myLibrary/Trafo', [fileName element num2str(lineNum)],'Position', [x0-width_line-deltax y0 x0-deltax y0+height_line]);   
            end

            hline = get_param([fileName element num2str(lineNum)],'PortHandles');
            hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
            connect_buses(fileName,hparent,hbus,hline,'r')
            T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"drawn"} = 1;
            set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));

        elseif linesQueue(3,1) == -1

            % Account for extra x-space IF line is drawn in the right AND elements are connected in the right  
            N_in    = [T_NET{T_NET.bus_to == currentNode,'bus_from'}; T_trafo{T_trafo.bus_to == currentNode,'bus_from'}]; % bus_to --> currentNode 
            if ~isempty(N_in)
                N_pqv   = T_nodes{T_nodes.Node == currentNode,2:end};
                n_elements = nnz(~ismissing(N_pqv));
                x0 = x0 + height_bus*(n_elements) + deltax_pqv*(n_elements);
            end

            % Account for extra y-space if parent and current have same y0 to avoid overlap
            if y0 == T_coord{parentNode,"y"}
                y0 = y0+deltay+width_bus+deltay;
            end

            lineNum  = T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode, "number"};
            lineType = T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode, "type"};
            switch lineType
                case 0 
                element = '/Line-';
                add_block('myLibrary/PI_line', [fileName element num2str(lineNum)],'Position', [x0+width_bus+deltax y0 x0+width_bus+deltax+width_line y0+height_line]);      
                case 1
                element = '/Line-';
                add_block('myLibrary/RL_line', [fileName element num2str(lineNum)],'Position', [x0+width_bus+deltax y0 x0+width_bus+deltax+width_line y0+height_line]);     
                case 2
                element = '/Trafo-';
                add_block('myLibrary/Trafo', [fileName element num2str(lineNum)],'Position',   [x0+width_bus+deltax y0 x0+width_bus+deltax+width_line y0+height_line]);   
            end

            hline = get_param([fileName element num2str(lineNum)],'PortHandles');
            hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
            connect_buses(fileName,hparent,hbus,hline,'l')
            T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"drawn"} = 1;
            set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
        end 
        
end