function T_nodes_specific = generate_specific_T_nodes(Connectivity_Matrix,T_nodes)
    [a,b] = find(Connectivity_Matrix>0);
    maxim = max(max(a,b));
    minim = min(min(a,b));
    T_nodes_specific=T_nodes(minim:maxim,:);
end