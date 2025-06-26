function g = parse_final(g)

g.n_vsc   = length(g.bus_vsc);
g.n_sg    = length(g.bus_sg);
g.n_stat  = length(g.bus_stat);
g.n_th    = length(g.bus_th);
g.n_user  = length(g.bus_user);
g.n_pq    = length(g.bus_pq);
g.n_rx    = length(g.bus_rx);
g.n_b2b   = length(g.bus1_b2b);


% check buses are well defined

g.bus_pq = sort(unique(g.bus_pq));
g.bus_rx = sort(unique(g.bus_rx));

g.pq = sort(unique(g.pq));

if ~isempty(intersect(g.pq,g.pv))
        ME = MException('PowerFlow:busMultipleDefined', 'Bus %s is defined both as PQ and PV',num2str(intersect(g.pq,g.pv)));
        throw(ME)
end
if ~isempty(intersect(g.pq,g.slack))
        ME = MException('PowerFlow:busMultipleDefined', 'Bus %s is defined both as PQ and SLACK',num2str(intersect(g.pq,g.slack)));
        throw(ME)
end
if ~isempty(intersect(g.pv,g.slack))
        ME = MException('PowerFlow:busMultipleDefined', 'Bus %s is defined both as PV and SLACK',num2str(intersect(g.pv,g.slack)));
        throw(ME)
end

[uniquePV, i] = unique(g.pv);
if length(uniquePV) ~= length(g.pv)
        idx = find(not(ismember(1:numel(g.pv),i)));
        ME = MException('PowerFlow:busMultipleDefined', 'PV bus %s has more than 1 element connected',num2str(g.pv(idx)));
        throw(ME)
end

[uniqueSK, i] = unique(g.slack);
if length(uniqueSK) ~= length(g.slack)
        idx = find(not(ismember(1:numel(g.slack),i)));
        ME = MException('PowerFlow:busMultipleDefined', 'Slack bus %s has more than 1 element connected',g.slack(idx));
        throw(ME)
end


g.slack = sort(g.slack);
g.pv = sort(g.pv);
g.pqpv = sort([g.pq, g.pv]);


end

