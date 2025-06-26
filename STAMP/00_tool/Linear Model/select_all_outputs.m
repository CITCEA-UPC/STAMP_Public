outputNames = {};

for idx = 1:length(l_blocks)
    ss_block = l_blocks{idx};
    outputNames = cat(2, outputNames, ss_block.OutputName');
end

outputNames = sort(unique(outputNames)); % display BOTH internal and external outputs
output = outputNames;