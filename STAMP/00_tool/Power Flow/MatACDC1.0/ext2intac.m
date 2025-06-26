function [i2eac, acdum_i, busdc, bus, gen, branch] = ext2intac(busdc, ...
    bus, gen, branch)

%EXT2INTAC Converts external to internal bus numbering.
%   [I2EAC, ACDUM_I, BUSDC, BUS, GEN, BRANCH] = EXT2INTAC(BUSDC, ...
%       BUS, GEN, BRANCH) 
%
%   Converts external ac bus numbers (possibly non-consecutive) to 
%   consecutive internal bus numbers. The ac grid is sorted based on the
%   converter connected buses and dc buses, per dc grid. Dummy ac buses are
%   assigned to dc buses without a connection to the ac grid. All other ac
%   buses are grouped at the end.
%   
%   Example
%       Sorting result for 2 dc grids with outages in grid 1:
%       dc grid
%       1       number of ac bus with a connection to dc bus 1 (dc grid 1)
%       ...
%       4       number of ac bus with a connection to dc bus 4 (dc grid 1)
%       5       ac bus arbitrarily assigned to dc bus 5 (converter outage
%                   at dc bus 5 (dc grid 1)
%       ...     
%       7       number of ac bus with a connection to dc bus 7 (dc grid 2)
%       ...  
%       9       number of ac bus with a connection to dc bus 7 (dc grid 2)
%   
%       REST OF THE AC SYSTEM
%       10      ac bus 10 without a connection to the dc grid 
%       ...     other ac buses
%
%   Inputs:
%       BUSDC : dc bus matrix
%       BUS : ac bus matrix
%       GEN : generator matrix
%       BRANCH : ac branch matrix
%
%   Outputs:
%       I2EAC : Internal to external ac indices
%       ACDUM_I : bus numbers assigned to ac buses which have the same
%           number as a dc bus, but no physical connection to that dc bus.
%           These floating dc buses arrive as a result of converter outages
%           and dc buses without a connection to the ac grid.
%       BUS : Updated ac bus matrix
%       GEN : Updated generator matrix
%       BRANCH : Updated ac branch matrix

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX,...
    VDCMIN, CDC]=idx_busdc;
%% define named indices into bus, gen, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
 [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
     MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
     QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;   

%%-----  rename ac bus numbers  -----
%% check presence of converter station on ac busses
%% 28/6/11: aac1 to be removed and to be replaced by real variable !!!
[ accnv_i, aac1, accnv ]  =   find( busdc( :, BUSAC_I )      );
[ acdum_i           ]   =   find( busdc( :, BUSAC_I )==0   );
acnocnv                 =   setdiff(bus( :, BUS_I ), accnv );
acdum                   =   acnocnv( 1:length(acdum_i)     );
acnodum                 =   acnocnv( length(acdum_i)+1:end );

%% check presence of multiple converters on ac busses
if length(accnv) ~= length(unique(accnv))
    error('More than one converter per ac node detected!');
end 

%% define index matrices
i2eac                           =   zeros( length( bus(:,BUS_I)),1 );
i2eac( accnv_i    )             =   accnv;
i2eac( acdum_i    )             =   acdum;
i2eac(size(busdc,1)+1: end )    =   acnodum;
e2iac           =   zeros(max(i2eac), 1 );
e2iac(i2eac)    =   [1:size(bus, 1)     ]';

 
%% dummy ac bus additions to busdc matrix
busdc( acdum_i,BUSAC_I )  =   acdum;

%% rename ac busses
busdc(:,BUSAC_I)        = e2iac( busdc(:, BUSAC_I)        );
bus(:, BUS_I)           = e2iac( bus(:, BUS_I)            );
gen(:, GEN_BUS)         = e2iac( gen(:, GEN_BUS)          );
branch(:, F_BUS)        = e2iac( branch(:, F_BUS)         );
branch(:, T_BUS)        = e2iac( branch(:, T_BUS)         );

return;
