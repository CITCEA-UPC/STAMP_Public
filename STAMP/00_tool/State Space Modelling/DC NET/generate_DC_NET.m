
function [DC_NET] = generate_DC_NET(DC_Connectivity_Matrix,T_DC_nodes,T_DC_NET,T_IPC)

%Incialitzem comptadors
y = size(DC_Connectivity_Matrix,1);
x = size(DC_Connectivity_Matrix,2);

f = size(T_DC_NET,1);
c = size(T_DC_nodes,2);

%Llista entrades i sortides sistema AC lineal final:
llista_u_DC = [];
llista_y_DC = [];

numero_de_C_DC = 1;
numero_de_R_DC = 1;

numero_de_rl_DC = 1;

numero_de_nus_DC= 1;
numero_de_nus_RC_DC = 1;

%Iterem per tota la matriu d'adjacència:
for i = 1 : 1 : size(DC_Connectivity_Matrix,1)
    Cn = 0;
    Gn = 0;
    [value,position] = find(DC_Connectivity_Matrix(i,:)==1);
    for Node = position
        C1 = T_DC_NET.C(T_DC_NET.bus_from == i & T_DC_NET.bus_to == Node )/2;
        C2 = T_DC_NET.C(T_DC_NET.bus_from == Node & T_DC_NET.bus_to == i )/2;
        if isempty(C1)
           C1 = T_DC_NET.C(T_DC_NET.bus_from == Node & T_DC_NET.bus_to == i )/2;
        end
        if isempty(C2)
           C2 = T_DC_NET.C(T_DC_NET.bus_from == i & T_DC_NET.bus_to == Node )/2;
        end
        Cn = Cn + sum( [C1,C2] );
           %Agafem les dades del condensador i de la resistència del node:
            % if Node>i
            %     Cn = Cn + T_DC_NET.C(T_DC_NET.bus_to==position);
            %     Gn = Gn + T_DC_NET.G(T_DC_NET.bus_to==position);
            % else
            %     Cn = Cn + T_DC_NET.C(T_DC_NET.bus_from==position);
            %     Gn = Gn + T_DC_NET.G(T_DC_NET.bus_from==position);
            % end
%         Cn = Cn + sum( [T_DC_NET.C(T_DC_NET.bus_from == i & T_DC_NET.bus_to == Node )/2, T_DC_NET.C(T_DC_NET.bus_from == Node & T_DC_NET.bus_to == i )]/2 );
%         Gn = Gn + sum( [T_DC_NET.G(T_DC_NET.bus_from == i & T_DC_NET.bus_to == Node )/2, T_DC_NET.G(T_DC_NET.bus_from == Node & T_DC_NET.bus_to == i )]/2 );
    end
    %Entrades, sortides i estat pel bloc C:
    c_x=[ join( ['vc_DC',num2str(i)])];
    c_u=[ join( ['ic_DC',num2str(i)])];
    c_y=[ join(['DC_NET.v',num2str(i),'DC'])];
    
    %Entrades i sortides pel bloc R:
    r_u=[ join(['DC_NET.v',num2str(i),'DC'])];
    r_y = [ join( ['ir_DC',num2str(i)])];
    
    %Afegim sortides al sistema final
    llista_y_DC = [llista_y_DC ; {join(['DC_NET.v',num2str(i),'DC'])}];
    
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
    
    %for n_i_i = 1 : 1 : size(T_DC_nodes,1)
         if isequal(T_DC_nodes.Element_1{i},'IPC')
                llista_u_nus_DC = [llista_u_nus_DC; { join( ['IPC',num2str(T_IPC.number(T_IPC.busdc == i)),'.iDC'] ) }];
                Din = [Din [1]]; %(Positiu perquè entra al nus) 
                llista_u_DC = [llista_u_DC ; { join( ['IPC',num2str(T_IPC.number(T_IPC.busdc == i)),'.iDC'] ) }];
         end
    %end
        
        for j = 1 : 1 : x
            
            if DC_Connectivity_Matrix(i,j) == 1 %if 1
                           
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
                    rl_u_a = [ join(['DC_NET.v',num2str(i),'DC']) ; join(['DC_NET.v',num2str(j),'DC'])];            
                    rl_y_a = [ join( ['ia_rl_DC',num2str(i),num2str(j)])];
                    
                    %Donem el nom de les variables de rl b:
                    rl_x_b = [ join( ['ibDC_',num2str(i),num2str(j)])];
                    rl_u_b = [ join(['DC_NET.v',num2str(i),'DC']) ; join(['DC_NET.v',num2str(j),'DC'])];            
                    rl_y_b = [ join( ['ib_rl_DC',num2str(i),num2str(j)])];

                    %Donem el nom de les variables de rl c:
                    rl_x_c = [ join( ['icDC_',num2str(i),num2str(j)])];
                    rl_u_c = [ join(['DC_NET.v',num2str(i),'DC']) ; join(['DC_NET.v',num2str(j),'DC'])];            
                    rl_y_c = [ join( ['ic_rl_DC',num2str(i),num2str(j)])];
                
                    %Constrium matrius de l'SS de rl:
                    for ii=1:1:f
                        if T_DC_NET.bus_from(ii)==i && T_DC_NET.bus_to(ii)==j
                                
                                %R i L part a
                                rxy_a = T_DC_NET.Ra(ii);
                                lxy_a = T_DC_NET.La(ii);
                                
                                %R i L part b
                                rxy_b = T_DC_NET.Rb(ii);
                                lxy_b = T_DC_NET.Lb(ii);
                                
                                %R i L part c
                                rxy_c = T_DC_NET.Rc(ii);
                                lxy_c = T_DC_NET.Lc(ii);
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


DC_NET = connect( llista_SS_rl_DC{:} , llista_SS_C_DC{:}, llista_SS_R_DC{:} , llista_SS_nus_DC{:}, llista_SS_nus_RC{:}, llista_u_DC, llista_y_DC );

function rl = construccio_SS_rl( Rxy , Lxy , rl_x , rl_u, rl_y)
    Arl = [-Rxy/Lxy];
    Brl = [1/Lxy, -1/Lxy];   
    Crl = [1];
    Drl = [0 0];
    rl = ss(Arl,Brl,Crl,Drl,'StateName',rl_x,'inputname',rl_u,'outputname',rl_y);
end

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
    Rn = 0; % Because it is not considered in the power flow!! and in the non-linear model!
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
end