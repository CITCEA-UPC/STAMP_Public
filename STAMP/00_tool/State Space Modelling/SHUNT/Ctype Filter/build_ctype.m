function ctype = build_ctype(number,C1,L, C2, R, bus,wb,u,Vg2l,Il2g)

if u==1
    A = [-1/(R*C1) -wb 0 0 1/C1 0;
         wb -1/(R*C1) 0 0 0 1/C1;
         0 0 0 -wb 1/C2 0;
         0 0 wb 0 0 1/C2;
         -1/L 0 -1/L 0 0 -wb;
         0 -1/L 0 -1/L wb 0];

     % 0 -wb 1/C2 0 0 0;
     %     wb 0 0 1/C2 0 0;

    B = [1/(R*C1) 0;
         0 1/(R*C1);
         0 0;
         0 0;
         1/L 0
         0 1/L]/Vg2l;
  
     C = [-1/R 0 0 0 1 0;
          0 -1/R 0 0 0 1]/Il2g;

    D = [1/R 0;
        0 1/R]/Vg2l/Il2g;
else
    A = zeros(6);
    B = zeros(6,2);
    C = zeros(2,6);
    D = zeros(2);
end
  
    x = {join(['Shunt',num2str(number),'.vC1_ctypeq']) ;... 
         join(['Shunt',num2str(number),'.vC1_ctyped']) ;...
         join(['Shunt',num2str(number),'.vC2_ctypeq']) ;... 
         join(['Shunt',num2str(number),'.vC2_ctyped']) ;...
         join(['Shunt',num2str(number),'.iL_ctypeq']) ;... 
         join(['Shunt',num2str(number),'.iL_ctyped']) ;};

    u = {join(['NET.vn',num2str(bus),'q']) ;... 
        join(['NET.vn',num2str(bus),'d']) ;};

    y = {join(['Shunt',num2str(number),'.iq']) ;... 
         join(['Shunt',num2str(number),'.id']) ;} ;

    ctype = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end