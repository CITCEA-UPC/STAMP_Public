function [IN_CALCULATION] = SS_IN_CALCULATION(KC,VE0,IFD0,NAMEIN,NAMEOUT)

A     = [0];
B     = [0 0];
C     = [0];
D     = KC*[-IFD0/VE0^2 1/VE0];

x = {''}; 

IN_CALCULATION   = ss(A,B,C,D,'StateName',x,'inputname',NAMEIN,'outputname',NAMEOUT);
end