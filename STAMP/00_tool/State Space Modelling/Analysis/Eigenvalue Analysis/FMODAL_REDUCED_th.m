function [T_modal_red, states_red] = FMODAL_REDUCED_th(ss_sys,modeID,th)

%   Participation factors

[RV,D,LV] = eig(ss_sys.a); 
PFs=LV.*RV; 

nPF=abs(PFs*diag(1./max(abs(PFs)))); 
% nPF=abs(PF);


% Get MATLAB orderning
eig_list = diag(D);
sz = [size(eig_list,1) 3];
varTypes = ["double","double","double"];
varNames = ["Mode","ID","Real"];
T_eig = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
T_eig.Mode = [1:height(T_eig)]'; 
T_eig.Real = real(eig_list);
T_eig = sortrows(T_eig,"Real",'descend');
id = [1:height(T_eig)]';
T_eig.ID = id;

% Obtain new IDs relative to MATLAB order
modeID_MATLAB = zeros(1,length(modeID));
for idx = 1:length(modeID)
    modeID_MATLAB(idx) = T_eig.Mode(T_eig.ID == modeID(idx));
end


% select desired mode and PF>0.1
nPF_mode = nPF(:,modeID_MATLAB);
% locs = nPF_mode >= 0.1;
locs = nPF_mode >= th; %round to 0.1
nPF_red = nPF_mode(sum(locs,2)>=1,:); 

fig=figure;
h=heatmap(nPF_red);
allStates = get(ss_sys,'StateName');
h.YData = allStates(sum(locs,2)>=1);
h.XData = modeID;
h.ColorScaling    = 'scaledcolumns';
h.Colormap        = flipud(gray);
h.ColorbarVisible = 'off';
h.CellLabelFormat = '%.2f';
%     h.Title           = Name; 
h.ColorScaling = 'scaledcolumns';
h.XLabel          = 'Eigenvalues';
h.YLabel          = 'States';
h.FontName        = 'Times New Roman'; 
h.FontSize        = 10;
h.NodeChildren(3).YAxis.TickLabelInterpreter = 'none';

set(gcf, 'Position',  [400, 400, max(60*size(nPF_red,2),180), max(25*size(nPF_red,1),80)])
set(gcf,'color','w');

%   Modal table

Asize=size(ss_sys.a);
n=Asize(1,1);
for i=1:1:n
    eig_list(i,1)=D(i,i);
    sigma(i,1)=real(eig_list(i,1));
    omega(i,1)=imag(eig_list(i,1));
    damping_ratio(i,1)=-sigma(i,1)/(abs(eig_list(i,1)));
    freq_p(i,1)=abs(omega(i,1))/(2*pi);
    if damping_ratio(i,1)<0.707
    freq_r(i,1)=(abs(eig_list(i,1))*sqrt(1-2*damping_ratio(i,1)^2))/(2*pi);
    else
    freq_r(i,1)=0;
    end
    modal(i,:)=[i sigma(i,1) omega(i,1) damping_ratio(i,1) freq_p(i,1) freq_r(i,1)];
    modal=(round(modal,5));
end
T_modal = array2table(modal,'VariableNames',{'Mode','Real','Imaginary','Damping','FrequencyMode','FrequencyResonance'});
T_modal = sortrows(T_modal,2,'descend');
id = [1:height(T_modal)]';
T_modal.Mode = id;

T_modal_red = T_modal(ismember(T_modal.Mode,modeID),:);
states_red  = h.YData;
%   Table fig

% clf(figure(500))
% uit              = uitable(figure(500));
% uit.Data         = T_modal{:,{'Mode' 'FrequencyPoles' 'Damping' 'Real'}}; 
% uit.ColumnName   = {T_modal.Properties.VariableNames{1} T_modal.Properties.VariableNames{5} T_modal.Properties.VariableNames{4} T_modal.Properties.VariableNames{2}};
% % uit.ColumnFormat = {'numeric' 'numeric' 'numeric'};
% uit.FontName     = 'Times New Roman'; 
% uit.FontSize     = 14;
% uit.Position     = [20 20 240 550];
% uit.ColumnWidth  = {50 150};

end