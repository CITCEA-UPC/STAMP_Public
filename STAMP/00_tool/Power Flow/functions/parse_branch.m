function g = parse_branch(g)

bus_f = g.branch.bus_from;
bus_t = g.branch.bus_to;
R = g.branch.R;
X = g.branch.X;
B = g.branch.B;
tm = g.branch.tap_module;
ta = g.branch.tap_angle;

g.bus = unique([bus_f, bus_t]);
g.nl = length(bus_f);
g.nb = length(g.bus);
t = tm(:) .* exp(1i .* ta(:) * pi / 180);


% build Yserie
Ys(:) = 1 ./ (R(:) + 1i * X(:));
Yrx = diag(Ys);
A = zeros(g.nb, g.nl);

for k=1:1:g.nl
    A(bus_f(k), k) = 1;
    A(bus_t(k), k) = -1;
end

At = transpose(A);
Yserie = A * Yrx * At;

% modify Yserie to add tap changers
for k=1:1:g.nl
    if not(t(k) == 1.0 + 1i * 0.0)
        % mod
        Yserie(bus_f(k), bus_f(k)) = Yserie(bus_f(k), bus_f(k)) - Yrx(k) + Yrx(k) / abs(t(k)) .^2;
        Yserie(bus_f(k), bus_t(k)) = Yserie(bus_f(k), bus_t(k)) + Yrx(k) - Yrx(k) / conj(t(k));
        Yserie(bus_t(k), bus_f(k)) = Yserie(bus_t(k), bus_f(k)) + Yrx(k) - Yrx(k) / t(k);
        Yserie(bus_t(k), bus_t(k)) = Yserie(bus_t(k), bus_t(k)) - Yrx(k) + Yrx(k);
    end
end


% build Yshunt
Yshunt = zeros(g.nb, g.nb);

for k=1:1:g.nl
%     Yshunt(bus_f(k), bus_f(k)) = Yshunt(bus_f(k), bus_f(k)) + i * B(k) / 2;
%     Yshunt(bus_t(k), bus_t(k)) = Yshunt(bus_t(k), bus_t(k)) + i * B(k) / 2;
    Yshunt(bus_f(k), bus_f(k)) = Yshunt(bus_f(k), bus_f(k)) + 1i * B(k) / 2 / abs(t(k)) .^2;
    Yshunt(bus_t(k), bus_t(k)) = Yshunt(bus_t(k), bus_t(k)) + 1i * B(k) / 2;
end

% add all
g.Y = Yserie + Yshunt;


end

