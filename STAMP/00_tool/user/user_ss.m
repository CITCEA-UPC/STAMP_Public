
% Arrays to store linearization points
lp_SG = {};
lp_GFOL = {};
lp_GFOR = {};

for idx = 1:height(T_user)

        T_XX = T_user(idx,:);
        elementName = T_XX.element{:};   
        switch elementName
            case 'SG' 
                run generate_SG_pu.m      % generate SS    
                l_blocks{end+1} = SS_SG;  % append ss to l_blocks   
            case 'GFOL'    
                run generate_GFOL.m         % generate SS    
                l_blocks{end+1} = SS_GFOL;  % append ss to l_blocks   
            case 'GFOR' 
                run generate_GFOR.m         % generate SS    
                l_blocks{end+1} = SS_GFOR;  % append ss to l_blocks   
        end
end
