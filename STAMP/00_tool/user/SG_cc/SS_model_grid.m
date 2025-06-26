% %Parameters
% run posytyf_param
clear SS_blocks
% Branch currents (Transformers and lines)
%%data.branch = [data.trafo, zeros(length(data.trafo),1);data.line];
%%[Nbranch, aux] = size(data.branch);
%%[Ntr, aux] = size(data.trafo); 
% clear aux;

Nbranch = height(results.branch); % Number of branches
n_slk = find(results.bus(:,2)==3); % Slack bus number
% SS_blocks = [];

for ii = 1:Nbranch
    bx = results.branch(ii,1); %from bus
    by = results.branch(ii,2); %to bus
%     if ii<=Ntr
%         state_name = {['itrq_',num2str(bx),'_',num2str(by)],['itrd_',num2str(bx),'_',num2str(by)]};
%         SS_name = 'I_trafo_';
%     else
    state_name = {['iLq_',num2str(bx),'_',num2str(by)],['iLd_',num2str(bx),'_',num2str(by)]};
    SS_name = 'I_line_';
%     end
    input_name = {['vb',num2str(bx),'q'],['vb',num2str(bx),'d'],['vb',num2str(by),'q'],['vb',num2str(by),'d'],['SG',num2str(n_slk),'_w']};
    output_name = state_name;
    
    Rxy = results.branch(ii,3)*Zb;
    Lxy = results.branch(ii,4)*Zb/wn;
    iq0 = ibranch_q0(ii);
    id0 = ibranch_d0(ii);
    
    % State-space RL line
    Arl = [-Rxy/Lxy -wn;
            wn -Rxy/Lxy];
    Brl = [1/Lxy, 0, -1/Lxy 0 -id0;
            0, 1/Lxy, 0 , -1/Lxy, iq0];   
    Crl = [1, 0;
           0, 1];
    Drl = zeros(2,5);
    eval([SS_name,num2str(bx),'_',num2str(by),' = ss(Arl,Brl,Crl,Drl,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
    eval('SS_blocks{ii} = eval([SS_name,num2str(bx),''_'',num2str(by)]);');
end

%%
% Bus voltages
Nblock = length(SS_blocks);
ncap = results.branch(:,[1,2]);
index_cap = find(results.branch(:,5)~=0);
index_cap = unique(results.branch(index_cap,[1,2]));
jj = 1;
for ii = index_cap'
    [xcap, aux] = find(ncap==ii);
    Cbus = sum(results.branch(xcap,5))/Zb/wn/2;

    state_name = {['vb',num2str(ii),'q'],['vb',num2str(ii),'d']};
    input_name = {['ib',num2str(ii),'q'],['ib',num2str(ii),'d']}; %'SG1_w'
    output_name = state_name;
    Ac = [0 -wn;
          wn 0];
    Bc = [1/Cbus, 0;%, -vb_d0(ii);
          0, 1/Cbus];% vb_q0(ii)];
    Cc = [1, 0;
        0, 1];
    Dc = zeros(2,2);

    eval(['V_bus_',num2str(ii),' = ss(Ac,Bc,Cc,Dc,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
    eval('SS_blocks{Nblock+jj} = eval([''V_bus_'',num2str(ii)]);');
    jj = jj+1;
end

%% Load currents
Nblock = length(SS_blocks);
%[Nload,aux] = size(data.load);
jj = 1;
for ii = 1:length(n_ld)
    nbus = n_ld(ii);
    
    if nbus~=12 && nbus~=20
        state_name = {['idL',num2str(nbus),'q'],['idL',num2str(nbus),'d']};
        input_name = {['vb',num2str(nbus),'q'],['vb',num2str(nbus),'d'],['Rd',num2str(nbus)],['SG',num2str(n_slk),'_w']};
        output_name = {['id',num2str(nbus),'q'],['id',num2str(nbus),'d']};

        Rload = Vn^2/(results.bus(nbus,3)*1e6); 
        Lload = Vn^2/(results.bus(nbus,4)*1e6)/wn;
        vq0 = vb_q0(nbus);
        vd0 = vb_d0(nbus);

        % State-space RL load
        Aload = [0 -wn;
                wn 0];
        Bload = [1/Lload, 0, 0, -idL_d0(ii);
                0, 1/Lload, 0, idL_q0(ii)];   
        Cload = [1, 0;
               0, 1];
        Dload = [1/Rload, 0 -vq0/Rload^2 0;
                 0  1/Rload -vd0/Rload^2 0];
        eval(['I_load_',num2str(nbus),' = ss(Aload,Bload,Cload,Dload,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
        eval('SS_blocks{Nblock+jj} = eval([''I_load_'',num2str(nbus)]);');
        jj = jj+1;
    else
        state_name = {['idL',num2str(nbus),'q'],['idL',num2str(nbus),'d']};
        input_name = {['vb',num2str(nbus),'q'],['vb',num2str(nbus),'d'],['Rd',num2str(nbus)],['SG',num2str(n_slk),'_w']};
        output_name = {['id',num2str(nbus),'q'],['id',num2str(nbus),'d']};

        Rload = Vn^2/(results.bus(nbus,3)*1e6); 
        Lload = Vn^2/(results.bus(nbus,4)*1e6)/wn;
        vq0 = vb_q0(nbus);
        vd0 = vb_d0(nbus);

        % State-space L load
        Aload = [0 -wn;
                wn 0];
        Bload = [1/Lload, 0, 0, -idL_d0(ii);
                0, 1/Lload, 0, idL_q0(ii)];   
        Cload = [1, 0;
               0, 1];
        Dload = [0, 0 0 0;
                 0  0 0 0];
        eval(['I_load_',num2str(nbus),' = ss(Aload,Bload,Cload,Dload,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
        eval('SS_blocks{Nblock+jj} = eval([''I_load_'',num2str(nbus)]);');
        jj = jj+1;
        % State-space R load   
       %input_name = {['isg',num2str(ng(ii)),'q'],['isg',num2str(ng(ii)),'d'],['iLq_',num2str(nline(xline,1)),'_',num2str(nline(xline,2))],['iLd_',num2str(nline(xline,1)),'_',num2str(nline(xline,2))]};     
       state_name = {};
       input_name = {['ib',num2str(nbus),'q'],['ib',num2str(nbus),'d']};     
       output_name = {['vb',num2str(nbus),'q'],['vb',num2str(nbus),'d']};
        
        ARload = [0];
        BRload = zeros(1,2);   
        CRload = [0;0];
        DRload = [Rload, 0 ;
                 0  Rload];     
             
        eval(['I_Rload_',num2str(nbus),' = ss(ARload,BRload,CRload,DRload,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
        eval('SS_blocks{Nblock+jj} = eval([''I_Rload_'',num2str(nbus)]);');
        jj = jj+1;
%     SS_blocks(Nblock+ii) = {['I_load_',num2str(nbus)]};
    end
end

%% Sum of currents in buses
Nblock = length(SS_blocks);
Nbus = length(results.bus(:,1));
ng = results.gen(:,1);%data.SG(:,1);
nc = 0;%data.VSC(:,1);
% ntr = data.trafo(:,[1,2]);
nline = results.branch(:,[1,2]);
nd = n_ld';
jj = 1;
for ii = 1:Nbus
    xg = find(ii==ng);
    xc = find(ii==nc);
    %[xtr,dir_tr] = find(ii==ntr);
    [xline,dir_line] = find(ii==nline);
    xd = find(ii==nd);
    
    Xcur = sum([length(xg),length(xc),length(xline),length(xd)]);
    
    Acur = [0];
    Bcur = zeros(1,2*Xcur);
    Ccur = [0;0];
    Dcur = zeros(2,2*Xcur);
    
    input_name_line = {};
    
    if isempty(xg)~=1
        for ii_g = 1:length(xg)
            Dcur(1,1+(ii_g-1)*2) = 1;
            Dcur(2,ii_g*2) = 1;
            input_name_g = {['isg',num2str(ii),'q'],['isg',num2str(ii),'d']};
        end
    else
        ii_g = 0;
        input_name_g = {};
    end
    
    if isempty(xc)~=1
        for ii_c = 1:length(xc)
            Dcur(1,1+(ii_c-1)*2) = 1;
            Dcur(2,ii_c*2) = 1;
            input_name_c = {['ivsc',num2str(ii),'q'],['ivsc',num2str(ii),'d']};
        end
    else
        ii_c = 0;
        input_name_c = {};
    end
    
%     if isempty(xtr)~=1
%         for ii_tr = 1:length(xtr)
%             if dir_tr == 1
%                 Dcur(1,2*ii_g+2*ii_c+1+(ii_tr-1)*2) = -1;
%                 Dcur(2,2*ii_g+2*ii_c+ii_tr*2) = -1;
%             else
%                 Dcur(1,2*ii_g+2*ii_c+1+(ii_tr-1)*2) = 1;
%                 Dcur(2,2*ii_g+2*ii_c+ii_tr*2) = 1;
%             end 
%             input_name_tr = {['itrq_',num2str(ntr(xtr,1)),'_',num2str(ntr(xtr,2))],['itrd_',num2str(ntr(xtr,1)),'_',num2str(ntr(xtr,2))]};
%         end
%     else
%         ii_tr = 0;
%         input_name_tr = {};
%     end
    if isempty(xline)~=1
        for ii_line = 1:length(xline)
            if dir_line(ii_line) == 1
                Dcur(1,2*ii_g+2*ii_c+1+(ii_line-1)*2) = -1;
                Dcur(2,2*ii_g+2*ii_c+ii_line*2) = -1;
            else
                Dcur(1,2*ii_g+2*ii_c+1+(ii_line-1)*2) = 1;
                Dcur(2,2*ii_g+2*ii_c+ii_line*2) = 1;
            end 
            input_name_line(1,1+(ii_line-1)*2:2*ii_line) = {['iLq_',num2str(nline(xline(ii_line),1)),'_',num2str(nline(xline(ii_line),2))],['iLd_',num2str(nline(xline(ii_line),1)),'_',num2str(nline(xline(ii_line),2))]};
        end
    else
        ii_line = 0;
        input_name_line = {};
    end
    
    if isempty(xd)~=1
        for ii_d = 1:length(xd)
            Dcur(1,2*ii_g+2*ii_c+2*ii_line+1+(ii_d-1)*2) = -1;
            Dcur(2,2*ii_g+2*ii_c+ii_line*2+ii_d*2) = -1;
            input_name_load(1,1+(ii_d-1)*2:2*ii_d) = {['id',num2str(ii),'q'],['id',num2str(ii),'d']};
        end
    else
        ii_d = 0;
        input_name_load = {};
    end
    
    state_name = {};
    output_name = {['ib',num2str(ii),'q'],['ib',num2str(ii),'d']};
    input_name = [input_name_g,input_name_c,input_name_line,input_name_load];
    eval(['I_bus_',num2str(ii),' = ss(Acur,Bcur,Ccur,Dcur,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
    eval('SS_blocks{Nblock+jj} = eval([''I_bus_'',num2str(ii)]);');
%     SS_blocks(Nblock+jj) = {['I_bus_',num2str(ii)]};
    jj = jj + 1;
end

%% Input SG currents and snubber
Nblock = length(SS_blocks);
%ng = data.SG(:,1);
%ntr = data.trafo(:,[1,2]);
Ssnb = [1 1 1 1 1 1 1 1 1 0];
jj = 1;
for ii = 1:length(ng)
    Rsnb = Vn^2/(data.SG(ii,2)*1e6*0.01)*Ssnb(ii);
    
    if Rsnb~=0
        Asnb = [0];
        %Bsnb = zeros(1,4);
        Bsnb = zeros(1,2);
        Csnb = [0;0];
        %Dsnb = [Rsnb 0 -Rsnb 0;
         %       0 Rsnb 0 -Rsnb];
        Dsnb = [Rsnb 0;
                0 Rsnb];
        
       [xline,aux] = find(nline==ng(ii));     

       %input_name = {['isg',num2str(ng(ii)),'q'],['isg',num2str(ng(ii)),'d'],['iLq_',num2str(nline(xline,1)),'_',num2str(nline(xline,2))],['iLd_',num2str(nline(xline,1)),'_',num2str(nline(xline,2))]};     
       input_name = {['ib',num2str(ng(ii)),'q'],['ib',num2str(ng(ii)),'d']};     
       output_name = {['vb',num2str(ng(ii)),'q'],['vb',num2str(ng(ii)),'d']};
       state_name = {};
       eval(['I_snb_SG_',num2str(ng(ii)),' = ss(Asnb,Bsnb,Csnb,Dsnb,''StateName'',state_name,''inputname'',input_name,''outputname'',output_name);']);
       eval('SS_blocks{Nblock+jj} = eval([''I_snb_SG_'',num2str(ng(ii))]);');
    %    SS_blocks(Nblock+ii) = {['I_snb_',num2str(ng(ii))]};
    jj = jj + 1;
    end
   
end

%% Connect all system
% grid_inputs = {'isg1q','isg1d','isg2q','isg2d','vb3q','vb3d','vb4q','vb4d','vb5q','vb5d','vb6q','vb6d','Rd9','Rd10','Rd11','Rd12','Rd13','SG1_w'};
% grid_inputs = {'vb1q','vb1d','isg2q','isg2d','vb3q','vb3d','vb4q','vb4d','vb5q','vb5d','vb6q','vb6d','Rd9','Rd10','Rd11','Rd12','Rd13','SG1_w'};
grid_inputs = {};
for ii = 1:length(ng)  
    grid_inputs(length(grid_inputs)+1) = {['isg',num2str(ng(ii)),'q']};
    grid_inputs(length(grid_inputs)+1) = {['isg',num2str(ng(ii)),'d']};
end
for ii = 1:length(n_ld)  
    grid_inputs(length(grid_inputs)+1) = {['Rd',num2str(n_ld(ii))]};
end
grid_inputs(length(grid_inputs)+1) = {['SG',num2str(n_slk),'_w']};

grid_outputs = {};
for ii = 1:length(ng)  
    grid_outputs(length(grid_outputs)+1) = {['vb',num2str(ng(ii)),'q']};
    grid_outputs(length(grid_outputs)+1) = {['vb',num2str(ng(ii)),'d']};
end

%grid_inputs = {'isg30q','isg30d','isg31q','isg31d','isg32q','isg32d','isg33q','isg33d','isg34q','isg34d','isg35q','isg35d','isg36q','isg36d','Rd9','Rd10','Rd11','Rd12','Rd13','SG1_w'};
%grid_outputs = {'vb31q','vb31d','vb38q','vb38d','iSG31q','itrd_1_7','itrq_2_13','itrd_2_13','itrq_3_8','itrd_3_8','itrq_4_9','itrd_4_9','itrq_5_11','itrd_5_11','itrq_6_12','itrd_6_12'};
SS_grid = connect(SS_blocks{:},grid_inputs,grid_outputs);
disp(['State space of the grid - Completed'])
