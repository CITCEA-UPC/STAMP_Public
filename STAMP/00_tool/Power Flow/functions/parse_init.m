function g = parse_init(g)
g.S     = zeros(g.nb, 1);
g.Vm    = ones(g.nb, 1)*g.Vb;
g.theta = zeros(g.nb, 1);
end

