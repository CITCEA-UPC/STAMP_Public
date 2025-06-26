function[dtheta] = SS_DTHETA(wb,NUMBER)

Adtheta = [0];
Bdtheta = [wb];
Cdtheta = [1];
Ddtheta = [0];

for NUM=NUMBER:NUMBER
    dthetae_x     = sprintf('SG%d.dthetae_x',NUM);
    dthetae       = sprintf('SG%d.dthetae',NUM);
    deltaw1       = sprintf('SG%d.deltaw1',NUM);
end

dtheta_x = {dthetae_x};
dtheta_y = {dthetae};
dtheta_u = {deltaw1};
dtheta = ss(Adtheta,Bdtheta,Cdtheta,Ddtheta,'StateName',dtheta_x,'inputname',dtheta_u,'outputname',dtheta_y);
end
