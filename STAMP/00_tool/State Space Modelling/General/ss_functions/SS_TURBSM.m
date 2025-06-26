function[turb] = SS_TURBSM(K,tau,NAMEIN,NAMEOUT,NUMBER)

[Aturb,Bturb,Cturb,Dturb]=tf2ss([K*tau 1],[tau 1]);

for NUM=NUMBER:NUMBER
xturb       = strcat(sprintf('SG%d.xturb_',NUM));
end  
 
turb_x = {xturb}; 
turb_u = {NAMEIN};
turb_y = {NAMEOUT};

turb = ss(Aturb,Bturb,Cturb,Dturb,'StateName',turb_x,'inputname',turb_u,'outputname',turb_y);

end