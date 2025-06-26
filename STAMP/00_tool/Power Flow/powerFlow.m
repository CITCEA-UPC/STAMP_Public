function results = powerFlow(T_nodes, T_global, T_DC_NET, T_NET, T_trafo, T_load, T_TH, T_SG, T_STATCOM, T_VSC, T_MMC_Pac_GFll, T_MMC_Vdc_GFll, T_b2b, T_user)
    
    % power flow for steady-state analysis
    
    % load grid
    grid = Parser();
    
    % parse the datafile
    grid = parse(grid, T_nodes, T_global, T_NET, T_DC_NET, T_trafo, T_load, T_TH, ...
                T_SG, T_STATCOM, T_VSC, T_MMC_Pac_GFll, T_MMC_Vdc_GFll, T_b2b, T_user);
    
    % solve
    max_err = 1e-10;
    max_iter = 50;
    err = 1.0;
    k_iter = 0;
    
    while err > max_err && k_iter < max_iter || k_iter < 2
        [grid, err, n_iter] = solver(grid, max_err, max_iter);
        if not(isempty(grid.b2b))
            grid = solver_dc(grid);
        end
        k_iter = k_iter + 1;
    end

    if k_iter==max_iter
        warning('Power flow maximum iterations reached')
    else
        disp('Power flow terminated correctly')
    end
    
    results = Results(grid);
end