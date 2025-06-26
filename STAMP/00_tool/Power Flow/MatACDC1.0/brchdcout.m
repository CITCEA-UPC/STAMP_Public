function [brchdc1, brchdc1i, brchdc0, brchdc0i] = brchdcout(branchdc)

%BRCHDCOUT  Split branchdc matrix into operating and non-operating lines. 
%   [BRCHDC1, BRCHDC1I, BRCHDC0, BRCHDC0I] = BRCHDCOUT(BRANCHDC)
%
%   Returns seperate branch matrices for lines in operation and those out
%   of operation, as well as their indices in the original brandch matrix.
%
%   Input:
%       BRANCHDC : dc branch matrix
%        
%   Outputs:
%       BRCHDC1 : dc branch matrix with operating lines
%       BRCHDC1I : indices of operating dc lines
%       BRCHDC0 : dc branch matrix with non-operating lines
%       BRCHDC0I : indices of non-operating dc lines

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;

%% converter status validity check
if any( (branchdc(:, BRDC_STATUS) ~= 0) & (branchdc(:, BRDC_STATUS) ~= 1) )
    error('branch status flags must be either 0 or 1');
end

%% define indices of outage branches
brchdc0i      = find(branchdc(:, BRDC_STATUS) == 0);
brchdc1i      = find(branchdc(:, BRDC_STATUS) == 1); 

%% define branchdc outage matrix
brchdc0      = branchdc(brchdc0i,:);
brchdc1      = branchdc(brchdc1i,:);

return;