function[shaft] = SS_SHFT(H,D1,we_0,wbase,Tm_0,NUMBER)

Ashaft = [-(D1*we_0+Tm_0)/(2*H*we_0) 0; wbase 0];
Bshaft = [1/(2*H*we_0) -1/(2*H); 0 0];
Cshaft = [1 0; 0 1];
Dshaft = [0 0; 0 0];

for NUM=NUMBER:NUMBER
we      = sprintf('SG%d.we',NUM);
Pm      = sprintf('SG%d.Pm',NUM);
etheta  = sprintf('SG%d.dthetae',NUM); 
Te      = sprintf('SG%d.Te',NUM);
end  
 
shaft_x = {we etheta}; 
shaft_u = {Pm Te};
shaft_y = {we etheta};
shaft   = ss(Ashaft,Bshaft,Cshaft,Dshaft,'StateName',shaft_x,'inputname',shaft_u,'outputname',shaft_y);
end
