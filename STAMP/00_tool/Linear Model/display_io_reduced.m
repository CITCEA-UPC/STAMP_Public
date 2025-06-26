
inputNames = {};
outputNames = {};

for idx = 1:length(l_blocks)
    ss_block = l_blocks{idx};
    inputNames = cat(2, inputNames, ss_block.InputName');
    outputNames = cat(2, outputNames, ss_block.OutputName');
end

inputNames = sort(unique(inputNames));
outputNames = sort(unique(outputNames)); % display BOTH internal and external outputs
inputNames = setdiff(inputNames,outputNames,'stable'); % display ONLY external inputs

% Inputs
[indx_in,tf_in] = listdlg('ListString',T_nodes{bus_in,2:end},'PromptString',{'Select inputs'});
if contains(T_nodes{bus_in,2:end}(indx_in),"Load")
    num = T_load.number(T_load.bus == bus_in);
    input = ['NET.Rld' num2str(num)];
elseif contains(T_nodes{bus_in,2:end}(indx_in),"TH")
    num = T_TH.number(T_TH.bus == bus_in);
    input = ['TH' num2str(num) '.vnq'];
elseif contains(T_nodes{bus_in,2:end}(indx_in),"user")
    num = T_user.number(T_user.bus == bus_in);
    input = ['User' num2str(num) '.Pref'];
elseif contains(T_nodes{bus_in,2:end}(indx_in),"SG")
    num = T_SG.number(T_SG.bus == bus_in);
    input = ['SG' num2str(num) '.Pref'];
end

% Outputs
indx_out = zeros(1,length(outputNames));
for idx = 1:length(user_out)
    bus = user_out(idx);
    num = T_user.number(T_user.bus == bus);
    indx_out = indx_out | contains(outputNames,['NET.vn' num2str(bus)]); %voltages
    indx_out = indx_out | contains(outputNames,['SG'   num2str(bus) '_w']); %omega
    indx_out = indx_out | contains(outputNames,['GFOR' num2str(bus) '.w']); %omega
    indx_out = indx_out | contains(outputNames,['GFOL' num2str(bus) '.w']); %omega
    if bus == bus_slk
        indx_out = indx_out | contains(outputNames,REF_w); %omega
    end

    for idx_el = 1:length(num)
        indx_out = indx_out | contains(outputNames,['USER'  num2str(num(idx_el)) '.']); %currents
    end
end

for idx = 1:length(load_out)
    bus = load_out(idx);
    num = T_load.number(T_load.bus == bus);
    indx_out = indx_out | contains(outputNames,['NET.vn' num2str(bus)]); %voltages
    indx_out = indx_out | contains(outputNames,['Load' num2str(num) '.']); %currents
end

for idx = 1:length(th_out)
    bus = th_out(idx);
    num = T_TH.number(T_TH.bus == bus);
    indx_out = indx_out | contains(outputNames,['NET.vn' num2str(bus)]); %voltages
    indx_out = indx_out | contains(outputNames,['TH' num2str(num) '.']); %currents
end

for idx = 1:length(sg_out)
    bus = sg_out(idx);
    num = T_SG.number(T_SG.bus == bus);
    indx_out = indx_out | contains(outputNames,['NET.vn' num2str(bus)]); %voltages
    indx_out = indx_out | contains(outputNames,['SG' num2str(num) '.']); %currents
    indx_out = indx_out | contains(outputNames,['SG'   num2str(bus) '_w']); %omega
    if bus == bus_slk
        indx_out = indx_out | contains(outputNames,REF_w); %omega
    end
end

for idx = 1:length(vsc_out)
    bus = vsc_out(idx);
    num_vsc = T_VSC.number(T_VSC.bus == bus);
    for idx_vsc = 1:length(num_vsc)
        num = num_vsc(idx_vsc);
        mode = T_VSC.mode{T_VSC.bus == bus & T_VSC.number == num};
        indx_out = indx_out | contains(outputNames,['NET.vn' num2str(bus)]); %voltages
        indx_out = indx_out | contains(outputNames,['VSC' num2str(num) '.']); %currents        
        indx_out = indx_out | contains(outputNames,[mode num2str(num) '.w']); %omega
        if bus == bus_slk
            indx_out = indx_out | contains(outputNames,REF_w); %omega
        end       
    end
end


outputNames_select = outputNames(indx_out);
[indx_out,tf_out] = listdlg('ListString',outputNames_select,'PromptString',{'Select outputs'});
output = outputNames_select(indx_out);

ss_sys = connect(l_blocks{:}, input, output);