function [busdc, bus, gen, branch] = ...
    int2extac(i2eac, acdum_i, busdc, bus, gen, branch)

%INT2EXTAC Converts to internal bus numbering.
%   [BUSDC, BUS, GEN, BRANCH] = INT2EXTAC(I2EAC, ACDUM_I, BUSDC, BUS, ...
%       GEN, BRANCH) 
%
%   Converts consecutive internal ac bus numbers back to the original bus
%   numbers using the mapping provided by I2EAC returned from EXT2INTAC and
%   removes the dummy ac buses assigned to the dc buses without connection 
%   to the ac grid as a result from EXT2INTAC.
%
%   Inputs:
%       I2EAC : internal to external ac indices
%       ACDUM_I : bus numbers assigned to ac buses which have the same
%           number as a dc bus, but no physical connection to that dc bus.
%           These floating dc buses arrive as a result of converter outages
%           and dc buses without a connection to the ac grid.
%       BUSDC : dc bus matrix
%       BUS : ac bus matrix
%       GEN : generator matrix
%       BRANCH : ac branch matrix
%
%   Outputs:
%       BUSDC : updated dc bus matrix
%       BUS : updated ac bus matrix
%       GEN : updated generator matrix
%       BRANCH : updated ac branch matrix

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


%% rename bus numbers
busdc(:, BUSAC_I)   = i2eac( busdc(:, BUSAC_I)  );
bus(:, BUS_I)       = i2eac( bus(:, BUS_I)      );
gen(:, GEN_BUS)     = i2eac( gen(:, GEN_BUS)    );
branch(:, F_BUS)    = i2eac( branch(:, F_BUS)   );
branch(:, T_BUS)    = i2eac( branch(:, T_BUS)   );

%% Dummy ac bus removal
busdc(acdum_i, BUSAC_I) = 0;
    


