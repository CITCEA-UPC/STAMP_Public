function [Ploss Pdc Pc]=calclossdc(Pc,Qc,Vc,Pdc,Vdc,lossa, lossb, losscr, lossci)
%format long
%CALCLOSSAC Converter loss calculation.
%    [PLOSS]=CALCLOSSAC(PC,QC,VC,LOSSA, LOSSB, LOSSCR, LOSSCI)
%
%  Calculates the converter losses based on a loss model quadratically
%  dependent on the converter current Ic
%
%   Inputs:
%       PC : converter active power injection
%       QC : converter reactive power injection
%       VC : complex converter voltage
%       LOSSA : constant converter loss coefficient
%       LOSSB : linear converter loss coefficient
%       LOSSCR : quadratic converter loss coefficient (rectifier)
%       LOSSCI : quadratic converter loss coefficient (inverter)
%
%   Output:
%       PLOSS : converter losses
% 
%   Converter loss model obtained from: 
%       G. Daelemans, VSC HVDC in meshed networks, Master Thesis,
%       KU Leuven, July 2008.

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%%----- Converter loss input data -----
%% Per unit loss coefficients
a   = lossa;                %% constant loss coefficient  [-]
b   = lossb;                %% linear loss coefficient    [-]
c   = [losscr lossci];      %% quadratic loss coefficient [-]

%%----- Converter input data -----
%% Define other coefficients
nc          =   size(Pc,1);     %% number of converters
convmode    =   sign(Pc);       %% converter operation mode
rectifier   =   convmode>0;
inverter    =   convmode<0;
VMc         =   Vc;
c_mtx       =   rectifier.*c(:,1)+inverter.*c(:,2);
c_mtx       =   c(:,1);

%%----- Converter loss calculation -----
%% Define other coefficients
%Ic     = abs(conj((Pc+1j*Qc)./(VMc)))             %% reactor currents
%Ploss   = a.*ones(length(Ic),1)+b.*Ic+c_mtx.*Ic.^2 ;    %% reactor losses
%Ploss   = c_mtx.*(Ic/3).^2;    %% reactor losses
%% Define other coefficients
%Vdc
Pc;
Qc;
Vdc;
c_mtx;
Isum = [];
Isum2 = [];
Isum3 = [];
Plossp = [];
Vsum = [];
%Isum1     = (-Vdc-sqrt(Vdc.^2-4.*-c_mtx.*-Pc./3))./(-2.*c_mtx)            %% reactor currents
format long
for c = 1:1:size(Pc,1)
    Isum(c) = (-Vdc(c)+sqrt(Vdc(c)^2-4*-c_mtx(c)*-Pc(c)/3))/(-2*c_mtx(c));
    Isum2(c) = (-Vdc(c)+sqrt(Vdc(c)^2-4*c_mtx(c)*-Pc(c)/3))/(-2*c_mtx(c));
    Isum3(c) = (-Vdc(c)-sqrt(Vdc(c)^2-4*-c_mtx(c)*Pc(c)/3))/(-2*c_mtx(c));
    Plossp(c) = + 3*c_mtx(c)*Isum(c)^2;
    Vsum(c) = -c_mtx(c)*Isum(c) + Vdc(c);
end
Isum = Isum'
Isum2 = Isum2'
Isum3 = Isum3'
Plossp = Plossp';
Vsum = Vsum';
%Isum2     = (-Vdc+sqrt(Vdc.^2-4.*-c_mtx.*-Pc./3))./(-2.*c_mtx)
%Sc = sqrt(Pc.^2+Qc.^2)
%Ploss    = + 3.*c_mtx.*Isum2.^2    %% reactor losses
Ploss = Plossp;

Pdc = 3.*Vdc.*Isum;
Pc = 3.*Vsum.*Isum;
%Ploss = 0;

%Pdc    = 3.*Vdc.*Isum2
%Ploss = 3.*c_mtx.*Isum.^2;
