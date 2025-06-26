function [F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc
%IDX_BRCHDC  Defines constants for named column indices to dc branch matrix.
%   [F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ... 
%   RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc
%
%   Some examples of usage, after defining the constants using the line above,
%   are:
%
%    Ploss = branchdc(:, PFDC) + branchdc(:, PTDC); % compute real power loss vector
% 
%   The index, name and meaning of each column of the branch matrix is given
%   below:
%
%   columns 1-11 must be included in input matrix (in case file)
%    1  F_BUSDC     f, from bus number
%    2  T_BUSDC     t, to bus number
%    3  BRDC_R      r, resistance (p.u.)
%    4  BRDC_L      l, inductance (p.u./s) (not used in power flow)
%    5  BRDC_C      c, total line charging capacity (p.u.*s) (not used in power flow)
%    6  RATEDC_A    rateA, MVA rating A (long term rating)
%    7  RATEDC_B    rateB, MVA rating B (short term rating)
%    8  RATEDC_C    rateC, MVA rating C (emergency rating)
%    9  BRDC_STATUS initial branch status, 1 - in service, 0 - out of service
%
%   columns 10-11 are added to matrix after power flow
%   they are typically not present in the input matrix
%    10 PFDC        real power injected at "from" bus end (MW)
%    11 PTDC        real power injected at "to" bus end (MW)

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define the indices
F_BUSDC     = 1;    %% f, from bus number
T_BUSDC     = 2;    %% t, to bus number
BRDC_R      = 3;    %% r, resistance (p.u.)
BRDC_L      = 4;    %% inductance (p.u./s)
BRDC_C      = 5;    %% c, total line charging capacity (p.u.*s)
RATEDC_A    = 6;    %% rateA, MVA rating A (long term rating)
RATEDC_B    = 7;    %% rateB, MVA rating B (short term rating)
RATEDC_C    = 8;    %% rateC, MVA rating C (emergency rating)
BRDC_STATUS = 9;    %% initial branch status, 1 - in service, 0 - out of service

%% included in power flow solution, not necessarily in input
PFDC        = 10;   %% real power injected at "from" bus end (MW)
PTDC        = 11;   %% real power injected at "to" bus end (MW)

return;