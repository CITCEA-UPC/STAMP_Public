% Inputs:  ·T_NET: Table with the AC grid data
%          ·T_MMC_Pac_GFll: Table with the MMC data controlling the AC
%                           power
%          ·T_MMC_Vdc_GFll: Table with the MMC data controlling the DC
%                           voltage
%          ·T_SG:  Table with the SG data
%          ·T_TH:  Table with the Thevenin data
% Outputs: ·Connectivity_Matrix: Matrix of the AC system, which NodeA is
%           connected to which NodeB
%          ·T_nodes: Table of nodes specifying which element/s is/are connected
%           in this node
function [Connectivity_Matrix, T_nodes] = generate_connectivity_matrix(T_NET, T_MMC_GFll_Vdc,T_MMC_GFll_Pac, T_SG,T_TH)
    % Connectivity Matrix generation:
    n_nodes = max([max(T_NET.NodeA),max(T_NET.NodeB)]);
    Connectivity_Matrix = zeros(n_nodes);
    for i=1:1:size(T_NET.NodeA,1)
        Connectivity_Matrix(T_NET.NodeA(i),T_NET.NodeB(i))=1;
    end
    Connectivity_Matrix = Connectivity_Matrix + Connectivity_Matrix';
    
    % Nodes specification:              
    tn = max(max(T_NET.NodeA,T_NET.NodeB));             %Total node number
    
    nsb=zeros(1,tn);
    for node = 1:1:tn
        nsb(i)=sum(sum([T_MMC_GFll_Vdc.NodeAC==node;T_MMC_GFll_Pac.NodeAC==node;T_SG.NodeAC==node;T_TH.NodeAC==node]));
    end
    nsb=max(nsb)

    sz = [tn nsb+2];                                    %Table size
    varNames = strings(nsb+2,1);
    varNames(1) = "Node";
    for i=1:1:(nsb+1)
        varNames(i+1) = strjoin(["Element",num2str(i)],'_');
    end
    varTypes = strings(nsb+2,1);
    varTypes(1) = "double";
    for i=1:1:(nsb+1)
        varTypes(i+1) = "string";
    end
    T_nodes = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    %Assign values to the T_nodes table
    T_nodes.Node(1:end) = 1:1:size(T_nodes.Node,1);
    for mmc=1:1:size(T_MMC_GFll_Vdc.NodeAC,1)
        for i =2:1:nsb+2
            if ismissing(T_nodes(T_MMC_GFll_Vdc.NodeAC(mmc),i))
                T_nodes{T_MMC_GFll_Vdc.NodeAC(mmc),i}=join(["MMC",num2str(T_MMC_GFll_Vdc.Number(mmc))]);
                break
            end
        end
    end
    for mmc=1:1:size(T_MMC_GFll_Pac.NodeAC,1)
        for i =2:1:nsb+2
            if ismissing(T_nodes(T_MMC_GFll_Pac.NodeAC(mmc),i))
                T_nodes{T_MMC_GFll_Pac.NodeAC(mmc),i}=join(["MMC",num2str(T_MMC_GFll_Pac.Number(mmc))]);
                break
            end
        end
    end
    for sg=1:1:size(T_SG.NodeAC,1)
        for i =2:1:nsb+2
            if ismissing(T_nodes(T_SG.NodeAC(sg),i))
                T_nodes{T_SG.NodeAC(sg),i}=join(["SG",num2str(T_SG.Number(sg))]);
                break
            end
        end
    end
    for th=1:1:size(T_TH.NodeAC,1)
        for i =2:1:nsb+2
            if ismissing(T_nodes(T_TH.NodeAC(th),i))
                T_nodes{T_TH.NodeAC(th),i}=join(["TH",num2str(T_TH.Number(th))]);
                break
            end
        end
    end
end