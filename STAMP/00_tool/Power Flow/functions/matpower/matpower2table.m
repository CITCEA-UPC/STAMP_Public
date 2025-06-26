function results = matpower2table(bus_pf, gen_pf)
    setup_globals; % Import global variables names

    gen_elements = [strings(size(gen_pf,1),1)];
    ii=1;
    %case TH
    for bus = 1:1:size(T_nodes,1)
        for element=2:1:size(T_nodes,2)
            name = T_nodes{bus,element};
            if contains(name,"TH")
                gen_elements(ii) = name;
                ii=ii+1;
            end
        end
    end
    %case SG
    for bus = 1:1:size(T_nodes,1)
        for element=2:1:size(T_nodes,2)
            name = T_nodes{bus,element};
            if contains(name,"SG")
                gen_elements(ii) = name;
                ii=ii+1;
            end
        end
    end
    %case VSC
    for bus = 1:1:size(T_nodes,1)
        for element=2:1:size(T_nodes,2)
            name = T_nodes{bus,element};
            if contains(name,"VSC")
                gen_elements(ii) = name;
                ii=ii+1;
            end
        end
    end
    %case user
    for bus = 1:1:size(T_nodes,1)
        for element=2:1:size(T_nodes,2)
            name = T_nodes{bus,element};
            if contains(name,"user")
                gen_elements(ii) = name;
                ii=ii+1;
            end
        end
    end

    % %Natural sorting using regexp
    % tokens = regexp(gen_elements, '(\D+)\s*(\d+)', 'tokens');
    % 
    % % Convert tokens into sortable cell array
    % prefixes = cellfun(@(x) x{1}{1}, tokens, 'UniformOutput', false);
    % numbers = cellfun(@(x) str2double(x{1}{2}), tokens);
    % 
    % % Combine and sort
    % [~, idx] = sortrows([prefixes, num2cell(numbers)]);
    % gen_elements = gen_elements(idx);
    
    %gen_elements = sort(gen_elements);

    baseMVA = T_global.Sb_MVA(1); %System power base in power-flow

        % results: struct with fields 'bus', 'load', 'th', 'sg', 'vsc', 'user'
        
        % bus
        results.bus = T_PF;
        results.bus.Vm = bus_pf(:,8);
        results.bus.theta = bus_pf(:,9);
        type = cell(height(T_PF),1);
        for idx = 1:height(T_PF)
            if bus_pf(idx,2) == 1
                type{idx,1} = "PQ";
            elseif bus_pf(idx,2) == 2
                type{idx,1} = "PV";
            elseif bus_pf(idx,2) == 3
                type{idx,1} = "slack";
            elseif bus_pf(idx,2) == 4
                type{idx,1} = "isolated";
            end      
        end
        results.bus(:,"type") = cell2table(type);
        results.bus = [results.bus T_nodes(ismember(T_nodes.Node,bus_pf(:,1)),2:end)];
        
        % load
        results.load = T_load(:,["number","bus","P","Q"]);

        % if any(bus_pf(:,4)<0)
        %     ME = MException('There is a load with Q<0. Capacitive loads are not implemented yet');
        %     throw(ME)         
        % end
        
        for idx = 1:height(T_load)
            busNum = T_load{idx,"bus"};
            row = bus_pf(ismember(bus_pf(:,1),busNum, 'rows'),:);
            if T_load{idx,"type"}{:} == 'PQ'
                results.load{idx,"P"} = row(3)/baseMVA;
                results.load{idx,"Q"} = row(4)/baseMVA;
            elseif T_load{idx,"type"}{:} == 'RX'
                results.load{idx,"P"} = results.bus.Vm(results.bus.bus==busNum)^2/T_load.R(idx);
                results.load{idx,"Q"} = results.bus.Vm(results.bus.bus==busNum)^2/T_load.X(idx);
                if isinf(results.load{idx,"Q"})
                    results.load{idx,"Q"} = 0;
                end
            end
        end

        %Shunts
        PQshunt = table('Size',[size(T_shunt,1) 2],'VariableTypes',["double", "double"],'VariableNames',{'P','Q'});
        results.shunt = [T_shunt(:,["number","bus"]) PQshunt];
        for idx = 1:height(T_shunt)
            shunt_number=T_shunt.number(idx);
            busNum = T_shunt{idx,"bus"};
            row = bus_pf(ismember(bus_pf(:,1),busNum, 'rows'),:);
            Z_R= T_shunt.R(shunt_number)/T_shunt.Zbpu_l2g(shunt_number);
            Z_L=1j*2*pi*T_global.f_Hz(T_shunt.Area(shunt_number))*T_shunt.L(shunt_number)/T_shunt.Zbpu_l2g(shunt_number);
            Z_C=1/(1j*2*pi*T_global.f_Hz(T_shunt.Area(shunt_number))*T_shunt.C(shunt_number))/T_shunt.Zbpu_l2g(shunt_number);
            Z_shunt=Z_R+Z_L+Z_C;
            phi = atan(imag(Z_shunt)/real(Z_shunt));

            results.shunt{idx,"P"} = results.bus.Vm(results.bus.bus==busNum)^2/abs(Z_shunt)*cos(phi);
            results.shunt{idx,"Q"} = results.bus.Vm(results.bus.bus==busNum)^2/abs(Z_shunt)*sin(phi);
            %results.shunt{idx,"P"} = row(3)/baseMVA+row(5)/baseMVA
            %results.shunt{idx,"Q"} = row(4)/baseMVA+row(6)/baseMVA
        end
        
        % TH
        results.th = T_TH(:,["number","bus","P","Q"]);
        T_TH_sorted = sortrows(T_TH,'bus','ascend');
        for idx = 1:height(T_TH_sorted)
            elementNum = T_TH_sorted.number(idx);
            busNum = T_TH_sorted.bus(idx);
            name = join(["TH", num2str(elementNum)]);
            %p_idx = find(gen_pf(:,1) == busNum);
            p_idx = find(gen_elements==name);
            results.th.P(idx) = gen_pf(p_idx,2)/baseMVA;
            results.th.Q(idx) = gen_pf(p_idx,3)/baseMVA;
        end
        
        % SG
        % Updated in version 7!
        results.sg = T_SG(:,["number","bus","P","Q"]);
        T_SG_sorted = sortrows(T_SG,'bus','ascend');
        for idx = 1:height(T_SG_sorted)
            elementNum = T_SG_sorted.number(idx);
            busNum = T_SG_sorted.bus(idx);
            name = join(["SG", num2str(elementNum)]);
            %p_idx = find(gen_pf(:,1) == busNum);
            p_idx = find(gen_elements==name);
            results.sg.P(idx) = gen_pf(p_idx,2)/baseMVA;
            results.sg.Q(idx) = gen_pf(p_idx,3)/baseMVA;
        end
       
        % VSC
        % Updated in version 7!
        results.vsc = T_VSC(:,["number","bus","P","Q"]);
        T_VSC_sorted = sortrows(T_VSC, 'bus','ascend');
        for idx = 1:height(T_VSC_sorted)
            elementNum = T_VSC_sorted.number(idx);
            busNum = T_VSC_sorted.bus(idx);
            name = join(["VSC", num2str(elementNum)]);
            %p_idx = find(gen_pf(:,1) == busNum);
            %p_idx = find(gen_pf(:,1) == elementNum);
            p_idx = find(gen_elements==name);
            results.vsc.P(idx) = gen_pf(p_idx,2)/baseMVA;
            results.vsc.Q(idx) = gen_pf(p_idx,3)/baseMVA;
        end

        % % IPC
        % results.ipc = T_IPC(:,["number","bus","P","Q"]);
        % for idx = 1:height(T_IPC)
        %     busNum = T_IPC.bus(idx);
        %     results.ipc.P(idx) = gen_pf(find(gen_pf(:,1) == busNum,1),2)/baseMVA;
        %     results.ipc.Q(idx) = gen_pf(find(gen_pf(:,1) == busNum,1),3)/baseMVA;
        % end
        
        % USER
        % Updated in version 7!
        results.user = T_user(:,["number","bus","P","Q"]);
        for idx = 1:height(T_user)
            elementNum = T_user.number(idx);
            busNum = T_user.bus(idx);
            name = join(["user", num2str(elementNum)]);
            %p_idx = find(gen_pf(:,1) == busNum);
            p_idx = find(gen_elements==name);
            results.user.P(idx) = gen_pf(p_idx,2)/baseMVA;
            results.user.Q(idx) = gen_pf(p_idx,3)/baseMVA;
        end

end

