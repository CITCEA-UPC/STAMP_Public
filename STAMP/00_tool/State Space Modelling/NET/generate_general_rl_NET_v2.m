function [NET] = generate_general_rl_NET_v2(Connectivity_Matrix,T_nodes,PI_T_nodes,T_NET)
%Flag that checks if there is at least one internal node
internal_node=false;

inputs = [];
outputs = [];

 for i=1:1:size(T_nodes.Node,1)
     strings = T_nodes{i,2:end};
     strings = rmmissing(strings);
     if ((isempty(strings) & not(ismember(i,PI_T_nodes.Node)))) | (contains(strings,"TH") & not(contains(strings,"Additional")) & not(ismember(i,PI_T_nodes.Node))) %Chech if there is something connected to the node
          %if sum(Connectivity_Matrix(i,:))>0  %&& sum(Connectivity_Matrix_PI(i,:))==0
             outputs = [outputs;{join(['NET','.vn',num2str(T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(T_nodes.Node(i)),'d'])}];
% %         elseif sum(Connectivity_Matrix(i,:))>0  && sum(Connectivity_Matrix_PI(i,:))>0
% %             inputs = [inputs;{join(['NET','.vn',num2str(T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(T_nodes.Node(i)),'d'])}];
          %end
     else
        inputs = [inputs;{join(['NET','.vn',num2str(T_nodes.Node(i)),'q'])};{join(['NET','.vn',num2str(T_nodes.Node(i)),'d'])}];
     end
 end
for i=1:1:size(T_NET.NodeA,1)
    if T_NET.C(i)==0
        if T_NET.NodeA(i)>T_NET.NodeB(i)
            outputs = [outputs; {join(['NET','.iq_',num2str(T_NET.NodeB(i)),'_',num2str(T_NET.NodeA(i))])};{join(['NET','.id_',num2str(T_NET.NodeB(i)),'_',num2str(T_NET.NodeA(i))])}];
        else
            outputs = [outputs; {join(['NET','.iq_',num2str(T_NET.NodeA(i)),'_',num2str(T_NET.NodeB(i))])};{join(['NET','.id_',num2str(T_NET.NodeA(i)),'_',num2str(T_NET.NodeB(i))])}];
        end
    end
end

ii=1;
for i = 1:1:size(T_NET.NodeA,1)
    NET.RL(i).R=T_NET.R(i);
    NET.RL(i).L=T_NET.L(i);
    NET.RL(i).NodeA=T_NET.NodeA(i);
    NET.RL(i).NodeB=T_NET.NodeB(i);
    ss_rl{i} = crea_ss_rl(T_NET.R(i),T_NET.L(i),T_NET.NodeA(i),T_NET.NodeB(i));
    NET.RL(i).SS=ss_rl{i};
    strings = T_nodes{T_nodes.Node==T_NET.NodeB(i),2:end};
    strings = rmmissing(strings);
    if ((isempty(strings) & not(ismember(T_nodes{T_nodes.Node==T_NET.NodeB(i),1},PI_T_nodes.Node)))) | (contains(strings,"TH") & not(contains(strings,"Additional")) & not(ismember(T_nodes{T_nodes.Node==T_NET.NodeB(i),1},PI_T_nodes.Node)))  
        internal_node=true;
        %line_nodes = find(Connectivity_Matrix(T_NET.NodeB(i),:)==1);
        line_nodes = find(Connectivity_Matrix(T_NET.NodeB(i),:)>0);
        R= zeros(size(line_nodes,2));
        L= zeros(size(line_nodes,2));
        rows_menys = T_NET.NodeB == T_NET.NodeB(i);
        rows_mes = T_NET.NodeA == T_NET.NodeB(i);
        
        [ss_union_q{ii}, ss_union_d{ii}] = crea_union(T_NET,rows_mes,rows_menys,T_NET.NodeB(i));
        ii=ii+1;
        T_nodes{T_nodes.Node==T_NET.NodeB(i),2:end} = '-'; %In order to not repeat an isolated node
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
        if nodes_menys(j)<Node
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(nodes_menys(j)),'_',num2str(Node)])}];
        else
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(Node),'_',num2str(nodes_menys(j))])}];
        end
    end
    for j=1:1:size(nodes_mes,1)
        if nodes_mes(j)>Node
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(Node),'_',num2str(nodes_mes(j))])}];
        else
            inputnames_q = [inputnames_q;{join(['NET','.iq_',num2str(nodes_mes(j)),'_',num2str(Node)])}];
        end
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
        if nodes_menys(j)<Node
            inputnames_d= [inputnames_d;{join(['NET','.id_',num2str(nodes_menys(j)),'_',num2str(Node)])}];
        else
            inputnames_d= [inputnames_d;{join(['NET','.id_',num2str(Node),'_',num2str(nodes_menys(j))])}];
        end
    end
    for j=1:1:size(nodes_mes,1)
        if nodes_mes(j)>Node
            inputnames_d = [inputnames_d;{join(['NET','.id_',num2str(Node),'_',num2str(nodes_mes(j))])}];
        else
            inputnames_d = [inputnames_d;{join(['NET','.id_',num2str(nodes_mes(j)),'_',num2str(Node)])}];
        end
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

    if NodeA>NodeB
            inputname  = [{join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d']);...
                          join(['NET','.vn',num2str(NodeA),'q']);join(['NET','.vn',num2str(NodeA),'d'])}];
            outputname = [{join(['NET','.iq_',num2str(NodeB),'_',num2str(NodeA)])};{join(['NET','.id_',num2str(NodeB),'_',num2str(NodeA)])}];
    else
            inputname = [{join(['NET','.vn',num2str(NodeA),'q']);join(['NET','.vn',num2str(NodeA),'d']);...
                          join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d'])}];
            outputname = [{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)])};{join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])}];
    end


    ss_rl = ss(A,B,C,D,'StateName',{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])},...
        'inputname',inputname,'outputname',outputname);
    
%     ss_rl = ss(A,B,C,D,'StateName',{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])},...
%         'inputname',{join(['NET','.vn',num2str(NodeA),'q']);join(['NET','.vn',num2str(NodeA),'d']);...
%                      join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d'])},...
%         'outputname',{join(['NET','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['NET','.id_',num2str(NodeA),'_',num2str(NodeB)])});
end

end