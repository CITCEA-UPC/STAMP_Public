function[error] = SS_ADD(NAMEREF,NAMEMES,NAMEERR)

Aerror     = [0];
Berror     = [0 0];
Cerror     = [0];
Derror     = [1 1];

error_x = {''}; 
error_u = {NAMEREF NAMEMES};
error_y = {NAMEERR};
error   = ss(Aerror,Berror,Cerror,Derror,'StateName',error_x,'inputname',error_u,'outputname',error_y);
end