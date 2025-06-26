function[gain] = SS_GAIN(NAMEIN,NAMEOUT,K)

Again     = [0];
Bgain     = [0];
Cgain     = [0];
Dgain     = [K];

gain_x = {''}; 
gain_u = {NAMEIN};
gain_y = {NAMEOUT};
gain   = ss(Again,Bgain,Cgain,Dgain,'StateName',gain_x,'inputname',gain_u,'outputname',gain_y);
end