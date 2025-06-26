function [NET] = generate_general_rl_NET_v3(connect_mtx_rl, rl_T_nodes, PI_T_nodes, rl_T_NET, T_global)
    
    if sum(connect_mtx_rl,'all')

        %% Order the buses of the rl lines (bus_from < bus_to):
        for line = 1:1:size(rl_T_NET,1)

            if rl_T_NET.bus_from(line) > rl_T_NET.bus_to(line)
                bus_from = rl_T_NET.bus_from(line);
                bus_to = rl_T_NET.bus_to(line);
                rl_T_NET{line,"bus_from"} = bus_to;
                rl_T_NET{line,"bus_to"} = bus_from;
            end

        end
        
        %% Generate the global inputs/outputs of the RL NET
        
        inputs = [];
        outputs = [];

        % Bus voltages

            % Voltage is OUTPUT if:
            % - It is an empty bus between RL lines
            % - There is a TH connected + only RL lines
    
            % Voltage is INPUT if:
            % - It is an Additional TH bus (V_TH == vn[ADD_BUS]qd is an input)
            % - There is a PI line connected to the bus
            % - There is a voltage source element connected to the bus
        
         for i=1:1:size(rl_T_nodes.Node,1)
             strings = rl_T_nodes{i,2:end};
             strings = rmmissing(strings);
             if ((isempty(strings) & not(ismember(rl_T_nodes.Node(i),PI_T_nodes.Node)))) | (contains(strings,"TH") & not(contains(strings,"Additional")) & not(ismember(rl_T_nodes.Node(i),PI_T_nodes.Node))) 
                outputs = [outputs;{join(['NET','.vn',num2str(rl_T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(rl_T_nodes.Node(i)),'d'])}];
             else
                inputs = [inputs;{join(['NET','.vn',num2str(rl_T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(rl_T_nodes.Node(i)),'d'])}];
             end
         end

        % Line currents

            % Positive current: bus_from --> bus_to
            % Negative current: bus_to --> bus_from

        for i=1:1:size(rl_T_NET.bus_from,1)
            if rl_T_NET.B(i)==0
                if rl_T_NET.bus_from(i)>rl_T_NET.bus_to(i)
                    outputs = [outputs; {join(['NET','.iq_',num2str(rl_T_NET.bus_to(i)),'_',num2str(rl_T_NET.bus_from(i))])};{join(['NET','.id_',num2str(rl_T_NET.bus_to(i)),'_',num2str(rl_T_NET.bus_from(i))])}];
                else
                    outputs = [outputs; {join(['NET','.iq_',num2str(rl_T_NET.bus_from(i)),'_',num2str(rl_T_NET.bus_to(i))])};{join(['NET','.id_',num2str(rl_T_NET.bus_from(i)),'_',num2str(rl_T_NET.bus_to(i))])}];
                end
            end
        end

    %% Generate RL NET State-Space
        
        % Flag to check if there is an internal node:
        % A) Empty bus with only RL lines connected to it
        % B) TH bus with only RL lines connected to it
        internal_node = false; 
        
        % List of visited internal nodes
        internal_node_list = [];

        ii = 1;
        % Generate the State-Space of each RL line in rl_T_NET
        for i = 1:1:size(rl_T_NET.bus_from,1)

            bus = rl_T_NET.bus_to(i);

            % Generate SS of RL line
            NET.RL(i).R = rl_T_NET.R(i);
            NET.RL(i).L = rl_T_NET.L(i);
            NET.RL(i).bus_from = rl_T_NET.bus_from(i);
            NET.RL(i).bus_to = bus;
            ss_rl{i} = generate_ss_rl(rl_T_NET.R(i), rl_T_NET.L(i), rl_T_NET.bus_from(i), bus, T_global.f_Hz(1));
            NET.RL(i).SS = ss_rl{i};

            % Check what is connected in "bus_to" of the line
            strings = rl_T_nodes{rl_T_nodes.Node==bus,2:end};
            strings = rmmissing(strings);

            % Check if the "bus_to" is internal
            if (isempty(strings) & not(ismember(bus, PI_T_nodes.Node))) | (contains(strings,"TH") & not(contains(strings,"Additional")) & not(ismember(bus,PI_T_nodes.Node)))  

                % Raise internal_node flag
                internal_node = true;
                internal_node_list(end+1) = bus;

                % Identify direction of currents of the RL lines connected to the internal bus
                rows_in = rl_T_NET.bus_to == bus;
                rows_out = rl_T_NET.bus_from == bus;
                
                % Generate SS of BUS voltage calculation (internal bus)
                [ss_union_q{ii}, ss_union_d{ii}] = crea_union(rl_T_NET, rows_out, rows_in, bus);

                % Update counter
                ii=ii+1;

                % In order to not repeat an isolated node
                rl_T_nodes{rl_T_nodes.Node==bus,2:end} = '-'; 

            end
        end


        % Check if there is any internal node in "bus_from" that has not
        % been visited
        for i = 1:1:size(rl_T_NET.bus_from,1)

            bus = rl_T_NET.bus_from(i);
            % Check what is connected in "bus_from" of the line
            strings = rl_T_nodes{rl_T_nodes.Node==rl_T_NET.bus_from(i),2:end};
            strings = rmmissing(strings);

            % Check if the "bus_from" is internal
            if (isempty(strings) & not(ismember(bus, PI_T_nodes.Node))) | (contains(strings,"TH") & not(contains(strings,"Additional")) & not(ismember(bus,PI_T_nodes.Node)))  

                % Raise internal_node flag
                internal_node = true;
                if ~ismember(bus,internal_node_list)

                    % Identify direction of currents of the RL lines connected to the internal bus
                    rows_in = rl_T_NET.bus_to == bus;
                    rows_out = rl_T_NET.bus_from == bus;
                    
                    % Generate SS of BUS voltage calculation (internal bus)
                    [ss_union_q{ii}, ss_union_d{ii}] = crea_union(rl_T_NET, rows_out, rows_in, bus);
    
                    % Update counter
                    ii=ii+1;
    
                    % In order to not repeat an isolated node
                    rl_T_nodes{rl_T_nodes.Node==bus,2:end} = '-'; 

                end
            end
        end
                    
        if internal_node==true
            NET.SS = connect(ss_rl{:},ss_union_q{:},ss_union_d{:},inputs,outputs);
        else
            NET.SS = connect(ss_rl{:},inputs,outputs);
        end
    
    elseif ~sum(connect_mtx_rl,'all')
        NET.SS = {};
    end
    

          
    function [ss_union_q, ss_union_d] = crea_union(rl_T_NET,rows_out,rows_in,BUS) 

        % crea_union: State-space of BUS voltage calculation (internal bus)

        % Get RL values of RL lines connected to the BUS   
        R_out = rl_T_NET.R(rows_out);
        L_out = rl_T_NET.L(rows_out);
        R_in = rl_T_NET.R(rows_in);
        L_in = rl_T_NET.L(rows_in);
        
        % Get buses of RL lines connected to the BUS 
        nodes_out = rl_T_NET.bus_to(rows_out);
        nodes_in = rl_T_NET.bus_from(rows_in);
        
        % 1) q component --------------------------------------------------

        % Set output variable: BUS voltage
        outputnames_q = {join(['NET','.vn',num2str(BUS),'q'])};

        % Set input variables: 
        % - currents of RL lines connected to the BUS 
        % - voltages of buses of RL lines connected to the BUS
        % inputnames = [iq_in..., iq_out..., vnq_in..., vnq_out...]
        inputnames_q = [];
        for j=1:1:size(nodes_in,1)
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(nodes_in(j)),'_',num2str(BUS)])}];
        end
        for j=1:1:size(nodes_out,1)
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(BUS),'_',num2str(nodes_out(j))])}];
        end
        for j=1:1:size(nodes_in,1)
            inputnames_q = [inputnames_q;{join(['NET','.vn',num2str(nodes_in(j)),'q'])}];
        end
        for j=1:1:size(nodes_out,1)
            inputnames_q = [inputnames_q;{join(['NET','.vn',num2str(nodes_out(j)),'q'])}];
        end

        % Generate D_q matrix == calculation of BUS q-voltage
        sum_L = 0;
        D_q = zeros(1,size(inputnames_q,1));

        % Is

        for j = 1:1:size(nodes_in,1) % iq_in
            D_q(1,j) = R_in(j)/L_in(j);
            sum_L = sum_L - 1/L_in(j);
        end

        jj =1;    
        for j = (size(nodes_in,1)+1):1:((size(nodes_in,1)+size(nodes_out,1))) % iq_out
            D_q(1,j) = -R_out(jj)/L_out(jj);
            sum_L = sum_L - 1/L_out(jj);
            jj=jj+1;
        end
        
        % Vs

        jj=1;
        for j=((size(nodes_in,1)+1+size(nodes_out,1))):1:(2*size(nodes_in,1)+size(nodes_out,1)) % vq_in
            D_q(1,j) = -1/L_in(jj);
            jj=jj+1;
        end
    
        jj =1;
        for j=(2*size(nodes_in,1)+1+size(nodes_out,1)):1:(2*size(nodes_in,1)+2*size(nodes_out,1)) %vq_out
            D_q(1,j) = -1/L_out(jj);
            jj=jj+1;
        end
        D_q = (1/sum_L)*D_q;
      
        % 2) d component --------------------------------------------------

        % Set output variable: BUS voltage
        outputnames_d = {join(['NET','.vn',num2str(BUS),'d'])};

        % Set input variables: 
        % - currents of RL lines connected to the BUS 
        % - voltages of buses of RL lines connected to the BUS
        % inputnames = [id_in..., id_out..., vnd_in..., vnd_out...]
        inputnames_d = [];
        for j=1:1:size(nodes_in,1)
            inputnames_d = [inputnames_d;{join(['NET','.id_',num2str(nodes_in(j)),'_',num2str(BUS)])}];
        end
        for j=1:1:size(nodes_out,1)
            inputnames_d = [inputnames_d;{join(['NET','.id_',num2str(BUS),'_',num2str(nodes_out(j))])}];
        end
        for j=1:1:size(nodes_in,1)
            inputnames_d = [inputnames_d;{join(['NET','.vn',num2str(nodes_in(j)),'d'])}];
        end
        for j=1:1:size(nodes_out,1)
            inputnames_d = [inputnames_d;{join(['NET','.vn',num2str(nodes_out(j)),'d'])}];
        end

        % Generate D_d matrix == calculation of BUS d-voltage    
        sum_L=0;
        D_d = zeros(1,size(inputnames_d,1));

        % Is
        for j=1:1:size(nodes_in,1)
            D_d(1,j) = R_in(j)/L_in(j);
            sum_L = sum_L - 1/L_in(j);
        end
        jj =1;
        for j=(size(nodes_in,1)+1):1:((size(nodes_in,1)+size(nodes_out,1)))
            D_d(1,j) = -R_out(jj)/L_out(jj);
            sum_L = sum_L - 1/L_out(jj);
            jj=jj+1;
        end
        
        % Vs
        jj=1;
        for j=((size(nodes_in,1)+1+size(nodes_out,1))):1:(2*size(nodes_in,1)+size(nodes_out,1))
            D_d(1,j) = -1/L_in(jj);
            jj=jj+1;
        end
    
        jj =1;
        for j=(2*size(nodes_in,1)+1+size(nodes_out,1)):1:(2*size(nodes_in,1)+2*size(nodes_out,1))
            D_d(1,j) = -1/L_out(jj);
            jj=jj+1;
        end

        D_d = (1/sum_L)*D_d;

        % 3) Generate State-Space calculation of qd BUS voltage -----------

        A = [0];
        B = zeros(1,size(D_q,2));
        C = [0];
        ss_union_q = ss(A,B,C,D_q,'statename','','inputname',inputnames_q,'outputname',outputnames_q);
        ss_union_d = ss(A,B,C,D_d,'statename','','inputname',inputnames_d,'outputname',outputnames_d);
        
    end
       


    function ss_rl = generate_ss_rl(R1,L1,bus_from,bus_to,f)

        % Generate the state-space of an RL line
    
        A = [-R1/L1 -2*pi*f; 2*pi*f -R1/L1];
        B = [1/L1 0 -1/L1 0; 0 1/L1 0 -1/L1];
        C = [1 0; 0 1];
        D = [0 0 0 0; 0 0 0 0];
    
        if bus_from>bus_to
                inputname  = [{join(['NET','.vn',num2str(bus_to),'q']);join(['NET','.vn',num2str(bus_to),'d']);...
                              join(['NET','.vn',num2str(bus_from),'q']);join(['NET','.vn',num2str(bus_from),'d'])}];
                outputname = [{join(['NET','.iq_',num2str(bus_to),'_',num2str(bus_from)])};{join(['NET','.id_',num2str(bus_to),'_',num2str(bus_from)])}];
        else
                inputname = [{join(['NET','.vn',num2str(bus_from),'q']);join(['NET','.vn',num2str(bus_from),'d']);...
                              join(['NET','.vn',num2str(bus_to),'q']);join(['NET','.vn',num2str(bus_to),'d'])}];
                outputname = [{join(['NET','.iq_',num2str(bus_from),'_',num2str(bus_to)])};{join(['NET','.id_',num2str(bus_from),'_',num2str(bus_to)])}];
        end
        
        ss_rl = ss(A,B,C,D,'StateName',{join(['NET','.iq_',num2str(bus_from),'_',num2str(bus_to)]) ; join(['NET','.id_',num2str(bus_from),'_',num2str(bus_to)])},...
            'inputname',inputname,'outputname',outputname);
        
    end

end