% Inputs:  ·T_NET: Table with the AC grid data
%          ·T_Trafo: Table with the Trafos data
%          ·T_MMC_Pac_GFll: Table with the MMC data controlling the AC
%                           power
%          ·T_MMC_Vdc_GFll: Table with the MMC data controlling the DC
%                           voltage
%          ·T_SG:  Table with the SG data
%          ·T_TH:  Table with the Thevenin data
%          ·T_shunt:  Table with the shunt elements data
% Outputs: ·Connectivity_Matrix: Matrix of the AC system, which bus_from is
%           connected to which bus_to
%          ·T_nodes: Table of nodes specifying which element/s is/are connected
%           in this node

function [Connectivity_Matrix,connect_mtx_PI,connect_mtx_rl, T_nodes] = generate_general_connectivity_matrix(T_NET,T_trafo, T_load, T_shunt, T_TH, T_SG, T_STATCOM, T_VSC, T_IPC, T_b2b, T_user)
    % Connectivity Matrix generation:
    n_nodes = max([max(T_NET.bus_from),max(T_NET.bus_to)]);
    connect_mtx_rl = zeros(n_nodes);
    connect_mtx_PI = zeros(n_nodes);
    for i=1:1:size(T_NET.bus_from,1)
        if T_NET.B(i)==0
            connect_mtx_rl(T_NET.bus_from(i),T_NET.bus_to(i))=1;
        else
            connect_mtx_PI(T_NET.bus_from(i),T_NET.bus_to(i))=1;
        end
    end
    connect_mtx_rl = connect_mtx_rl + connect_mtx_rl';
    connect_mtx_PI = connect_mtx_PI + connect_mtx_PI';
    Connectivity_Matrix = connect_mtx_PI+connect_mtx_rl;
    
    % Nodes specification:              
    tn = max(max([T_NET.bus_from;T_NET.bus_to;T_trafo.bus_from;T_trafo.bus_to]));             %Total node number
    
    nsb=zeros(1,tn);
    for node = 1:1:tn
        nsb(node)=sum(sum([T_load.bus==node; T_shunt.bus==node; T_TH.bus==node; T_SG.bus==node; T_STATCOM.bus==node; T_VSC.bus==node; T_IPC.bus==node; T_user.bus==node]));
    end
    nsb=max(nsb);

    sz = [tn nsb+1];                                    %Table size
    varNames = strings(nsb+1,1);
    varNames(1) = "Node";
    for i=1:1:(nsb)
        varNames(i+1) = strjoin(["Element",num2str(i)],'_');
    end
    varTypes = strings(nsb+1,1);
    varTypes(1) = "double";
    for i=1:1:(nsb)
        varTypes(i+1) = "string";
    end
    T_nodes = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

    %Assign values to the T_nodes table
    T_nodes.Node(1:end) = 1:1:size(T_nodes.Node,1);

    mmc_list = {T_IPC};

    for idx = 1:1:length(mmc_list)
        T_mmc = mmc_list{idx};
        for mmc =1:1:size(T_mmc.bus,1)
            for i =2:1:nsb+2
                if ismissing(T_nodes(T_mmc.bus(mmc),i))
                    T_nodes{T_mmc.bus(mmc),i} = join(["IPC",num2str(T_mmc.number(mmc))]);
                    break
                end
            end
        end
    end

    xx_list = {T_load, T_shunt, T_TH, T_SG, T_STATCOM, T_VSC, T_user};
    xx_names = ["Load", "Shunt", "TH", "SG", "STATCOM", "VSC", "user"];

    for idx = 1:1:length(xx_list)
        T_xx = xx_list{idx};
        for xx =1:1:size(T_xx.bus,1)
            for i =2:1:nsb+2
                if ismissing(T_nodes(T_xx.bus(xx),i))
                    T_nodes{T_xx.bus(xx),i} = join([xx_names(idx),num2str(T_xx.number(xx))]);
                    break
                end
            end
        end
    end

end