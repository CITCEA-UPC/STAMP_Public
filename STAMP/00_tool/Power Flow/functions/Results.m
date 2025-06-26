function obj = Results(grid)

    % create tables to store results
    obj.bus    = table('Size', [grid.nb 5],'VariableTypes', ["double","double","double","double","string"],'VariableNames', ["bus","Vm","theta","V","type"]);

    obj.PQ_lines= grid.branch(:,["number" "bus_from" "bus_to"]); 
    obj.PQ_lines.Pf = zeros(height(obj.PQ_lines),1);
    obj.PQ_lines.Qf = zeros(height(obj.PQ_lines),1);
    obj.PQ_lines.Pt = zeros(height(obj.PQ_lines),1);
    obj.PQ_lines.Qt = zeros(height(obj.PQ_lines),1);

    if isempty(grid.load); obj.load =[]; else; obj.load = grid.load(:,["number" "bus" "P" "Q"]); end 
    if isempty(grid.th);   obj.th   =[]; else; obj.th   = grid.th(:,["number" "bus" "P" "Q"]); end
    if isempty(grid.sg);   obj.sg   =[]; else; obj.sg   = grid.sg(:,["number" "bus" "P" "Q"]); end
    if isempty(grid.stat); obj.stat =[]; else; obj.stat = grid.stat(:,["number" "bus" "P" "Q"]); end
    if isempty(grid.vsc);  obj.vsc  =[]; else; obj.vsc  = grid.vsc(:,["number" "bus" "P" "Q"]); end
    if isempty(grid.user); obj.user =[]; else; obj.user = grid.user(:,["number" "bus" "P" "Q"]); end
    
    if isempty(grid.b2b)  
        obj.b2b  =[]; 
    else
        obj.b2b     = grid.b2b(:,["bus1" "bus2" "P1" "Q1" "P2" "Q2"]); 
        obj.b2b.Vdc1 = grid.b2b.Vdc;
        obj.b2b.Vdc2 = grid.b2b.Vdc;
        obj.b2b.Idc  = zeros(height(grid.b2b),1);
    end 


    %% BUS VOLTAGES & ANGLES
    
    V = grid.Vm .* exp(1i .* grid.theta);
    Ss = diag(V) * conj(grid.Y) * conj(V);
    theta = grid.theta * 180 / pi;
    theta = wrapTo180(theta); % wrap angle
    
    obj.bus{:,"bus"} = (1:1:grid.nb)';
    obj.bus{:,"Vm"} = grid.Vm;
    obj.bus{:,"theta"} = theta;
    obj.bus{:,"V"} = V;

    %% LOADS
    % negative sign because it is a load

    % RX loads
    % calculate P and Q 
    for k=1:1:length(grid.bus_rx)
        bus_rx = grid.bus_rx(k); %current load bus
        obj.load{obj.load.bus == bus_rx,"P"} = -grid.Vm(bus_rx) .^ 2 / grid.load{grid.load.bus==bus_rx,"R"};
        obj.load{obj.load.bus == bus_rx,"Q"} = -grid.Vm(bus_rx) .^ 2 / grid.load{grid.load.bus==bus_rx,"X"};
    end            
    
    % PQ loads
    for k=1:1:length(grid.bus_pq)
        bus_pq = grid.bus_pq(k); %current load bus
        obj.load{obj.load.bus == bus_pq,"P"} = -grid.load{grid.load.bus == bus_pq,"P"};       %- real(grid.Sload(bus_pq));
        obj.load{obj.load.bus == bus_pq,"Q"} = -grid.load{grid.load.bus == bus_pq,"Q"};       %- imag(grid.Sload(bus_pq));
    end

    %% THEVENIN

    for k=1:1:length(grid.bus_th)
        bus_th = grid.bus_th(k);
        if ismember(bus_th, grid.pq)
            obj.th{obj.th.bus == bus_th,"P"} = grid.th{grid.th.bus == bus_th,"P"}; 
            obj.th{obj.th.bus == bus_th,"Q"} = grid.th{grid.th.bus == bus_th,"Q"}; 
        else
            if ismember(bus_th,grid.load.bus)
                obj.th{obj.th.bus == bus_th,"P"} = real(Ss(bus_th)) - obj.load{obj.load.bus == bus_th,"P"}; 
                obj.th{obj.th.bus == bus_th,"Q"} = imag(Ss(bus_th)) - obj.load{obj.load.bus == bus_th,"Q"};
            else
                obj.th{obj.th.bus == bus_th,"P"} = real(Ss(bus_th)); 
                obj.th{obj.th.bus == bus_th,"Q"} = imag(Ss(bus_th));
            end
        end
    end
    
    %%  ELEMENTS 
    %   only PQ buses considered for the case of >1 element/bus    
    for k=1:1:grid.nb
        bus = grid.bus(k);

        obj.vsc  = results_xx(grid, Ss, bus, grid.bus_vsc, obj.vsc);
        obj.sg   = results_xx(grid, Ss, bus, grid.bus_sg, obj.sg);
        obj.stat = results_xx(grid, Ss, bus, grid.bus_stat, obj.stat);
        obj.user = results_xx(grid, Ss, bus, grid.bus_user, obj.user);

    end

    %% B2B

    for k=1:1:length(grid.b2b.bus1)    
        bus1 = grid.b2b.bus1(k);
        bus2 = grid.b2b.bus2(k);
        
        obj.b2b{obj.b2b.bus1 == bus1,"P1"} = real(Ss(bus1));
        obj.b2b{obj.b2b.bus2 == bus2,"P2"} = real(Ss(bus2));
        obj.b2b{obj.b2b.bus1 == bus1,"Q1"} = imag(Ss(bus1));
        obj.b2b{obj.b2b.bus2 == bus2,"Q2"} = imag(Ss(bus2));
        obj.b2b{obj.b2b.bus1 == bus1,"Vdc1"} = grid.Vdc1;
        obj.b2b{obj.b2b.bus2 == bus2,"Vdc2"} = grid.Vdc2;
        obj.b2b{obj.b2b.bus1 == bus1,"Idc1"} = -grid.Idc;
        obj.b2b{obj.b2b.bus2 == bus2,"Idc2"} = grid.Idc;

        if ismember(bus1, grid.bus_th) 
            obj.b2b{obj.b2b.bus1 == bus1,"P1"} = obj.b2b{obj.b2b.bus1 == bus1,"P1"} - grid.th{grid.th.bus == bus1,"P"};
            obj.b2b{obj.b2b.bus1 == bus1,"Q1"} = obj.b2b{obj.b2b.bus1 == bus1,"Q1"} - grid.th{grid.th.bus == bus1,"Q"};
        end
        if ismember(bus1, grid.bus_pq) 
            obj.b2b{obj.b2b.bus1 == bus1,"P1"} = obj.b2b{obj.b2b.bus1 == bus1,"P1"} - grid.load{grid.load.bus == bus,"P"};
            obj.b2b{obj.b2b.bus1 == bus1,"Q1"} = obj.b2b{obj.b2b.bus1 == bus1,"Q1"} - grid.load{grid.load.bus == bus,"Q"};                
        end

        if ismember(bus2, grid.bus_th) 
            obj.b2b{obj.b2b.bus2 == bus2,"P2"} = obj.b2b{obj.b2b.bus2 == bus2,"P2"} - grid.th{grid.th.bus == bus2,"P"};
            obj.b2b{obj.b2b.bus2 == bus2,"Q2"} = obj.b2b{obj.b2b.bus2 == bus2,"Q2"} - grid.th{grid.th.bus == bus2,"Q"};
        end
        if ismember(bus2, grid.bus_pq) 
            obj.b2b{obj.b2b.bus2 == bus2,"P2"} = obj.b2b{obj.b2b.bus2 == bus2,"P2"} - grid.load{grid.load.bus == bus,"P"};
            obj.b2b{obj.b2b.bus2 == bus2,"Q2"} = obj.b2b{obj.b2b.bus2 == bus2,"Q2"} - grid.load{grid.load.bus == bus,"Q"};                
        end

    end

    
    %% BRANCHES

    % compute power flow through lines
    n_c = 1;
    for k=1:1:length(grid.bus)
        for j=k+1:1:length(grid.bus)
            if not(grid.Y(k,j) == 0)
                If = V(k) * grid.Y(k,j) - V(j) * grid.Y(j,k);
                It = V(j) * grid.Y(j,k) - V(k) * grid.Y(k,j);
                Sf = - V(k) * conj(If);
                St = - V(j) * conj(It);
                Pf = real(Sf);
                Qf = imag(Sf);
                Pt = real(St);
                Qt = imag(St);

                obj.PQ_lines{n_c,'Pf'}  = Pf;
                obj.PQ_lines{n_c,'Qf'}  = Qf;
                obj.PQ_lines{n_c,'Pt'} = Pt;
                obj.PQ_lines{n_c,'Qt'} = Qt;

                n_c = n_c + 1;
            end
        end
    end
    

    %% ADD ADDITIONAL DATA
    % add bus type to global (?)
    for row = 1:height(obj.bus)
        if ismember(obj.bus{row,"bus"},grid.pq)
            obj.bus{row,"type"} = "PQ";
        elseif ismember(obj.bus{row,"bus"},grid.pv)
            obj.bus{row,"type"} = "PV";
        else 
            obj.bus{row,"type"} = "slack";
        end
    end
end

