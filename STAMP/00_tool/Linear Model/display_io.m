
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

[indx_in,tf_in] = listdlg('ListString',inputNames,'PromptString',{'Select inputs'});
[indx_out,tf_out] = listdlg('ListString',outputNames,'PromptString',{'Select outputs'});

input = inputNames(indx_in);
output = outputNames(indx_out);