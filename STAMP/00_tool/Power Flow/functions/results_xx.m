function obj_xx = results_xx(grid, Ss, bus, bus_xx, obj_xx)

    if ismember(bus, bus_xx) 
        obj_xx{obj_xx.bus == bus,"P"} = real(Ss(bus));
        obj_xx{obj_xx.bus == bus,"Q"} = imag(Ss(bus));
        if ismember(bus, grid.bus_th) 
            obj_xx{obj_xx.bus == bus,"P"} = obj_xx{obj_xx.bus == bus,"P"} - grid.th{grid.th.bus == bus,"P"};
            obj_xx{obj_xx.bus == bus,"Q"} = obj_xx{obj_xx.bus == bus,"Q"} - grid.th{grid.th.bus == bus,"Q"};
        end
        if ismember(bus, grid.bus_pq) 
            obj_xx{obj_xx.bus == bus,"P"} = obj_xx{obj_xx.bus == bus,"P"} - grid.load{grid.load.bus == bus,"P"};
            obj_xx{obj_xx.bus == bus,"Q"} = obj_xx{obj_xx.bus == bus,"Q"} - grid.load{grid.load.bus == bus,"Q"};                
        end
%         if ismember(bus, grid.bus_rx) 
%             obj_xx{obj_xx.bus == bus,"P"} = obj_xx{obj_xx.bus == bus,"P"} + obj_load{obj_load.bus == bus,"P"};
%             obj_xx{obj_xx.bus == bus,"Q"} = obj_xx{obj_xx.bus == bus,"Q"} + obj_load{obj_load.bus == bus,"Q"};                
%         end
    end

end