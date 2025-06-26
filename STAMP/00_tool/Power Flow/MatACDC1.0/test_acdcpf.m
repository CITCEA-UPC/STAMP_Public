function test_acdcpf

% TEST_ACDCPF  test script to run a sequential ac/dc power flow 

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define options
mdopt = macdcoption;
mdopt(13) =0;     % no output info

%% run ac/dc power flow simulations 
fprintf('> test voltage slack control')
[baseMVA, bus gen ,branch, busdc, convdc, branchdc, converged, ...
        timecalc] = runacdcpf('case5_stagg', 'case5_stagg_MTDCslack', mdopt);

fprintf(' -> Done. \n> test voltage droop control')
[baseMVA, bus gen ,branch, busdc, convdc, branchdc, converged, ...
        timecalc] = runacdcpf('case5_stagg', 'case5_stagg_MTDCdroop', mdopt);
    
fprintf(' -> Done. \n> test infinite grid')
[baseMVA, bus gen ,branch, busdc, convdc, branchdc, converged, ...
        timecalc] = runacdcpf('case3_inf', 'case5_stagg_MTDCdroop', mdopt);
    
fprintf(' -> Done. \n> test multiple ac and dc systems')
[baseMVA, bus gen ,branch, busdc, convdc, branchdc, converged, ...
        timecalc] = runacdcpf('case24_ieee_rts1996_3zones', 'case24_ieee_rts1996_MTDC', mdopt);
    
fprintf(' -> Done. \n')
return;