function[ADD3] = SS_ADD3(NAME1,NAME2,NAME3,NAMEOUT)

A     = [0];
B     = [0 0 0];
C     = [0];
D     = [1 1 1];

x = {''}; 
u = {NAME1 NAME2 NAME3};
y = {NAMEOUT};
ADD3   = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end