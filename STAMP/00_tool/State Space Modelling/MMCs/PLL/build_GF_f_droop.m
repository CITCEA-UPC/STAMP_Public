function f_droop = build_GF_f_droop(kf, number,REF_w)    
        % droop:
        Apll_n = [0];
        Bpll_n = [0 0];
        Cpll_n = [0];
        Dpll_n = [kf -kf];

        pll_n_x = '';

        pll_n_u = {join(['IPC',num2str(number),'.Pac_ref']);...
                   join(['IPC',num2str(number),'.Pac_filt']);};

        pll_n_y = {join(['IPC',num2str(number),'.w'])};

        pll_n = ss(Apll_n,Bpll_n,Cpll_n,Dpll_n,'StateName',pll_n_x,'inputname',pll_n_u,'outputname',pll_n_y);
    
    
        % e_theta (PLL-Grid):
        Atheta_n = [0];
        Btheta_n = [1 -1];
        Ctheta_n = [1];
        Dtheta_n = [0 0];
        theta_n_x = { join(['IPC',num2str(number),'.I_pll'])};
        theta_n_u = { join(['IPC',num2str(number),'.w']);...
                      REF_w };
        theta_n_y = { join(['IPC',num2str(number),'.angle'] ) };
        theta_n = ss(Atheta_n,Btheta_n,Ctheta_n,Dtheta_n,'StateName',theta_n_x,'inputname',theta_n_u,'outputname',theta_n_y);
        
        y = [ theta_n_y; pll_n_y];
        u = [ pll_n_u ; REF_w] ;

        f_droop = connect(pll_n , theta_n, u, y );
           
end