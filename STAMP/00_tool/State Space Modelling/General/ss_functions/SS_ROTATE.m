function[rot] = SS_ROTATE(etheta_0, var_q0, var_d0, varBase, direction, u, y)

if direction == "glob2loc"
    k=-1; 
    factor = 1/varBase;
elseif direction == "loc2glob"
    k=1; 
    factor = varBase;
end

Arot     = [0];
Brot     = [0 0 0];
Crot     = [0;0];
Drot     = [cos(etheta_0)       k*sin(etheta_0)     -sin(etheta_0)*var_q0 + k*cos(etheta_0)*var_d0;
            -k*sin(etheta_0)    cos(etheta_0)       -k*cos(etheta_0)*var_q0-sin(etheta_0)*var_d0]*factor;
 
rot_x = {''}; 
rot_u = u;
rot_y = y;
rot   = ss(Arot,Brot,Crot,Drot,'StateName',rot_x,'inputname',rot_u,'outputname',rot_y);
end