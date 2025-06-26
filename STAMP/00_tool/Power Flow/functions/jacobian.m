function [J] = jacobian(g, vec_p, vec_q, vec_d, vec_v)


V = g.Vm .* exp(1i .* g.theta);
V_diag = diag(V);

Vm_diag = diag(g.Vm);

YV_diag = diag(g.Y * V);
YV_diag_conj = conj(YV_diag);

J1J4 = 1i * V_diag * (YV_diag_conj - conj(g.Y) * conj(V_diag));
J2J5 = V_diag * (YV_diag_conj + conj(g.Y) * conj(V_diag)) / Vm_diag;

J1 = real(J1J4);
J4 = imag(J1J4);

J2 =real(J2J5);
J5 = imag(J2J5);

J1k = J1(vec_p, vec_d);
J4k = J4(vec_q, vec_d);

J2k = J2(vec_p, vec_v);
J5k = J5(vec_q, vec_v);

J = [J1k, J2k; J4k, J5k];

end

