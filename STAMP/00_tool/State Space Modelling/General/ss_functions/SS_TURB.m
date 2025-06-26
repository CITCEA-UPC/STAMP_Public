function[turb] = SS_TURB(T,F,NAMEIN,STAGE,NUMBER)

Aturb  = [-1/T];
Bturb  = [1];
Cturb  = [1/T; F/T];
Dturb  = [0;0];  

for NUM=NUMBER:NUMBER
xturb       = strcat(sprintf('SG%d.xturb_',NUM),num2str(STAGE));
yturb       = strcat(sprintf('SG%d.Yturb_',NUM),num2str(STAGE));
Tturb       = strcat(sprintf('SG%d.Tt_',NUM),num2str(STAGE));
uturb       = NAMEIN;
end  
 
turb_x = {xturb}; 
turb_u = {uturb};
turb_y = {yturb Tturb};
turb   = ss(Aturb,Bturb,Cturb,Dturb,'StateName',turb_x,'inputname',turb_u,'outputname',turb_y);
end