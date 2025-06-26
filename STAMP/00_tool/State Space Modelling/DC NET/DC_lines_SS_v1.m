%% Funció get_AC_system_SS
format long
%Llegim l'arxiu de text lines
txt_file_lines_DC = 'lines_gogs_DC_km.txt';
%Llegim arxiu dels nodes
txt_file_nodes_DC = 'nodes_gogs_DC_km.txt';

%Calculem les Rxy i les Lxy:
escriu_data(txt_file_lines_DC);

%Llegim les dades dels fitxers
[Madj_DC, Matriu_dades_DC, Matriu_dades_complet_DC] = read_data('linesDC_km_complet.txt');

%Calculem i escrivim les Ci:
escriu_data_C(txt_file_nodes_DC , Madj_DC , Matriu_dades_complet_DC);

%Creem les variables pel simulink:
[C, G, R, L] = genera_variables_pel_simulink('linesDC_km_complet.txt', 'nodesDC_complet.txt');

Matriu_node_DC = read_data_node('nodesDC_complet.txt');

%Calculem els parametres de la linia
%gorgs_param_km

%Dibuixem el sistema
Graph = crea_graph(Madj_DC);
%colors(Graph,Matriu_node_DC)

%Incialitzem comptadors
y = size(Madj_DC,1);
x = size(Madj_DC,2);

f = size(Matriu_dades_DC,1);
c = size(Matriu_dades_DC,2);

%No cal si ho fem amb I
%Definim resistència i inductància que conneten la carrega al node i
%r_PQ = Rc_n1; 
%l_PQ = Lc_n1;

%prompt_N = 'Insert number of nodes: ';
%N = input(prompt_N);

%Llista entrades i sortides sistema AC lineal final:
llista_u_DC = [];
llista_y_DC = [];


numero_de_C_DC = 1;
numero_de_R_DC = 1;

numero_de_rl_DC = 1;

numero_de_nus_DC= 1;
numero_de_nus_RC_DC = 1;

fclose('all');
%fclose('linesDC_km_complet.txt');
%fclose('linesDC_km_complet.txt');
%fclose('lines_gogs_DC_km.txt');
%fclose('nodes_gogs_DC_km.txt');

%Iterem per tota la matriu d'adjacència:
for i = 1 : 1 : y
    %Agafem les dades del condensador i de la resistència del node:
    for n_i = 1 : 1 : size(Matriu_node_DC,1)
        if Matriu_node_DC(n_i,1)==i
            Cn = Matriu_node_DC(n_i,2);
            Gn = Matriu_node_DC(n_i,3);
        end
    end
    
    %Entrades, sortides i estat pel bloc C:
    c_x=[ join( ['vc_DC',num2str(i)])];
    c_u=[ join( ['ic_DC',num2str(i)])];
    c_y=[ join(['v',num2str(i),'_DC'])];
    
    %Entrades i sortides pel bloc R:
    r_u=[ join(['v',num2str(i),'_DC'])];
    r_y = [ join( ['ir_DC',num2str(i)])];
    
    %Afegim sortides al sistema final
    llista_y_DC = [llista_y_DC ; {join(['v',num2str(i),'_DC'])}];
    
    %Construim l'espai d'estats del condensador.
    SS_C_i = construccio_SS_Cn( Cn , c_x , c_u , c_y ); 
    
    %Construim l'espai d'estats de la resistència.
    SS_R_i = construccio_SS_Rn( Gn , r_u , r_y ); 
    
    %llista_SS_C = [llista_SS_C SS_C_i];
    llista_SS_C_DC{numero_de_C_DC}  = SS_C_i;
    numero_de_C_DC = numero_de_C_DC + 1;
    
    %llista_SS_R:
    llista_SS_R_DC{numero_de_R_DC} = SS_R_i;
    numero_de_R_DC = numero_de_R_DC + 1;
    %Creem matriu D per cada nus de C
    Din = [];
    
    %Creem llista per les entrades del nus node
    llista_u_nus_DC = [];
    %Creem llista per les sortides del nus node
    llista_y_nus_DC = [join( ['irc_DC',num2str(i)])];
    
    %Creem llista per les entrades i les sortides del nus RC
    llista_u_nus_RC = [ join( ['irc_DC',num2str(i)]); {join( ['ir_DC',num2str(i)])}];
    llista_y_nus_RC = [ join( ['ic_DC',num2str(i)])];
    
    for n_i_i = 1 : 1 : size(Matriu_node_DC,1)
        if Matriu_node_DC(n_i_i,1) == i && Matriu_node_DC(n_i_i,4)==1
                %Matriu_node(n_i_i,3)
                llista_u_nus_DC = [llista_u_nus_DC; { join( ['iDC_MMCn',num2str(Matriu_node_DC(n_i_i,1))] ) }];
                %OJOOOOO PROVO NEGATIU
                %%%%%
                %%%%%
                %%%%%
                Din = [Din [1]]; %(Positiu perquè entra al nus) 
                llista_u_DC = [llista_u_DC ; {join( ['iDC_MMCn',num2str(Matriu_node_DC(n_i_i,1))] )}];
        end
    end
        
        for j = 1 : 1 : x
            
            if Madj_DC(i,j) == 1 %if 1
                           
                if j<i
                    %Creem la D per l'SS del nus de C:
                    Din = [Din [1 1 1]];
                    %Afegim entrades al nus de C
                    llista_u_nus_DC = [llista_u_nus_DC ; join( ['ia_rl_DC',num2str(j),num2str(i)]) ; join( ['ib_rl_DC',num2str(j),num2str(i)]) ; join( ['ic_rl_DC',num2str(j),num2str(i)])];
                elseif j>i
                    %Creem la D per l'SS del nus de C:
                    Din = [Din [-1 -1 -1]];
                    llista_u_nus_DC = [llista_u_nus_DC ; join( ['ia_rl_DC',num2str(i),num2str(j)]) ; join( ['ib_rl_DC',num2str(i),num2str(j)]); join( ['ic_rl_DC',num2str(i),num2str(j)])];

                    %Donem el nom de les variables de rl a:
                    rl_x_a = [ join( ['iaDC_',num2str(i),num2str(j)])];
                    rl_u_a = [ join(['v',num2str(i),'_DC']) ; join(['v',num2str(j),'_DC'])];            
                    rl_y_a = [ join( ['ia_rl_DC',num2str(i),num2str(j)])];
                    
                    %Donem el nom de les variables de rl b:
                    rl_x_b = [ join( ['ibDC_',num2str(i),num2str(j)])];
                    rl_u_b = [ join(['v',num2str(i),'_DC']) ; join(['v',num2str(j),'_DC'])];            
                    rl_y_b = [ join( ['ib_rl_DC',num2str(i),num2str(j)])];

                    %Donem el nom de les variables de rl c:
                    rl_x_c = [ join( ['icDC_',num2str(i),num2str(j)])];
                    rl_u_c = [ join(['v',num2str(i),'_DC']) ; join(['v',num2str(j),'_DC'])];            
                    rl_y_c = [ join( ['ic_rl_DC',num2str(i),num2str(j)])];
                
                    %Constrium matrius de l'SS de rl:
                    for ii=1:1:f
                        if Matriu_dades_DC(ii,1)==i && Matriu_dades_DC(ii,2)==j
                                
                                %R i L part a
                                rxy_a = Matriu_dades_DC(ii,3);
                                lxy_a = Matriu_dades_DC(ii,6);
                                
                                %R i L part b
                                rxy_b = Matriu_dades_DC(ii,4);
                                lxy_b = Matriu_dades_DC(ii,7);
                                
                                %R i L part c
                                rxy_c = Matriu_dades_DC(ii,5);
                                lxy_c = Matriu_dades_DC(ii,8);
                        end
                    end
                    %Construim part a
                    SS_rl = construccio_SS_rl(rxy_a , lxy_a , rl_x_a , rl_u_a, rl_y_a);
                    llista_SS_rl_DC{numero_de_rl_DC} = SS_rl;
                    numero_de_rl_DC = numero_de_rl_DC + 1;
                    %Construim part b
                    SS_rl = construccio_SS_rl(rxy_b , lxy_b, rl_x_b , rl_u_b, rl_y_b);
                    llista_SS_rl_DC{numero_de_rl_DC} = SS_rl;
                    numero_de_rl_DC = numero_de_rl_DC + 1;
                    %Construim part c
                    SS_rl = construccio_SS_rl(rxy_c , lxy_c , rl_x_c , rl_u_c, rl_y_c);
                    llista_SS_rl_DC{numero_de_rl_DC} = SS_rl;
                    numero_de_rl_DC = numero_de_rl_DC + 1; 
                    
                    %Afegim entrades al sistema AC final:
                    %llista_u_AC = [llista_u_AC ; {join(['v',num2str(i),'_q'])} ; {join(['v',num2str(j),'_q'])} ; {join(['v',num2str(i),'_d'])}; {join(['v',num2str(j),'_d'])}]
                    %llista_y_DC = [llista_y_DC ; {join( ['ia_rl_DC',num2str(i),num2str(j)])} ; {join( ['ib_rl_DC',num2str(i),num2str(j)])} ;  {join( ['ic_rl_DC',num2str(i),num2str(j)])} ];
                    
                else
                    continue
                end %if elseif
               
            end %end de l'if 1
            
        end %end del for
        
     %Construim matrius de l'SS del nus:
     SS_nus = construccio_SS_nus( Din , llista_u_nus_DC , llista_y_nus_DC );
     %Augmentem la llista dels nusos:
     llista_SS_nus_DC{numero_de_nus_DC} = SS_nus;
     numero_de_nus_DC = numero_de_nus_DC + 1;
     
     %Construim matriu de l'SS del nus de RC:
     SS_nus_RC = construccio_SS_nus_RC({llista_u_nus_RC{:}}, llista_y_nus_RC);
     llista_SS_nus_RC{numero_de_nus_RC_DC} = SS_nus_RC;
     numero_de_nus_RC_DC = numero_de_nus_RC_DC + 1;
end


%Si l'entrada és V:
%SS_AC_system = connect( llista_SS_rl{:} , llista_SS_C{:} , llista_SS_nus{:} , llista_SS_PQ{:}, llista_u_AC, llista_y_AC )

%Si l'entrada és I:
SS_DC_system = connect( llista_SS_rl_DC{:} , llista_SS_C_DC{:}, llista_SS_R_DC{:} , llista_SS_nus_DC{:}, llista_SS_nus_RC{:}, llista_u_DC, llista_y_DC );

function rl = construccio_SS_rl( Rxy , Lxy , rl_x , rl_u, rl_y)
    
   %Frequència de la xarxa
    % State-space RL line
    Arl = [-Rxy/Lxy];
    Brl = [1/Lxy, -1/Lxy];   
    Crl = [1];
    Drl = [0 0];
    rl = ss(Arl,Brl,Crl,Drl,'StateName',rl_x,'inputname',rl_u,'outputname',rl_y);
end

%Aquesta funció no cal si fem entrada current:
% function rl_PQ = construccio_SS_rl_convertidor( Rxy , Lxy , rl_x , rl_u, rl_y)
%     
%    %Frequència de la xarxa
%     w = 2*pi*50;
%     % State-space RL line
%     Arl_PQ = [-Rxy/Lxy -w;
%             w -Rxy/Lxy];
%     Brl_PQ = [1/Lxy, 0, -1/Lxy , 0;
%             0, 1/Lxy, 0, -1/Lxy];   
%     Crl_PQ = [1, 0;
%            0, 1];
%     Drl_PQ = zeros(2,4);
%     rl_PQ = ss(Arl_PQ,Brl_PQ,Crl_PQ,Drl_PQ,'StateName',rl_x,'inputname',rl_u,'outputname',rl_y);
% end

function c = construccio_SS_Cn( Cn , c_x , c_u , c_y )
   %Frequència de la xarxa
    Ac = [0];
    Bc = [1/Cn];
    Cc = [1];
    Dc = [0];

    c = ss(Ac,Bc,Cc,Dc,'StateName',c_x,'inputname',c_u,'outputname',c_y);
end

function r_n = construccio_SS_Rn( Rn , r_u , r_y )
    Ain = [0];
    Din = [Rn];
    Cin = [0];
    columns_Bin = size(Din,2);
    Bin = zeros(1,columns_Bin);
    
    in_x={''};
    
    r_n = ss(Ain,Bin,Cin,Din,'StateName',in_x,'inputname',r_u,'outputname',r_y);
end

function in = construccio_SS_nus( Din , llista_u_nus , llista_y_nus )
    % State-space sum of currents in node
    Ain = [0];
    columns_Bin = size(Din,2);
    Bin = zeros(1,columns_Bin);
    Cin = [0];
    
    in_x={''};
    
    in = ss(Ain,Bin,Cin,Din,'StateName',in_x,'inputname',llista_u_nus,'outputname',llista_y_nus);
end

function in = construccio_SS_nus_RC( llista_u_nus , llista_y_nus )
    % State-space sum of currents in node
    Ain = [0];
    Din = [1 -1];
    columns_Bin = size(Din,2);
    Bin = zeros(1,columns_Bin);
    Cin = [0];
    
    in_x={''};
    
    in = ss(Ain,Bin,Cin,Din,'StateName',in_x,'inputname',llista_u_nus,'outputname',llista_y_nus);
end

function [Madj, Matriu_dades, Matriu_dades_complet] = read_data(txt_file_lines)
    [n_inicial, n_final, distancia, llista_rxy_a, llista_rxy_b,llista_rxy_c, llista_lxy_a, llista_lxy_b,llista_lxy_c] = textread(txt_file_lines,'%u %u %f %f %f %f %f %f %f');
    
    Matriu_dades_complet = [n_inicial, n_final, distancia, llista_rxy_a, llista_rxy_b, llista_rxy_c, llista_lxy_a, llista_lxy_b, llista_lxy_c];
    Matriu_nodes = [n_inicial n_final];
    r = size(Matriu_nodes,1);
    
    Matriu_dades = [n_inicial n_final llista_rxy_a llista_rxy_b llista_rxy_c llista_lxy_a llista_lxy_b llista_lxy_c];
    dim = max(max(Matriu_nodes));
    Madj = zeros(dim);
    for i=1:1:r
        Madj(Matriu_nodes(i,1),Matriu_nodes(i,2))=1;
    end
    Madj = Madj + Madj';
end

function Matriu_node = read_data_node(txt_file_nodes)
    [n_node, node_type, C_i , R_i] = textread(txt_file_nodes,'%u %u %f %f');
    
    Matriu_node = [n_node C_i  R_i node_type];
end

function Graph = crea_graph(Madj)
    %figure
    primer_cas = 0;
    for i=1:1:size(Madj,1)
        for j=1:1:size(Madj,2)
            if i == 1 && Madj(i,j)==1 && primer_cas == 0
                Graph = graph(i,j);
                primer_cas = primer_cas + 1;
            elseif j>i && Madj(i,j)==1
                Graph = addedge(Graph,i,j);
            end
        end
    end
end

function Graph_nodes_PQ = colors(Graph,Matriu_node)
    H = plot(Graph);
    for n = 1:1:size(Matriu_node,1)
         if Matriu_node(n,4) == 1
             highlight(H,n,'NodeColor','r');
             labelnode(H,n,join(['VSC Converter ','Node',num2str(n)]));
             %labelnode(H,n,'VSC Convereter')
             %labelnode(H,n,num2str(n))
         end
   end
end

function escriu_data(txt_file_lines)
    % Submarine DC lines (Julian)
    Rz1base=0.126485647879109;    % ohm/km
    Rz2base=0.150386436675472;    % ohm/km
    Rz3base=0.017738188835732;    % ohm/km
    Lz1base=0.000264365949627;    % H/km
    Lz2base=0.007286487663814;    % H/km
    Lz3base=0.003619879392824;    % H/km
    
    [n_inicial, n_final, distancia] = textread(txt_file_lines,'%u %u %f');
    
    %Obrim el fitxer on volem escriure les dades:
    fitxer_complet = fopen('linesDC_km_complet.txt','wt');
    
    for i = 1:1:size(n_inicial,1)
        %el fitxer final queda com
        %n_inicial n_final distancia Ra Rb Rc La Lb Lc
        fprintf(fitxer_complet,'%u %u %f %f %f %f %f %f %f \n' , [n_inicial(i) n_final(i) distancia(i) 2*Rz1base*distancia(i) 2*Rz2base*distancia(i) 2*Rz3base*distancia(i) 2*Lz1base*distancia(i) 2*Lz2base*distancia(i) 2*Lz3base*distancia(i)]);
    end
    
end

function escriu_data_C(txt_file_nodes_i, Madj ,Matriu_dades)
    %Paràmetre base:
    Gybase=1.01512e-10;           % S/km
    Cybase=0.161561e-6;           % F/km
    
    [numero_nodes, tipus_node] = textread(txt_file_nodes_i,'%u %u');
    fitxer_complet = fopen('nodesDC_complet.txt','wt');
    
    %Recorrem la matriu d'adjacència:
    for i=1:1:size(Madj,1)
        C_i = 0;
        G_i = 0;
        for j=1:1:size(Madj,2)
            if Madj(i,j)==1
                %Ara recorrem la matriu de dades per trobar la distancia
                %d'aquesta linia:
                for f = 1:1:size(Matriu_dades,1)
                    if (Matriu_dades(f,1) == i && Matriu_dades(f,2) == j) || (Matriu_dades(f,1) == j && Matriu_dades(f,2) == i)
                        distancia = Matriu_dades(f,3);
                        C_i = C_i + Cybase*distancia/2/2;
                        G_i = G_i + Gybase*distancia/2/2;
                    end
                end
            end
        end
        fprintf(fitxer_complet,'%u %u %.16f %.16f \n' , [numero_nodes(i) tipus_node(i) C_i G_i]);
    end
    
end

function [C, G , R, L] = genera_variables_pel_simulink(txt_lines, txt_nodes)
     [node, tipus, C_i ,G_i] = textread(txt_nodes,'%u %u %f %f');
     total_nodes = size(node,1);
     primer = true;
     for i=1:1:total_nodes
         if primer == true
            C = struct(join(['dc',num2str(i)]),C_i(i));
            G = struct(join(['dc',num2str(i)]),G_i(i));
            primer = false;
         else
            %C = setfield(C,join(['ac',num2str(i)]),C_i(i));
            C.(join(['dc',num2str(i)]))= C_i(i);
            G.(join(['dc',num2str(i)]))= G_i(i);
         end
     end
     
     [node_i, node_f, distancia, llista_Rxy_a, llista_Rxy_b,llista_Rxy_c, llista_Lxy_a, llista_Lxy_b, llista_Lxy_c] = textread(txt_lines,'%u %u %f %f %f %f %f %f %f');

     %size(node_i,1)
     primer = true;
     for i= 1:1:size(node_i,1)
         if primer == true
            %a
            R = struct(join(['z1_',num2str(node_i(i)),num2str(node_f(i))]),llista_Rxy_a(i));
            L = struct(join(['z1_',num2str(node_i(i)),num2str(node_f(i))]),llista_Lxy_a(i));
            %b
            R.(join(['z2_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Rxy_b(i);
            L.(join(['z2_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Lxy_b(i);
            %c
            R.(join(['z3_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Rxy_c(i);
            L.(join(['z3_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Lxy_c(i);
            primer = false;
         else
            %a
            R.(join(['z1_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Rxy_a(i);
            L.(join(['z1_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Lxy_a(i);
            %b
            R.(join(['z2_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Rxy_b(i);
            L.(join(['z2_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Lxy_b(i);
            %c
            R.(join(['z3_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Rxy_c(i);
            L.(join(['z3_',num2str(node_i(i)),num2str(node_f(i))])) = llista_Lxy_c(i);
         end
     end
end
