function [Ploss]=calclossac(Pc,Qc,Vc,lossa, lossb, losscr, lossci)

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
VMc         =   abs(Vc);
c_mtx       =   rectifier.*c(:,1)+inverter.*c(:,2);

%%----- Converter loss calculation -----
%% Define other coefficients
Ic     = sqrt(Pc.^2+Qc.^2)./(VMc);             %% reactor currents
%Ploss   = a.*ones(length(Ic),1)+b.*Ic+c_mtx.*Ic.^2 ;    %% reactor losses
Ploss   = c_mtx.*(Ic/3).^2;    %% reactor losses
