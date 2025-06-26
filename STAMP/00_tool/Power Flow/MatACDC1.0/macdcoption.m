function options = macdcoption

%MACDCOPTION used to retrieve a MATACDC options vector.
%   OPTIONS = MACDCOPTION
% 
%   returns default option vector
%
% The currently defined options are:
%   
%   idx - NAME,default              description [options]
%   ---   ------------              ---------------------------------------
%    1  - TOLACDC, 1e-8             tolerance ac/dc power flow
%    2  - ITMAXACDC, 10             maximum iterations ac/dc power flow
%    3  - TOLDC, 1e-8               tolerance dc power flow (Newton's 
%                                   method)
%    4  - ITMAXDC, 10               maximum iterations dc power flow 
%                                   (Newton's method)
%    5  - TOLSLACKDROOP, 1e-8       tolerance dc slack bus iteration
%    6  - ITMAXSLACKDROOP, 10       maximum iterations dc slack bus iteration
%    7  - TOLSLACKDROOPINT, 1e-8    tolerance internal slack bus iteration 
%                                   (Newton's method)
%    8  - ITMAXSLACKDROOPINT, 10    maximum iterations internal slack bus 
%                                   iteration (Newton's method)
%    9  - MULTSLACK, 0              multiple dc slack buses (dc voltage 
%                                   controlling converters) per dc grid
%        [  0 - only 1 dc voltage controlling per dc grid allowed        ]
%        [  1 - more than 1 dc voltage controlling per dc grid allowed   ]
%
%   10  - LIMAC, 0                  enforce ac converter limits
%        [  0 - do NOT enforce limits                                    ]
%        [  1 - enforce converter current and voltage limits             ]
%   11  - LIMDC, 0                  enforce dc converter limits (not 
%                                   implemented)
%   12  - TOLLIM, 1e-2              maximum difference between subsequent
%                                   violations
%
%   13  - OUTPUT, 1                 print output
%   14  - CONVPLOTOPT, 0            plot converter limit violations
%        [  0 - do not plot converter limit violations                   ]
%        [  1 - plot only converter limit violations                     ]
%        [  2 - plot converter limit violations and end situation        ]

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% Options vector
options = [ 
    1e-8;           %% tolerance ac/dc power flow
    10;             %% maximum iterations ac/dc power flow
    1e-8;           %% tolerance dc power flow (Newton's method)
    10;             %% maximum iterations dc power flow (Newton's method)
    1e-8;           %% tolerance slack/droop bus iteration 
    10;             %% maximum iterations slack/droop bus iteration
    1e-8;           %% tolerance internal slack/droop bus iteration (Newton's method)
    10;             %% maximum iterations internal slack/droop bus iteration (Newton's method)
    0;              %% multiple dc slack buses per dc grid allowed
    
    0;              %% ac limits converters enabled
    0;              %% dc limits converters enabled (not implemented)
    1e-2;           %% maximum error between subsequent limit violations
    
    1;              %% print output
    0;              %% plot converter station limit violations (1 = only viol, 2 = viol + end situation)
];

return;
