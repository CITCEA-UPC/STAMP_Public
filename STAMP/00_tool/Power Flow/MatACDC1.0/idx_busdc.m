function [BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX, ...
    VDCMIN, CDC]=idx_busdc
%IDX_BUSDC   Defines constants for named column indices to dc bus matrix.
%   [BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX, VDCMIN,...
%   ...., CDC]=idx_busdc
%
%   Some examples of usage, after defining the constants using the line above,
%   are:
%
%    Pd = busdc(4, PDC);        % get dc power withdrawal from dc grid at dc bus with index 4
%    busdc(:, VDCMIN) = 0.95;   % set min voltage magnitude to 0.95 at all dc buses
% 
%   The index, name and meaning of each column of the bus matrix is given
%   below:
%
%   columns 1-9 must be included in input matrix (in case file)
%    1  BUSDC_I     dc bus number
%    2  BUSAC_I     ac bus number (corresponding) 0 indicates no ac bus
%                   connection
%    3  GRIDDC      dc grid to which the BUSDC_I is connected
%    4  PDC         power withdrawn from the dc grid (MW)
%    5  VDC         dc voltage (p.u.)
%    6  BASE_KVDC   base dc voltage (kV)
%    7  VDCMAX      max dc voltage (p.u.)
%    8  VDCMIN      min dc voltage (p.u.)
%    9  CDC         dc bus capacitor size (p.u.) (not used in power flow)

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define the indices
BUSDC_I     = 1;        %% dc bus number
BUSAC_I     = 2;        %% ac bus number (corresponding) 0 indicates no ac bus connection
GRIDDC      = 3;        %% dc grid to which BUSDC_I is connected
PDC         = 4;        %% power withdrawal from the dc grid (MW)
VDC         = 5;        %% dc voltage (p.u.)
BASE_KVDC   = 6;        %% base dc voltage (kV)
VDCMAX      = 7;        %% max dc voltage (p.u.)
VDCMIN      = 8;        %% min dc voltage (p.u.)
CDC         = 9;        %% dc capacitor size (p.u.)

return;