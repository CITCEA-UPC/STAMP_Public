function[shaft] = SS_SHFTMM(H1,H2,H3,H4,H5,K12,K23,K34,K45,D1,D2,D3,D4,D5,wb,NUMBER)

Ashaft  = [-D1/2/H1 0 0 0 0 1/2/H1 0 0 0;
            0 -D2/2/H2 0 0 0 -1/2/H2 1/2/H2 0 0;
            0 0 -D3/2/H3 0 0 0 -1/2/H3 1/2/H3 0;
            0 0 0 -D4/2/H4 0 0 0 -1/2/H4 1/2/H4;
            0 0 0 0 -D5/2/H5 0 0 0 -1/2/H5;
            -K12*wb K12*wb 0 0 0 0 0 0 0;
            0 -K23*wb K23*wb 0 0 0 0 0 0;
            0 0 -K34*wb K34*wb 0 0 0 0 0;
            0 0 0 -K45*wb K45*wb 0 0 0 0;];  

Bshaft  = [-1/(2*H1)  0  0  0  0; 
            0  1/(2*H2)  0  0  0; 
            0  0  1/(2*H3)  0  0; 
            0  0  0  1/(2*H4)  0; 
            0  0  0  0  1/(2*H5);  
            0  0  0  0  0; 
            0  0  0  0  0; 
            0  0  0  0  0; 
            0  0  0  0  0];
Cshaft  = [1  0  0  0  0  0  0  0  0];
Dshaft  = [0  0  0  0  0];


for NUM=NUMBER:NUMBER
    deltaw1       = sprintf('SG%d.deltaw1',NUM);
    deltaw2       = sprintf('SG%d.deltaw2',NUM);
    deltaw3       = sprintf('SG%d.deltaw3',NUM);
    deltaw4       = sprintf('SG%d.deltaw4',NUM);
    deltaw5       = sprintf('SG%d.deltaw5',NUM);
    ms2      = sprintf('SG%d.ms2',NUM);
    ms3      = sprintf('SG%d.ms3',NUM);
    ms4      = sprintf('SG%d.ms4',NUM);
    ms5      = sprintf('SG%d.ms5',NUM);
    we_pu    = sprintf('SG%d.w_pu',NUM); 
    Te          = sprintf('SG%d.Te',NUM);
    Tt2         = sprintf('SG%d.Tt_2',NUM);
    Tt3         = sprintf('SG%d.Tt_3',NUM);
    Tt4         = sprintf('SG%d.Tt_4',NUM);
    Tt5         = sprintf('SG%d.Tt_5',NUM);
end  

shaft_x = {deltaw1 deltaw2 deltaw3 deltaw4 deltaw5 ms2 ms3 ms4 ms5}; 
shaft_u = {Te Tt2 Tt3 Tt4 Tt5};
shaft_y = {we_pu}; 
shaft   = ss(Ashaft,Bshaft,Cshaft,Dshaft,'StateName',shaft_x,'inputname',shaft_u,'outputname',shaft_y);
end