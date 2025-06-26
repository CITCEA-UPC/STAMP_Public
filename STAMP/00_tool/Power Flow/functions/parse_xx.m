function [g,g_busxx] = parse_xx(g, g_xx,g_busxx)

if isempty(g_xx)
    return
end

% bus types:
% 0: slack, 1: pq, 2: pv

bus =   g_xx.bus;
P =     g_xx.P;
Q =     g_xx.Q;
V =     g_xx.V;
type =  g_xx.type;

n_elements = length(bus);

    for k=1:1:n_elements
        g.S(bus(k)) = g.S(bus(k)) + (P(k) + 1i * Q(k));
        g.Vm(bus(k)) = V(k);       
        g_busxx(end+1)= bus(k);

        if type(k) == 0  % slack
            g.slack(end+1) = bus(k);
            
        elseif type(k) == 1  % pq
            g.pq(end+1) = bus(k);
            
        elseif type(k) == 2  % pv
            g.pv(end+1) = bus(k);
        end  
    end

end