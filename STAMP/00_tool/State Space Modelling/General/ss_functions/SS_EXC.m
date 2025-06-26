function[exc] = SS_EXC(KA,TA,TB,TC,K,NUMBER,IN,OUT)

Aexc    = [0 1; -1/(TA*TB) -(1/TB)-(1/TA)];
Bexc    = [0 ; 1];
Cexc    = [KA/(TA*TB) (TC*KA)/(TA*TB)]*K;
Dexc    = [0];

for NUM=NUMBER:NUMBER
xexc1       = sprintf('SG%d.xexc_1',NUM);
xexc2       = sprintf('SG%d.xexc_2',NUM);
end  
 
exc_x = {xexc1 xexc2}; 
exc_u = IN;
exc_y = OUT;
exc   = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);
end