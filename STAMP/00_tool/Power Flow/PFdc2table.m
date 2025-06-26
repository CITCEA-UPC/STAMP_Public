function T_XX = PFdc2table(T_XX, results_bus, results_xx_dc)

    for idx = 1:height(T_XX)
        bus_xx          = T_XX{idx,"bus"};
        bus_xx_dc       = T_XX{idx,"busdc"};
        T_XX.P(idx)     = results_xx_dc{results_xx_dc.bus == bus_xx_dc,"Pac"};
        T_XX.Pdc(idx)   = results_xx_dc{results_xx_dc.bus == bus_xx_dc,"Pdc"};
        T_XX.Vdc(idx)   = results_xx_dc{results_xx_dc.bus == bus_xx_dc,"Vm"};
        T_XX.Q(idx)     = results_xx_dc{results_xx_dc.bus == bus_xx_dc,"Q"};
        T_XX.V(idx)     = results_bus{results_bus.bus == bus_xx,"Vm"};
        T_XX.theta(idx) = results_bus{results_bus.bus == bus_xx,"theta"};

%         switch results_bus.type
%             case "slack"
%                 T_XX.type(idx) = 0;
%             case "PQ"
%                 T_XX.type(idx) = 1;
%             case "PV"
%                 T_XX.type(idx) = 2;
%         end
    end    

end