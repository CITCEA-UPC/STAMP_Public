function [T_modal] = FMODAL(ss_sys)

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
modeID = 1:height(T_eig);
modeID_MATLAB = zeros(1,length(modeID));
for idx = 1:length(modeID)
    modeID_MATLAB(idx) = T_eig.Mode(T_eig.ID == modeID(idx));
end


% select desired mode and PF>0.1
nPF_mode = nPF(:,modeID_MATLAB);
locs = nPF_mode >= 0;
nPF_red = nPF_mode(sum(locs,2)>=1,:); 

fig=figure;
h=heatmap(nPF_red);
h.YData=get(ss_sys,'StateName');
h.XData = modeID;
% h.YDisplayLabels(1:1:251) = {''};
% h.XDisplayLabels(1:1:251) = {''};
h.ColorScaling    = 'scaledcolumns';
h.Colormap        = flipud(gray);
h.ColorbarVisible = 'on';
h.CellLabelFormat = '%.2f';
%     h.Title           = Name; 
h.XLabel          = 'Eigenvalues';
h.YLabel          = 'States';
h.FontName        = 'Times New Roman'; 
h.FontSize        = 8;


%   Modal table

Asize=size(ss_sys.a);
n=Asize(1,1);

sz = [n 6];
varTypes = ["double","double","double","double","double","double"];
varNames = ["Mode","Real","Imaginary","Frequency","Damping", "FrequencyResonance"];
T_modal = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


for i=1:1:n
    lambda(i,1)=D(i,i);
    sigma(i,1)=real(lambda(i,1));
    omega(i,1)=imag(lambda(i,1));
    damping_ratio(i,1)=-sigma(i,1)/(abs(lambda(i,1)));
    freq_p(i,1)=abs(omega(i,1))/(2*pi);
    if damping_ratio(i,1)<0.707
        freq_r(i,1)=(abs(lambda(i,1))*sqrt(1-2*damping_ratio(i,1)^2))/(2*pi);
    else
        freq_r(i,1)=0;
    end
    modal=[i sigma(i,1) omega(i,1) freq_p(i,1) damping_ratio(i,1) freq_r(i,1)];
    modal=(round(modal,5));
    T_modal(i,:) = num2cell(modal);
end

T_modal = sortrows(T_modal,2,'descend');
id = [1:height(T_modal)]';
T_modal.Mode = id;

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