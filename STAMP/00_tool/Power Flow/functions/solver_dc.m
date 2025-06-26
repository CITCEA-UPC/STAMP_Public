function grid = solver_dc(g)


Vv = g.Vm .* exp(1i * g.theta);


if isempty(g.load)
    Iall = g.Y * Vv;
else
    Iall = g.Y * Vv + conj(g.Sload ./ Vv);
end

I1_b2b = Iall(g.bus1_b2b);
I2_b2b = Iall(g.bus2_b2b);

Vb1 = Vv(g.bus1_b2b) + I1_b2b * g.Z1;
Vb2 = Vv(g.bus2_b2b) + I2_b2b * g.Z2;

Pb1 = real(Vb1 * conj(I1_b2b));

Vdc1 = [];
Pdc2 = [];
P2fin = [];
Idc = [];
for k=1:1:length(I1_b2b)
    Vdc1(end+1) = (g.Vdc(k) + sqrt(g.Vdc(k) .^2 - 4 * Pb1(k) * g.Rdc(k))) / 2;
    Pdc2(end+1) = (Vdc1(k) - g.Vdc(k)) / g.Rdc(k) * g.Vdc(k);
    %P2fin(end+1) = Pdc2(k) - abs(I2_b2b(k)) .^2 * real(g.Z2(k));
    P2fin(end+1) = Pdc2(k) - abs(I2_b2b(k)) .^2 * real(g.Z2(k));
    Idc(end+1) = (Vdc1(k) - g.Vdc(k)) / g.Rdc(k);
end
g.Vdc1 = Vdc1;
g.Vdc2 = g.Vdc;
g.Idc = Idc;

g.S = g.S_nob2b;

% update P2 powers
bus1 = g.b2b.bus1;
bus2 = g.b2b.bus2;
P1 = g.b2b.P1;
Q1 = g.b2b.Q1;
% P2 = g.b2b(:,5);
Q2 = g.b2b.Q2;

for k=1:1:length(I1_b2b)
    g.S(bus1(k)) = g.S(bus1(k)) + (P1(k) + 1i * Q1(k));
    g.S(bus2(k)) = g.S(bus2(k)) + (P2fin(k) + 1i * Q2(k));
end
    
% final store
grid = g;

end

