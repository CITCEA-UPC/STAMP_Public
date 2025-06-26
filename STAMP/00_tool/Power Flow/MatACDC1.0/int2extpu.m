function [busdc, convdc, branchdc]=int2extpu(baseMVA, baseMVAac, ...
    baseMVAdc, busdc, convdc, branchdc)

% INT2EXTPU Converts internal per unit values to original values. 
%   [BUSDC, CONVDC, BRANCHDC]=INT2EXTPU(BASEMVA, BASEMVAAC, BASEMVADC, ...
%       BUSDC, CONVDC, BRANCHDC, POL)
%
%   Converts internal per unit values of the dc matrices (busdc, convdc 
%   and branchdc) to the original bases provided in the input files.
%
%   Inputs:
%       BASEMVA : base power of ac power flow data
%       BASEMVAAC : base power of ac data of the converters
%       BASEMVADC : base power of dc data of the dc system
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%       BRANCHDC : dc branch matrix
%
%   Outputs:
%       BUSDC : Updated dc bus matrix
%       CONVDC : Updated converter matrix
%       BRANCHDC : Updated dc branch matrix

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%%-----  initialize  -----
%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX,...
    VDCMIN, CDC]=idx_busdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;
 [DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF]=idx_convdc;

%%-----  per unit conversion  -----
%%Only p.u. impedances and currents are changed. Voltages (p.u.) and
%%powers (real values) are left unaltered.
%% converter ac side conversion
convdc(:,RTF)   =   convdc(:,RTF)*baseMVAac/baseMVA;    %% (p.u.)
convdc(:,XTF)   =   convdc(:,XTF)*baseMVAac/baseMVA;    %% (p.u.)
convdc(:,BF)    =   convdc(:,BF)*baseMVAac/baseMVA;     %% (p.u.)
convdc(:,RCONV) =   convdc(:,RCONV)*baseMVAac/baseMVA;  %% (p.u.) values converted to original (p.u.) base
convdc(:,XCONV) =   convdc(:,XCONV)*baseMVAac/baseMVA;  %% (p.u.) values converted to original (p.u.) base
convdc(:,ICMAX) =   convdc(:,ICMAX)*baseMVA/baseMVAac;

%%==> dc side per unit convention
%%basekAdc = baseMVAdc/basekVdc
%%baseRdc  = basekVdc^2/baseMVAdc

%% converter dc side conversion
baseR_busdc     =   busdc(:,BASE_KVDC).^2/baseMVAdc;     %% (Ohm)
baseR_busdc2ac  =   busdc(:,BASE_KVDC).^2/baseMVA;       %% (Ohm)
busdc(:,CDC)    =   busdc(:,CDC)./baseR_busdc2ac.*baseR_busdc;     %% (p.u.*s)  values converted to original (p.u.*s) base 

%% dc network branch conversion
baseKVDC_brch       =   busdc(F_BUSDC,BASE_KVDC);
baseR_brchdc        =   baseKVDC_brch .^2/baseMVAdc; 
baseR_brchdc2ac     =   baseKVDC_brch .^2/baseMVA; 
branchdc(:,BRDC_R)  =   branchdc(:,BRDC_R).*baseR_brchdc2ac./baseR_brchdc;     %% (p.u.*s)  values converted to original (p.u.*s) base 
branchdc(:,BRDC_L)  =   branchdc(:,BRDC_L).*baseR_brchdc2ac./baseR_brchdc;     %% (p.u.*s)  values converted to original (p.u.*s) base 
branchdc(:,BRDC_C)  =   branchdc(:,BRDC_C)./baseR_brchdc2ac.*baseR_brchdc;     %% (p.u.*s)  values converted to original (p.u.*s) base  