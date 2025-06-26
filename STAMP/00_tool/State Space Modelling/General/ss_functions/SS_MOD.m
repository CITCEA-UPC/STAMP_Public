function[mod] = SS_MOD(NAMEQ,VALQ0,NAMED,VALD0,NAMEOUT)

Amod     = [0];
Bmod     = [0 0];
Cmod     = [0];
Dmod     = [VALQ0/sqrt(VALQ0^2+VALD0^2) VALD0/sqrt(VALQ0^2+VALD0^2)];
 
mod_x = {''}; 
mod_u = {NAMEQ NAMED};
mod_y = {NAMEOUT};
mod   = ss(Amod,Bmod,Cmod,Dmod,'StateName',mod_x,'inputname',mod_u,'outputname',mod_y);
end