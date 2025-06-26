function [PI_NET] = generate_PI_NET(Connectivity_Matrix,T_nodes,T_NET,f)
%Llista entrades i sortides sistema AC lineal final:
llista_u_AC = [];
llista_y_AC = [];

%Inicialitzem comptadors:
numero_de_C = 1;
numero_de_rl = 1; 
numero_de_nus = 1; 

%Iterem per tota la matriu d'adjacència:
minimum_node = min([T_NET.NodeA;T_NET.NodeB])-1;
for i = 1 : 1 : size(Connectivity_Matrix,1)
    Cn = 0;
    [value,position] = find(Connectivity_Matrix(i,:)==1);
    for Node = [position]
         Cn = Cn + sum( [T_NET.C(T_NET.NodeA == i+minimum_node & T_NET.NodeB == Node+minimum_node ), T_NET.C(T_NET.NodeA == Node+minimum_node & T_NET.NodeB == i+minimum_node )] );
    end
                
    c_x=[ join( ['vc_q',num2str(i+minimum_node)]) ; join( ['vc_d',num2str(i+minimum_node)] )];
    c_u=[ join( ['ic_q',num2str(i+minimum_node)]); join(['ic_d',num2str(i+minimum_node)])];
    c_y=[ join(['NET.vn',num2str(i+minimum_node),'q']); join(['NET.vn',num2str(i+minimum_node),'d'])];
    llista_y_AC = [llista_y_AC ; {join(['NET.vn',num2str(i+minimum_node),'q'])}; {join(['NET.vn',num2str(i+minimum_node),'d'])}];
    %Construim l'espai d'estats del condensador.
    SS_C_i = construccio_SS_Cn( Cn , c_x , c_u , c_y, f ); 
    %Afegim el SS del C a la llista
    llista_SS_C{numero_de_C}  = SS_C_i;
    numero_de_C = numero_de_C + 1;
    
    %Creem matriu D per cada nus
    Din = [];
    
    %Creem llista per les entrades del nus
    llista_u_nus = [];
    %Creem llista per les sortides del nus
    llista_y_nus = [join( ['ic_q',num2str(i+minimum_node)]) ; join(['ic_d',num2str(i+minimum_node)])];
    
    %Iterem per cada linia
    for n_i_i = 1 : 1 : size(T_nodes,1)
        if T_nodes.Node(n_i_i) == i+minimum_node
            for n_j_j = 2:1:size(T_nodes,2)
                if not(ismissing(T_nodes{n_i_i,n_j_j}))
                    cadena_element=split(T_nodes{n_i_i,n_j_j});
                    element = cadena_element(1);
                    number = cadena_element(2);
                    if isequal(element,"SG")
                        str = split(T_nodes{n_i_i,n_j_j});
                        number =str(2);
                        %Definim entrades pel nus
                        llista_u_nus = [llista_u_nus; {join( ['SG',num2str(number),'.iq'])}  ; {join( ['SG',num2str(number),'.id'])} ];
                
                        %Definim una Din nova pel nus:
                        Din = [Din [1 0; 0 1]]; %(Positiu perquè entra al nus)
        
                        %Definim entrada global del sistema
                        llista_u_AC = [llista_u_AC ; {join( ['SG',num2str(number),'.iq'])} ; {join( ['SG',num2str(number),'.id'])}];
                    end

%                     if isequal(element,"TH")
%                         str = split(T_nodes{n_i_i,n_j_j});
%                         number =str(2);
%                         %Definim entrades pel nus
%                         llista_u_nus = [llista_u_nus; {join( ['TH',num2str(number),'.iq'])}  ; {join( ['TH',num2str(number),'.id'])} ];
%                 
%                         %Definim una Din nova pel nus:
%                         Din = [Din [1 0; 0 1]]; %(Positiu perquè entra al nus)
%         
%                         %Definim entrada global del sistema
%                         llista_u_AC = [llista_u_AC ; {join( ['TH',num2str(number),'.iq'])} ; {join( ['TH',num2str(number),'.id'])}];
%                     end

                    if isequal(element,"PQ")
                        str = split(T_nodes{n_i_i,n_j_j});
                        number =str(2);
                        %Definim entrades pel nus
                        llista_u_nus = [llista_u_nus; { join(['PQ',num2str(number),'.iq']) } ; { join(['PQ',num2str(number),'.id']) } ];
                
                        %Definim una Din nova pel nus:
                        Din = [Din [1 0; 0 1]]; %(Positiu perquè entra al nus)
        
                        %Definim entrada global del sistema
                        llista_u_AC = [llista_u_AC ; { join(['PQ',num2str(number),'.iq']) } ; { join(['PQ',num2str(number),'.id']) } ];
                    end
                    if isequal(element,"MMC")
                        %Definim entrades pel nus:
                        str = split(T_nodes{n_i_i,n_j_j});
                        number =str(2);
                        llista_u_nus = [llista_u_nus; {join(['VSC',num2str(number),'.idiffq'])} ; {join(['VSC',num2str(number),'.idiffd'])} ];
                
                        %Definim una Din nova pel nus:
                        Din = [Din [1 0; 0 1]]; %(Positiu perquè entra al nus)
        
                        %Definim entrada global del sistema
                        llista_u_AC = [llista_u_AC ; {join(['VSC',num2str(number),'.idiffq'])} ; {join(['VSC',num2str(number),'.idiffd'])}];
                    end
                    
                end

            end
                
        end
            
    end
        
    for j = 1 : 1 : size(Connectivity_Matrix,2)
            
            if Connectivity_Matrix(i,j) == 1
                           
                if j<i
                    %Creem la D per l'SS del nus:
                    Din = [Din [1 0; 0 1]]; %1 perquè entren al nus
                    llista_u_nus = [llista_u_nus ; {join( ['NET.iq_',num2str(j+minimum_node),'_',num2str(i+minimum_node)])} ; {join( ['NET.id_',num2str(j+minimum_node),'_',num2str(i+minimum_node)])}];
                elseif j>i
                    %Creem la D per l'SS del nus:
                    Din = [Din [-1 0; 0 -1]]; %-1 perquè surten del nus
                    llista_u_nus = [llista_u_nus ; {join( ['NET.iq_',num2str(i+minimum_node),'_',num2str(j+minimum_node)])} ; {join( ['NET.id_',num2str(i+minimum_node),'_',num2str(j+minimum_node)])}];
                
                    %Donem el nom de les variables de rl:
                    rl_x = [ join( ['iq',num2str(i+minimum_node),num2str(j+minimum_node)]) ; join( ['id',num2str(i+minimum_node),num2str(j+minimum_node)])];
                    rl_u = [ join(['NET.vn',num2str(i+minimum_node),'q']) ; join(['NET.vn',num2str(j+minimum_node),'q']) ; join(['NET.vn',num2str(i+minimum_node),'d']) ; join(['NET.vn',num2str(j+minimum_node),'d'])];            
                    rl_y = [ join( ['NET.iq_',num2str(i+minimum_node),'_',num2str(j+minimum_node)]) ; join( ['NET.id_',num2str(i+minimum_node),'_',num2str(j+minimum_node)])];
                
                    %Constrium matrius de l'SS de rl:
                    SS_rl = construccio_SS_rl(T_NET.R(T_NET.NodeA==i+minimum_node & T_NET.NodeB==j+minimum_node) , T_NET.L(T_NET.NodeA==i+minimum_node & T_NET.NodeB==j+minimum_node) , rl_x , rl_u, rl_y,f);
                    
                    %Matriu_dades(j,1)
                    llista_SS_rl{numero_de_rl} = SS_rl;
                    numero_de_rl = numero_de_rl + 1; 
                    
                    %Afegim entrades al sistema AC final:
                    llista_y_AC = [llista_y_AC ; {join( ['NET.iq_',num2str(i+minimum_node),'_',num2str(j+minimum_node)])} ; {join( ['NET.id_',num2str(i+minimum_node),'_',num2str(j+minimum_node)])}];
                
                else
                    continue
                end %if elseif
               
            end %end de l'if 1
            
     end %end del for
        
     %Construim matrius de l'SS del nus:
     SS_nus = construccio_SS_nus( Din , llista_u_nus , llista_y_nus );
     
     %Augmentem la llista dels nusos:
     llista_SS_nus{numero_de_nus} = SS_nus;
     numero_de_nus = numero_de_nus + 1;
    
end

%Si l'entrada és I:
PI_NET = connect( llista_SS_rl{:} , llista_SS_C{:} , llista_SS_nus{:}, llista_u_AC, llista_y_AC );


function rl = construccio_SS_rl( Rxy , Lxy , rl_x , rl_u, rl_y,f)
    w = 2*pi*f;
   %Frequència de la xarxa
    % State-space RL line
    Arl = [-Rxy/Lxy -w;
            w -Rxy/Lxy];
    Brl = [1/Lxy, -1/Lxy, 0, 0;
            0, 0, 1/Lxy, -1/Lxy];   
    Crl = [1, 0;
           0, 1];
    Drl = zeros(2,4);
    rl = ss(Arl,Brl,Crl,Drl,'StateName',rl_x,'inputname',rl_u,'outputname',rl_y);
end


function c = construccio_SS_Cn( Cn , c_x , c_u , c_y ,f)
    w = 2*pi*f;
   %Frequència de la xarxa
    % State-space C bus
    Ac = [0 -w;
          w 0];
    Bc = [1/Cn, 0;
       0, 1/Cn];
    Cc = [1, 0;
        0, 1];
    Dc = zeros(2,2);

    c = ss(Ac,Bc,Cc,Dc,'StateName',c_x,'inputname',c_u,'outputname',c_y);
end

function in = construccio_SS_nus( Din , llista_u_nus , llista_y_nus )
    % State-space sum of currents in node
    Ain = [0];
    columns_Bin = size(Din,2);
    Bin = zeros(1,columns_Bin);
    Cin = [0;0];
    
    in_x={''};
    
    in = ss(Ain,Bin,Cin,Din,'StateName',in_x,'inputname',llista_u_nus,'outputname',llista_y_nus);
end
end