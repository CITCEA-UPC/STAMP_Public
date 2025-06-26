function [grid, err, n_iter] = solver(g, max_err, max_iter)

    err = 1.0;
    n_iter = 0;
    
    [vec_d, vec_v] = vec_dv(g);
    [vec_p, vec_q] = vec_pq(g);
    
    while err > max_err && n_iter < max_iter
     
        Af = residuals(g, vec_p, vec_q);
        J = jacobian(g, vec_p, vec_q, vec_d, vec_v);
        Ax = - inv(J) * Af;
    
        g.theta(vec_d) = g.theta(vec_d) + Ax(1:length(vec_d));
        g.Vm(vec_v) = g.Vm(vec_v) + Ax(length(vec_d)+1:length(vec_d)+length(vec_v));
        
        err = max(abs(Af));
        n_iter = n_iter + 1;
    
    end
    
    % final store
    grid = g;

end

