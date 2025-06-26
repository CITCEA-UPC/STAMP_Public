function T_lines = draw_line_force(linesQueue,T_lines,T_coord,parentNode,currentNode,fileName,x0,y0,width_line,deltax,deltax_pqv,deltay,height_line,T_NET,T_trafo,T_nodes,height_bus,width_bus)

    if linesQueue(3,1) == 0
    else

        hbus        = get_param([fileName '/BUS-' num2str(currentNode)],'PortHandles');
        posCurrent  = get_param([fileName '/BUS-' num2str(currentNode)],'Position');
        posParent   = get_param([fileName '/BUS-' num2str(parentNode)],'Position'); 
     
        if linesQueue(3,1) == 1
            
            x0_current = T_coord{T_coord.element == num2str(currentNode),"x"};
            y0_current = T_coord{T_coord.element == num2str(currentNode),"y"};
            x0_parent = T_coord{T_coord.element == num2str(parentNode),"x"};
            y0_parent = T_coord{T_coord.element == num2str(parentNode),"y"};

            x0 = (x0_current + x0_parent)/2;
            y0 = (y0_current + y0_parent)/2;

            lineNum  = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "number"};
            lineType = T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode, "type"};
            switch lineType
                case 0 
                element = '/Line-';
                add_block('myLibrary/PI_line', [fileName element num2str(lineNum)],'Position', [x0 y0 x0+width_line y0+height_line]);                                                                                                                                           
                case 1
                element = '/Line-';    
                add_block('myLibrary/RL_line', [fileName element num2str(lineNum)],'Position', [x0 y0 x0+width_line  y0+height_line]);   
                case 2
                element = '/Trafo-';
                add_block('myLibrary/Trafo', [fileName element num2str(lineNum)],'Position',   [x0 y0 x0+width_line y0+height_line]);   
                case 3
                element = '/HVDC_line-';
                add_block('myLibrary/HVDC_line', [fileName element num2str(lineNum)],'Position',   [x0 y0 x0+width_line y0+height_line]);     
            end
                
                side = 'l2r';
                if posCurrent(1) < posParent(1) 
                    set_param([fileName element num2str(lineNum)],'Orientation','left');
                    side = 'r2l';
                end
            if lineType ==3
                hbus  = get_param([fileName '/DCBUS-IPC-' num2str(currentNode)],'PortHandles');
                hline = get_param([fileName element num2str(lineNum)],'PortHandles');
                hparent = get_param([fileName '/DCBUS-IPC-' num2str(parentNode)],'PortHandles');
                connect_DCbuses_force2(fileName,hparent,hbus,hline,side)
                
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"drawn"} = 1;

                linePosition = get_param([fileName element num2str(lineNum)],'Position');
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"x0"} = linePosition(1);
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"y0"} = linePosition(2);
                set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
            else
                hline = get_param([fileName element num2str(lineNum)],'PortHandles');
                hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
                connect_buses_force(fileName,hparent,hbus,hline,side)
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"drawn"} = 1;

                linePosition = get_param([fileName element num2str(lineNum)],'Position');
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"x0"} = linePosition(1);
                T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"y0"} = linePosition(2);
                set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
            end

            %hline = get_param([fileName element num2str(lineNum)],'PortHandles');
            %hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
            %connect_buses_force(fileName,hparent,hbus,hline,side)
            %T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"drawn"} = 1;

            %linePosition = get_param([fileName element num2str(lineNum)],'Position');
            %T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"x0"} = linePosition(1);
            %T_lines{T_lines.bus_from == parentNode & T_lines.bus_to == currentNode,"y0"} = linePosition(2);
            %set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));

        elseif linesQueue(3,1) == -1

            x0_current = T_coord{T_coord.element == num2str(currentNode),"x"};
            y0_current = T_coord{T_coord.element == num2str(currentNode),"y"};
            x0_parent = T_coord{T_coord.element == num2str(parentNode),"x"};
            y0_parent = T_coord{T_coord.element == num2str(parentNode),"y"};

            x0 = (x0_current + x0_parent)/2;
            y0 = (y0_current + y0_parent)/2;
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
                case 3
                element = '/HVDC_line-';
                add_block('myLibrary/HVDC_line', [fileName element num2str(lineNum)],'Position',   [x0+width_bus+deltax_pqv y0 x0+width_bus+deltax_pqv+width_line y0+height_line]);
            end

                side = 'l2r';
                if posCurrent(1) > posParent(1) 
                    set_param([fileName element num2str(lineNum)],'Orientation','left');
                    side = 'r2l';
                end
            if lineType ==3
                hbus  = get_param([fileName '/DCBUS-IPC-' num2str(currentNode)],'PortHandles');
                hline = get_param([fileName element num2str(lineNum)],'PortHandles');
                hparent = get_param([fileName '/DCBUS-IPC-' num2str(parentNode)],'PortHandles');
                connect_DCbuses_force2(fileName,hbus,hparent,hline,side)
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"drawn"} = 1;

                linePosition = get_param([fileName element num2str(lineNum)],'Position');
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"x0"} = linePosition(1);
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"y0"} = linePosition(2);
                set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
            else
                hline = get_param([fileName element num2str(lineNum)],'PortHandles');
                hparent = get_param([fileName '/BUS-' num2str(parentNode)],'PortHandles');
                connect_buses_force(fileName,hbus,hparent,hline,side)
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"drawn"} = 1;

                linePosition = get_param([fileName element num2str(lineNum)],'Position');
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"x0"} = linePosition(1);
                T_lines{T_lines.bus_from == currentNode & T_lines.bus_to == parentNode,"y0"} = linePosition(2);
                set_param([fileName element num2str(lineNum)],'num',num2str(lineNum));
            end
            
        end 
    end  
end