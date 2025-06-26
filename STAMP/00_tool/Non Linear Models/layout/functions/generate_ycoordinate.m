function T_coord = generate_ycoordinate(childs,T_coord,deltay,height_bus,width_bus,height_pqv,Madj,x0,y0)

            deltay_load = height_pqv + width_bus + 2*deltay; %assume there is at least a load connected downwards

            % If exists, allocate in same y-coord a neighbour with no more left-childs
                % Desempate: allocate first the ones with least right-childs to avoid potential future overlaps   
                grandChilds_0       = sortrows(childs(childs.n_in==1,:),'n_out','ascend');         
            if ~isempty(grandChilds_0)
                is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y0 & T_coord.x == x0);
                y_child = y0;
                while is_notFree % Ensure x0 and y0 are empty!  
                    y_child     = y_child + height_bus + deltay + deltay_load;
                    is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y_child & T_coord.x == x0);
                end    
                T_coord{T_coord.bus == grandChilds_0.bus(1),"y"} = y_child;
                T_coord{T_coord.bus == grandChilds_0.bus(1),"x"} = x0;
                T_coord{T_coord.bus == grandChilds_0.bus(1),"alloc"} = 1;
                childs(childs.bus == grandChilds_0.bus(1),:) = [];
            % If not, discard y0-coordinate to avoid overlaps
            end

        % Assign xy coordinates
            % Allocate closer those childs whose grandchilds are connected
            % y-coord has to account for space for the grandchilds
            delta_y0_up     = 0;
            delta_y0_down   = 0;

            idx_node = 1;
            n_nodes  = height(childs);
            while idx_node <= n_nodes   
                currentNeighbour = childs(1,:);
                T_coord{T_coord.bus == currentNeighbour.bus,"x"} = x0;    

                %even --> up
                if mod(idx_node,2) == 0 
                    k           = -1;
                    y_child     = y0 - height_bus - deltay*ceil(idx_node/2)*k - delta_y0_up - deltay_load; 
                    is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y_child & T_coord.x == x0);
                    while is_notFree % Ensure x0 and y0 are empty!  
                        y_child     = y_child - height_bus - deltay;
                        is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y_child & T_coord.x == x0);
                    end                    
                    delta_y0_up = max(ceil(currentNeighbour.n_out/2)*(deltay + height_bus), 3*deltay + height_bus + width_bus + height_pqv); 

                %odd --> down
                else                       
                    k           = 1;
                    y_child     = y0 + height_bus + deltay*ceil(idx_node/2)*k + delta_y0_down + deltay_load; 
                    is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y_child & T_coord.x == x0);
                    while is_notFree % Ensure x0 and y0 are empty!  
                        y_child     = y_child + height_bus + deltay;
                        is_notFree  = any(T_coord.alloc == 1 & T_coord.y == y_child & T_coord.x == x0);
                    end 
                    delta_y0_down = max(ceil(currentNeighbour.n_out/2)*(deltay + height_bus), 3*deltay + height_bus + width_bus + height_pqv); 
                end     
                
                y0 = y_child;
                T_coord{T_coord.bus == currentNeighbour.bus,"y"} = y_child; 
                T_coord{T_coord.bus == currentNeighbour.bus,"alloc"} = 1;                              

             %Now check connectivity between grandchilds of right-childs
                Madj_red = Madj(currentNeighbour.bus,childs.bus)'; 
             % if current child has not any grandhcild connected to any grandchild - --> pass
             % else: allocate closer those nodes --> reorder grandChilds 
                if any(Madj_red)
                    T_temp = childs;
                    childs(2:(2+nnz(Madj_red)-1),:) = T_temp(find(Madj_red),:);
                    childs((2+nnz(Madj_red)):end,:) = [];
                    T_temp(find(Madj_red),:) = [];
                    childs       = [childs; T_temp(2:end,:)];         
                end

                childs(childs.bus == currentNeighbour.bus,:) = [];
                idx_node = idx_node+1;
            end
   
end