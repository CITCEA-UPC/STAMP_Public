function T_XX = PF2table(T_XX, results_bus, results_xx)

    for idx = 1:height(T_XX)
        bus_xx          = T_XX{idx,"bus"};
        num_xx          = T_XX{idx,"number"};
        T_XX.P(idx)     = results_xx{results_xx.bus == bus_xx & results_xx.number == num_xx,"P"};
        T_XX.Q(idx)     = results_xx{results_xx.bus == bus_xx & results_xx.number == num_xx,"Q"};
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