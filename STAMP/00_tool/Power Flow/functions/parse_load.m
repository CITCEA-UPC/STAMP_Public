function g = parse_load(g)

if isempty(g.load)
    return
end

bus = g.load.bus;
R = g.load.R;
X = g.load.X;
P = g.load.P;
Q = g.load.Q;

g.Sload = zeros(g.nb, 1);

nload = length(bus);

for k=1:1:nload
    if not(ismember(bus(k), g.pv)) && not(ismember(bus(k), g.slack))
        g.pq(end+1) = bus(k);
    else
        ME = MException('PowerFlow:busMultipleDefined', 'Bus %s is defined both as PQ and PV',num2str(intersect(bus(k),unique([g.slack, g.pv]))));
        throw(ME)        
    end
    
    if not(P(k) == 0.0) || not(Q(k) == 0.0)
        g.Sload(bus(k)) = g.Sload(bus(k)) + (P(k) + 1i * Q(k));
        g.S(bus(k)) = g.S(bus(k)) - (P(k) + 1i * Q(k));
        g.bus_pq(end+1) = bus(k);
        g.P_pq(end+1) = P(k);
        g.Q_pq(end+1) = Q(k);
        
    elseif not(R(k) == 0.0) && not(X(k) == 0.0)
        g.Y(bus(k), bus(k)) = g.Y(bus(k), bus(k)) + 1 / R(k) + 1 / (1i * X(k));
        g.bus_rx(end+1) = bus(k);
        g.r_rx(end+1) = R(k);
        g.x_rx(end+1) = X(k);
        
    elseif not(R(k) == 0.0)
        g.Y(bus(k), bus(k)) = g.Y(bus(k), bus(k)) + 1 / R(k);
        g.bus_rx(end+1) = bus(k);
        g.r_rx(end+1) = R(k);
        g.x_rx(end+1) = X(k);
        
    elseif not(X(k) == 0.0)
        g.Y(bus(k), bus(k)) = g.Y(bus(k), bus(k)) + 1 / (1i * X(k));
        g.bus_rx(end+1) = bus(k);
        g.r_rx(end+1) = R(k);
        g.x_rx(end+1) = X(k);
        
    end
end

g.pqpv = sort(unique([g.pq, g.pv]));

end

