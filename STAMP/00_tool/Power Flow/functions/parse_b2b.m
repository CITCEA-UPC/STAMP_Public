function g = parse_b2b(g)

if isempty(g.b2b)
    return
end


% bus types:
% 0: slack, 1: pq, 2: pv

bus1 = g.b2b.bus1;
bus2 = g.b2b.bus2;
P1   = g.b2b.P1;
Q1   = g.b2b.Q1;
P2   = g.b2b.P2;
Q2   = g.b2b.Q2;
V1   = g.b2b.V1;
V2   = g.b2b.V2;
Vdc  = g.b2b.Vdc;
R1   = g.b2b.R1;
X1   = g.b2b.X1;
R2   = g.b2b.R1;
X2   = g.b2b.X2;
Rdc  = g.b2b.Rdc;
type = g.b2b.type;

nb2b = height(g.b2b);
g.S_nob2b = g.S;

    for k=1:1:nb2b
        g.S(bus1(k)) = g.S(bus1(k)) + (P1(k) + 1i * Q1(k));
        g.S(bus2(k)) = g.S(bus2(k)) + (P2(k) + 1i * Q2(k));
        
        g.Vm(bus1(k)) = V1(k);
        g.Vm(bus2(k)) = V2(k);
        
        g.bus1_b2b(end+1) = bus1(k);
        g.bus2_b2b(end+1) = bus2(k);
        
        g.Vdc(end+1) = Vdc(k);
        g.Rdc(end+1) = Rdc(k);
        g.Z1(end+1) = R1(k) + 1i*X1(k);
        g.Z2(end+1) = R2(k) + 1i*X2(k);     
        
        if type(k) == 0  % slack
            g.slack(end+1) = bus1(k);
            g.slack(end+1) = bus2(k);
            
        elseif type(k) == 1  % pq
            g.pq(end+1) = bus1(k);
            g.pq(end+1) = bus2(k);
            
        elseif type(k) == 2  % pv
            g.pv(end+1) = bus1(k);
            g.pv(end+1) = bus2(k); 
        end    
    end
end