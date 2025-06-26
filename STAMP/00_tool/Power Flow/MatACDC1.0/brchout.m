function [brch1, brch1i, brch0, brch0i] = brchout(branch)

%BRCHOUT  Split branch matrix into operating and non-operating lines. 
%   [BRCH1, BRCH1I, BRCH0, BRCH0I] = BRCHOUT(BRANCH)
%
%   Returns seperate branch matrices for lines in operation and those out
%   of operation, as well as their indices in the original brandch matrix.
%
%   Input:
%       BRANCH : dc branch matrix
%        
%   Outputs:
%       BRCH1 : branch matrix with operating lines
%       BRCH1I : indices of operating lines
%       BRCH0 : branch matrix with non-operating lines
%       BRCH0I : indices of non-operating lines

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%% converter status validity check
if any( (branch(:, BR_STATUS) ~= 0) & (branch(:, BR_STATUS) ~= 1) )
    error('branch status flags must be either 0 or 1');
end

%% define indices of outage branches
brch0i      = find(branch(:, BR_STATUS) == 0);
brch1i      = find(branch(:, BR_STATUS) == 1); 

%% define branchdc outage matrix
brch0      = branch(brch0i,:);
brch1      = branch(brch1i,:);

return;