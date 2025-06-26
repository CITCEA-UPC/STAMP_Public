function [NET] = generate_rl_NET(Connectivity_Matrix,T_nodes,PI_T_nodes,T_NET)
%Flag that checks if there is at least one internal node
internal_node=false;

inputs = [];
outputs = [];

for i=1:1:size(T_nodes.Node,1)
    if ismissing(T_nodes(i,2:end))%Chech if there is something connected to the node
        outputs = [outputs;{join(['NET','.vn',num2str(T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(T_nodes.Node(i)),'d'])}];
    else
        inputs = [inputs;{join(['NET','.vn',num2str(T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(T_nodes.Node(i)),'d'])}];
    end
end
for i=1:1:size(T_NET.NodeA,1)
    outputs = [outputs; {join(['NET','.iq_',num2str(T_NET.NodeA(i)),'_',num2str(T_NET.NodeB(i))])};{join(['NET','.id_',num2str(T_NET.NodeA(i)),'_',num2str(T_NET.NodeB(i))])}];
end

ii=1;
for i = 1:1:size(T_NET.NodeA,1)
    NET.RL(i).R=T_NET.R(i);
    NET.RL(i).L=T_NET.L(i);
    NET.RL(i).NodeA=T_NET.NodeA(i);
    NET.RL(i).NodeB=T_NET.NodeB(i);
    ss_rl{i} = crea_ss_rl(T_NET.R(i),T_NET.L(i),T_NET.NodeA(i),T_NET.NodeB(i));
    NET.RL(i).SS=ss_rl{i};
    %NET.RL.SS(i)=ss_rl
    if ismissing(T_nodes(T_NET.NodeB(i),2:end))
        internal_node=true;
        line_nodes = find(Connectivity_Matrix(T_NET.NodeB(i),:)==1);
        R= zeros(size(line_nodes,2));
        L= zeros(size(line_nodes,2));
        rows_menys = T_NET.NodeB == T_NET.NodeB(i);
        rows_mes = T_NET.NodeA == T_NET.NodeB(i);
        
        [ss_union_q{ii}, ss_union_d{ii}] = crea_union(T_NET,rows_mes,rows_menys,T_NET.NodeB(i));
        ii=ii+1;
        T_nodes{T_NET.NodeB(i),2:end} = '-'; %In order to not repeat an isolated node
    end
end

if internal_node==true
    NET.SS = connect(ss_rl{:},ss_union_q{:},ss_union_d{:},inputs,outputs);
else
    NET.SS = connect(ss_rl{:},inputs,outputs);
end

    function [ss_union_q, ss_union_d] = crea_union(system_table,rows_mes,rows_menys,Node)
    R_mes = system_table.R(rows_mes);
    L_mes = system_table.L(rows_mes);
    
    
    R_menys = system_table.R(rows_menys);
    L_menys = system_table.L(rows_menys);
    
    nodes_mes = system_table.NodeB(rows_mes);
    nodes_menys = system_table.NodeA(rows_menys);
    
    %QQQQQQQQQ!!!!!!!
    outputnames_q = {join(['NET','.vn',num2str(Node),'q'])};
    inputnames_q = [];
    for j=1:1:size(nodes_menys,1)
        inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(nodes_menys(j)),'_',num2str(Node)])}];
    end
    for j=1:1:size(nodes_mes,1)
        inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(Node),'_',num2str(nodes_mes(j))])}];
    end
    
    for j=1:1:size(nodes_menys,1)
        inputnames_q = [inputnames_q;{join(['NET','.vn',num2str(nodes_menys(j)),'q'])}];
    end
    for j=1:1:size(nodes_mes,1)
        inputnames_q = [inputnames_q;{join(['NET','.vn',num2str(nodes_mes(j)),'q'])}];
    end

    sumatori = 0;
    D_q = zeros(1,size(inputnames_q,1));
    %Is
    for j=1:1:size(nodes_menys,1)
        D_q(1,j) = R_menys(j)/L_menys(j);
        sumatori = sumatori - 1/L_menys(j);
    end
    jj =1;

    for j=(size(nodes_menys,1)+1):1:((size(nodes_menys,1)+size(nodes_mes,1)))
        D_q(1,j) = -R_mes(jj)/L_mes(jj);
        sumatori = sumatori - 1/L_mes(jj);
        jj=jj+1;
    end
    
    %Vs
    jj=1;
    for j=((size(nodes_menys,1)+1+size(nodes_mes,1))):1:(2*size(nodes_menys,1)+size(nodes_mes,1))
        D_q(1,j) = -1/L_menys(jj);
        jj=jj+1;
    end

    jj =1;
    for j=(2*size(nodes_menys,1)+1+size(nodes_mes,1)):1:(2*size(nodes_menys,1)+2*size(nodes_mes,1))
        D_q(1,j) = -1/L_mes(jj);
        jj=jj+1;
    end
    D_q = (1/sumatori)*D_q;
    %DDDDDDDDDDDD!!!!!!!
    outputnames_d = {join(['NET','.vn',num2str(Node),'d'])};
    inputnames_d = [];
    for j=1:1:size(nodes_menys,1)
        inputnames_d= [inputnames_d;{join(['NET','.id_',num2str(nodes_menys(j)),'_',num2str(Node)])}];
    end
    for j=1:1:size(nodes_mes,1)
        inputnames_d = [inputnames_d;{join(['NET','.id_',num2str(Node),'_',num2str(nodes_mes(j))])}];
    end
    
    for j=1:1:size(nodes_menys,1)
        inputnames_d = [inputnames_d;{join(['NET','.vn',num2str(nodes_menys(j)),'d'])}];
    end
    for j=1:1:size(nodes_mes,1)
        inputnames_d = [inputnames_d;{join(['NET','.vn',num2str(nodes_mes(j)),'d'])}];
    end

    sumatori=0;
    D_d = zeros(1,size(inputnames_d,1));
    %Is
    for j=1:1:size(nodes_menys,1)
        D_d(1,j) = R_menys(j)/L_menys(j);
        sumatori = sumatori - 1/L_menys(j);
    end
    jj =1;
    for j=(size(nodes_menys,1)+1):1:((size(nodes_menys,1)+size(nodes_mes,1)))
        D_d(1,j) = -R_mes(jj)/L_mes(jj);
        sumatori = sumatori - 1/L_mes(jj);
        jj=jj+1;
    end
    
    %Vs
    jj=1;
    for j=((size(nodes_menys,1)+1+size(nodes_mes,1))):1:(2*size(nodes_menys,1)+size(nodes_mes,1))
        D_d(1,j) = -1/L_menys(jj);
        jj=jj+1;
    end

    jj =1;
    for j=(2*size(nodes_menys,1)+1+size(nodes_mes,1)):1:(2*size(nodes_menys,1)+2*size(nodes_mes,1))
        D_d(1,j) = -1/L_mes(jj);
        jj=jj+1;
    end
    D_d = (1/sumatori)*D_d;
    A = [0];
    B = zeros(1,size(D_q,2));
    C = [0];
    ss_union_q = ss(A,B,C,D_q,'statename','','inputname',inputnames_q,'outputname',outputnames_q);
    ss_union_d = ss(A,B,C,D_d,'statename','','inputname',inputnames_d,'outputname',outputnames_d);
end
     
    function ss_rl = crea_ss_rl(R1,L1,NodeA,NodeB)
    A = [-R1/L1 -2*pi*60; 2*pi*60 -R1/L1];
    B = [1/L1 0 -1/L1 0; 0 1/L1 0 -1/L1];
    C = [1 0; 0 1];
    D = [0 0 0 0; 0 0 0 0];
    ss_rl = ss(A,B,C,D,'StateName',{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])},...
        'inputname',{join(['NET','.vn',num2str(NodeA),'q']);join(['NET','.vn',num2str(NodeA),'d']);...
                     join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d'])},...
        'outputname',{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])});
end

end