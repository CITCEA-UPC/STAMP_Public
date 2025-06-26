function [Af] = residuals(g, vec_p, vec_q)

V = g.Vm .* exp(1i .* g.theta);
V_diag = diag(V);

Ss = V_diag * conj(g.Y) * conj(V);

Afp = real(Ss) - real(g.S);
Afq = imag(Ss) - imag(g.S);

Af = [Afp(vec_p); Afq(vec_q)];

end

