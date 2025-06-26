function T_lines = draw_line(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus)

    if linesQueue(3,1) == 0
    else

        hbus        = get_param([fileName '/BUS-' num2str(currentNode)],'PortHandles');
        posCurrent  = get_param([fileName '/BUS-' num2str(currentNode)],'Position');
        posParent   = get_param([fileName '/BUS-' num2str(parentNode)],'Position'); 
     
        if linesQueue(3,1) == 1

            % Determine if there are more lines drawn in the same position
            N_lines_left = T_lines(T_lines.bus_to == currentNode & T_lines.drawn == 1,:);
            if posParent(2) < posCurrent(2) %if position parent is higher
                deltay_add   = -(deltax_pqv+height_line)*height(N_lines_left);
            else %if position parent is lower
                deltay_add   = (deltax_pqv+height_line)*height(N_lines_left);
            end

            y0 = y0+deltay_add; 

            while ~isempty(T_lines(T_lines.x0 == x0-width_line-deltax & T_lines.y0 == y0,:))
                if posParent(2) < posCurrent(2)
                    y0 = y0-(deltax_pqv+height_line);
                else
                    y0 = y0+(deltax_pqv+height_line);
                end
            end            


            lineNum  = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "number"};
            lineType = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "type"};
            switch lineType
                case 0 
                element = '/Line-';
                add_block('myLibrary/PI_line', [fileName element num2str(lineNum)],'Position', [x0-width_line-deltax_pqv y0 x0-deltax_pqv y0+height_line]);                                                                                                                                           
                case 1
                element = '/Line-';    
                add_block('myLibrary/RL_line', [fileName element num2str(lineNum)],'Position', [x0-width_line-deltax_pqv y0 x0-deltax_pqv y0+height_line]);   
                case 2
                element = '/Trafo-';
                add_block('myLibrary/Trafo', [fileName element num2str(lineNum)],'Position',    [x0-width_line-deltax_pqv y0 x0-deltax_pqv y0+height_line]);   
            end

            hline = get_param([fileName element num2str(lineNum)],'PortHandles');
            hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
            connect_buses(fileName,hparent,hbus,hline,'r')
            T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"drawn"} = 1;

            linePosition = get_param([fileName element num2str(lineNum)],'Position');
            T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"x0"} = linePosition(1);
            T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"y0"} = linePosition(2);
            set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));

        elseif linesQueue(3,1) == -1

            % Determine if there are more lines drawn in the same position
            N_lines_right = T_lines(T_lines.bus_from == currentNode & T_lines.drawn == 1,:);
            if posCurrent(2) < posParent(2)  %if position current is higher
                deltay_add   = (deltax_pqv+height_line)*height(N_lines_right);
                flag_rotate  = 1;
            else %if position current is lower
                deltay_add   = -(deltax_pqv+height_line)*height(N_lines_right);
                flag_rotate  = 0;
            end
            
            y0 = y0+deltay_add; 

            while ~isempty(T_lines(T_lines.x0 == x0+width_bus+deltax_pqv & T_lines.y0 == y0,:))
                if posCurrent(2) < posParent(2) 
                    y0 = y0 + (deltax_pqv+height_line);
                else
                   y0 = y0 - (deltax_pqv+height_line);   
                end
            end        

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
                add_block('myLibrary/PI_line', [fileName element num2str(lineNum)],'Position', [x0+width_bus+deltax_pqv y0 x0+width_bus+deltax_pqv+width_line y0+height_line]);      
                case 1
                element = '/Line-';
                add_block('myLibrary/RL_line', [fileName element num2str(lineNum)],'Position', [x0+width_bus+deltax_pqv y0 x0+width_bus+deltax_pqv+width_line y0+height_line]);     
                case 2
                element = '/Trafo-';
                add_block('myLibrary/Trafo', [fileName element num2str(lineNum)],'Position',   [x0+width_bus+deltax_pqv y0 x0+width_bus+deltax_pqv+width_line y0+height_line]);   
            end

            if flag_rotate
                set_param([fileName element num2str(lineNum)],'Orientation','down');
            end

            hline = get_param([fileName element num2str(lineNum)],'PortHandles');
            hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
            connect_buses(fileName,hparent,hbus,hline,'l')
            T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"drawn"} = 1;

            linePosition = get_param([fileName element num2str(lineNum)],'Position');
            T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"x0"} = linePosition(1);
            T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"y0"} = linePosition(2);
            set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
        end 
    end  
end