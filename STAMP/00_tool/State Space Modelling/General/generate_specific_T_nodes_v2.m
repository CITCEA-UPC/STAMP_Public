function T_nodes_specific = generate_specific_T_nodes_v2(Connectivity_Matrix,T_nodes)
    lines = sum(Connectivity_Matrix);
    for line = 1:1:size(lines,2)
        if lines(line)==0
            T_nodes(T_nodes.Node==line,:)=[];
        end
    end
    T_nodes_specific=T_nodes;
end