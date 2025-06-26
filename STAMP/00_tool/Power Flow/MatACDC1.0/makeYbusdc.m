function [Ybusdc, Yfdc, Ytdc] = makeYbusdc(busdc, branchdc)

%MAKEYBUSDC   Builds the dc bus admittance matrix and branch admittance matrices.
%   [YBUSDC, YFDC, YTDC] = MAKEYBUSDC(BUSDC, BRANCHDC) 

%   returns the full bus admittance matrix (i.e. for all dc buses) and the 
%   matrices YFDC and YTDC which, when multiplied by the dc voltage 
%   vector, yield the vector currents injected into each dc line from the
%   "from" and "to" buses respectively of each line.
%
%   Input:
%       BUSDC : dc bus matrix
%       BRANCHDC : dc branch matrix
%        
%   Outputs:
%       YBUSDC : dc branch matrix with operating lines
%       YFDC : matrix when multiplied by dc voltage vector, yields currents
%           from the "from" buses
%       YTDC : matrix when multiplied by dc voltage vector, yields currents
%           from the "to" buses

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into dc branch matrices
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_X, BRDC_B, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;

%% constants
n = size(busdc, 1);          %% number of buses
m = size(branchdc, 1);       %% number of lines

%% for each branch, compute the elements of the branch admittance matrix where
%
%      | If |   | Yff  Yft |   | Vf |
%      |    | = |          | * |    |
%      | It |   | Ytf  Ytt |   | Vt |

Ys = ones(m,1) ./ branchdc(:,BRDC_R);

Ytt = Ys;
Yff = Ys;
Yft = - Ys;
Ytf = - Ys;

%% build connection matrices
f = branchdc(:, F_BUSDC);                  %% list of "from" buses
t = branchdc(:, T_BUSDC);                  %% list of "to" buses
Cf = sparse(1:m, f, ones(m, 1), m, n);     %% connection matrix for line & from buses
Ct = sparse(1:m, t, ones(m, 1), m, n);     %% connection matrix for line & to buses

%% build Yf and Yt such that Yf * V is the vector of complex branch currents injected
%% at each branch's "from" bus, and Yt is the same for the "to" bus end
i       = [1:m; 1:m]';                              %% double set of row indices
Yfdc    = sparse(i, [f; t], [Yff; Yft], m, n); 
Ytdc    = sparse(i, [f; t], [Ytf; Ytt], m, n);

Ybusdc = Cf' * Yfdc + Ct' * Ytdc;
    
return;