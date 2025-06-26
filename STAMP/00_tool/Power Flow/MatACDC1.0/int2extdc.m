function [busdc, convdc, branchdc] = int2extdc(i2edcpmt, i2edc, busdc, ...
    convdc, branchdc)

%INT2EXTDC   Converts dc internal to external bus numbering.
%   [BUSDC, CONVDC, BRANCHDC] = INT2EXTDC(I2EDCPMT, I2EDC, BUSDC, ...
%       CONVDC, BRANCHDC)
%
%   Converts external dc bus numbers (possibly non-consecutive) to 
%   consecutive internal bus numbers, starting at 1.
%
%   Inputs:
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%       BRANCHDC : dc branch matrix
%
%   Outputs:
%       I2EDC : Internal to external dc indices
%       BUSDC : Updated dc bus matrix
%       CONVDC : Updated converter matrix
%       BRANCHDC : Updated dc branch matrix

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX,...
    VDCMIN, CDC]=idx_busdc;
 [DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF]=idx_convdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;

%%----- internal to external bus numbering -----
%% Part 1: Bus renumbering
busdc(   :,BUSDC_I )    = i2edc( busdc(   :, BUSDC_I )       );
convdc(  :,CONV_BUS)    = i2edc( convdc(  :, CONV_BUS)       );
branchdc(:,F_BUSDC )    = i2edc( branchdc(:, F_BUSDC )       );
branchdc(:,T_BUSDC )    = i2edc( branchdc(:, T_BUSDC )       );

%% Part 2: Change bus order of busdc matrix
busdc(i2edcpmt,:)       = busdc;

return;