function nonlinear_trafos(nonlinear, blocks, names)

    for idx = 1:length(blocks)
        T_xx = blocks{idx};
        name = names{idx};
        for idx_xx = 1:height(T_xx)
            element = T_xx(idx_xx,:);
            state = 'off';
            if(T_xx.trafo{:} == "No"); state = 'on'; end
            set_param(join([nonlinear '/' name num2str(element.number) '/trafo/trafo_branch']),'commented', state)
        end
    end
end

